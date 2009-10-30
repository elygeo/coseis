#!/usr/bin/env python
"""
Support Operator Rupture Dynamics
"""
import os, sys, re, math
import util, configure, fieldnames
from extras import coord, egmm, signal, source, viz, swab
try:
    from extras import rspectra
except( ImportError ):
    pass

def stage( inputs ):
    """
    Setup, and optionally launch, a SORD job.
    """
    import glob, time, getopt, shutil
    import setup

    # Save start time
    starttime = time.asctime()
    print( 'SORD setup' )

    # Read defaults
    pm = {}
    f = os.path.join( os.path.dirname( __file__ ), 'parameters.py' )
    exec open( f ) in pm
    if 'machine' in inputs:
        cf = configure.configure( machine=inputs['machine'] )
    else:
        cf = configure.configure()

    # Merge inputs
    util.prune( inputs )
    util.prune( pm )
    util.prune( cf, pattern='(^_)|(^.$)' )
    for k, v in inputs.iteritems():
        if k in cf:
            cf[k] = v
        elif k in pm:
            pm[k] = v
        else:
            sys.exit( 'Unknown parameter: %s = %r' % ( k, v ) )
    cf = util.namespace( cf )
    cf.rundir = os.path.expanduser( cf.rundir )
    pm = prepare_param( util.namespace( pm ), cf.itbuff )

    # Command line options
    opts = [
        'n', 'dryrun',
        's', 'serial',
        'm', 'mpi',
        'i', 'interactive',
        'q', 'queue',
        'd', 'debug',
        'g', 'debugging',
        't', 'testing',
        'p', 'profiling',
        'O', 'optimized',
        'f', 'force',
    ]
    options = ''.join( opts[::2] )
    long_options = opts[1::2]
    opts = getopt.getopt( sys.argv[1:], options, long_options )[0]
    for o, v in opts:
        if   o in ('-n', '--dry-run'):
            cf.prepare = False
        elif o in ('-s', '--serial'):
            cf.mode = 's'
        elif o in ('-m', '--mpi'):
            cf.mode = 'm'
        elif o in ('-i', '--interactive'):
            cf.run = 'i'
        elif o in ('-q', '--queue'):
            cf.run = 'q'
        elif o in ('-d', '--debug'):
            cf.optimize = 'g'
            cf.run = 'g'
        elif o in ('-g', '--debugging'):
            cf.optimize = 'g'
        elif o in ('-t', '--testing'):
            cf.optimize = 't'
        elif o in ('-p', '--profiling'):
            cf.optimize = 'p'
        elif o in ('-O', '--optimized'):
            cf.optimize = 'O'
        elif o in ('-f', '--force'):
            if os.path.isdir( cf.rundir ):
                shutil.rmtree( cf.rundir )
        else:
            sys.exit( 'Error: unknown option: ' + o )
    if not cf.prepare:
        cf.run = False

    # Partition for parallelization
    pm.nn = tuple( int(i) for i in pm.nn )
    maxtotalcores = cf.maxnodes * cf.maxcores
    if not cf.mode and maxtotalcores == 1:
        cf.mode = 's'
    np3 = pm.np3[:]
    if cf.mode == 's':
        np3 = [1, 1, 1]
    nl = [ (pm.nn[i] - 1) / np3[i] + 1 for i in range(3) ]
    i  = abs( pm.faultnormal ) - 1
    if i >= 0:
        nl[i] = max( nl[i], 2 )
    pm.np3 = tuple( (pm.nn[i] - 1) / nl[i] + 1 for i in range(3) )
    cf.np = pm.np3[0] * pm.np3[1] * pm.np3[2]
    if not cf.mode:
        cf.mode = 's'
        if cf.np > 1:
            cf.mode = 'm'

    # Resources
    if cf.maxcores:
        cf.nodes = min( cf.maxnodes, (cf.np - 1) / cf.maxcores + 1 )
        cf.ppn = (cf.np - 1) / cf.nodes + 1
        cf.cores = min( cf.maxcores, cf.ppn )
        cf.totalcores = cf.nodes * cf.maxcores
    else:
        cf.nodes = 1
        cf.ppn = cf.np
        cf.cores = cf.np
        cf.totalcores = cf.np

    # RAM and Wall time usage
    if pm.oplevel in (1, 2):
        nvars = 20
    elif pm.oplevel in (3, 4, 5):
        nvars = 23
    else:
        nvars = 44
    nm = (nl[0] + 2) * (nl[1] + 2) * (nl[2] + 2)
    cf.pmem = 32 + int(1.2 * nm * nvars * int( cf.dtype[-1] ) / 1024 / 1024)
    cf.ram = cf.pmem * cf.ppn
    ss  = (pm.nt + 10) * cf.ppn * nm / cf.cores / cf.rate
    sus = int( ss / 3600 * cf.totalcores + 1 )
    mm  =      ss / 60 * 3.0 + 10
    if cf.maxtime:
        mm = min( mm, 60*cf.maxtime[0] + cf.maxtime[1] )
    hh = mm / 60
    mm = mm % 60
    cf.walltime = '%d:%02d:00' % (hh, mm)
    print( 'Machine: ' + cf.machine )
    print( 'Cores: %s of %s' % (cf.np, maxtotalcores) )
    print( 'Nodes: %s of %s' % (cf.nodes, cf.maxnodes) )
    print( 'RAM: %sMb of %sMb per node' % (cf.ram, cf.maxram) )
    print( 'Time limit: ' + cf.walltime )
    print( 'SUs: %s' % sus )
    if cf.maxcores and cf.ppn > cf.maxcores:
        print( 'Warning: exceding available cores per node (%s)' % cf.maxcores )
    if cf.ram and cf.ram > cf.maxram:
        print( 'Warning: exceding available RAM per node (%sMb)' % cf.maxram )

    # Compile code
    if not cf.prepare:
        return cf
    setup.build( cf.mode, cf.optimize )

    # Create run directory
    print( 'Run directory: ' + cf.rundir )
    try:
        os.makedirs( cf.rundir )
    except( OSError ):
        sys.exit( '%r exists or cannot be created. Use --force to overwrite.'
            % cf.rundir )
    for f in 'in', 'out', 'prof', 'stats', 'debug', 'checkpoint':
        os.mkdir( os.path.join( cf.rundir, f ) )

    # Link input files
    for i, line in enumerate( pm.fieldio ):
        if 'r' in line[0] or 'R' in line[0] and os.sep in line[8]:
            filename = os.path.expanduser( line[8] )
            f = os.path.basename( filename )
            line = line[:8] + (f,) + line[9:]
            pm.fieldio[i] = line
            f = os.path.join( cf.rundir, 'in', f )
            try:
                os.link( filename, f )
            except( 'OSError' ):
                os.symlink( filename, f )
    for pat in cf.infiles:
        for filename in glob.glob( os.path.expanduser( pat ) ):
            f = os.path.basename( filename )
            f = os.path.join( cf.rundir, 'in', f )
            try:
                os.link( filename, f )
            except( 'OSError' ):
                os.symlink( filename, f )

    # Copy files to run directory
    cwd = os.path.realpath( os.getcwd() )
    cf.rundate = time.asctime()
    cf.name = os.path.basename( cf.rundir )
    cf.rundir = os.path.realpath( cf.rundir )
    os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )
    cf.bin = os.path.join( '.', 'sord-' + cf.mode + cf.optimize )
    path = os.path.join( 'bin', 'sord-' + cf.mode + cf.optimize )
    shutil.copy( path, cf.rundir )
    if os.path.isfile( 'sord.tgz' ):
        shutil.copy( 'sord.tgz', cf.rundir )
    if cf.optimize == 'g':
        for f in glob.glob( os.path.join( 'src', '*.f90' ) ):
            shutil.copy( f, cf.rundir )
    f = os.path.join( 'conf', cf.machine, 'templates' )
    if not os.path.isdir( f ):
        f = os.path.join( 'conf', 'default', 'templates' )
    for d in os.path.join( 'conf', 'common', 'templates' ), f:
        for f in glob.glob( os.path.join( d, '*' ) ):
            ff = os.path.join( cf.rundir, os.path.basename( f ) )
            out = open( f ).read() % cf.__dict__
            open( ff, 'w' ).write( out )
            shutil.copymode( f, ff )

    # Write files
    os.chdir( cf.rundir )
    log = open( 'log', 'w' )
    log.write( starttime + ': setup started\n' )
    util.save( 'parameters.py', pm, expand=['fieldio'] )
    util.save( 'conf.py', cf, prune_pattern='(^_)|(^.$)' )

    # Return to initial directory
    os.chdir( cwd )
    return cf

def prepare_param( pm, itbuff ):
    """
    Prepare input paramers
    """

    # inervals
    pm.itio = max( 1, min(pm.itio, pm.nt) )
    if pm.itcheck % pm.itio != 0:
        pm.itcheck = (pm.itcheck / pm.itio + 1) * pm.itio

    # hypocenter coordinates
    xi = list( pm.ihypo )
    for i in range( 3 ):
        xi[i] = 0.0 + xi[i]
        if xi[i] == 0.0:
            xi[i] = 0.5 * (pm.nn[i] + 1)
        elif xi[i] <= -1.0:
            xi[i] = xi[i] + pm.nn[i] + 1
        if xi[i] < 1.0 or xi[i] > pm.nn[i]:
            sys.exit( 'Error: ihypo %s out of bounds' % xi )
    pm.ihypo = tuple( xi )

    # Rupture boundary conditions
    i1 = list( pm.bc1 )
    i2 = list( pm.bc2 )
    i = abs(pm.faultnormal) - 1
    if i >= 0:
        irup = int( xi[i] )
        if irup == 1:
            i1[i] = -2
        if irup == pm.nn[i] - 1:
            i2[i] = -2
        if irup < 1 or irup > (pm.nn[i] - 1):
            sys.exit( 'Error: ihypo %s out of bounds' % xi )
    pm.bc1 = tuple( i1 )
    pm.bc2 = tuple( i2 )

    # PML region
    i1 = [0, 0, 0]
    i2 = [n+1 for n in pm.nn]
    if pm.npml > 0:
        for i in range( 3 ):
            if pm.bc1[i] == 10:
                i1[i] = pm.npml
            if pm.bc2[i] == 10:
                i2[i] = pm.nn[i] - pm.npml + 1
            if i1[i] > i2[i]:
                sys.exit( 'Error: model too small for PML' )
    pm.i1pml = tuple( i1 )
    pm.i2pml = tuple( i2 )

    # I/O sequence
    fieldio = []
    for line in pm.fieldio:
        line = list( line )
        filename = '-'
        tfunc, val, period = 'const', 1.0, 1.0
        x1 = x2 = 0.0, 0.0, 0.0
        op = line[0][0]
        mode = line[0][1:]
        if op not in '=+':
            sys.exit( 'Error: unsupported operator: %r' % line )
        try:
            if len( line ) is 10:
                tfunc, period, x1, x2, nb, ii, field, filename, val = line[1:]
            elif mode in ['r', 'R', 'w', 'wi']:
                field, ii, filename = line[1:]
            elif mode in ['', 's', 'i']:
                field, ii, val = line[1:]
            elif mode in ['f', 'fs', 'fi']:
                field, ii, val, tfunc, period = line[1:]
            elif mode in ['c']:
                field, ii, val, x1, x2 = line[1:]
            elif mode in ['fc']:
                field, ii, val, tfunc, period, x1, x2 = line[1:]
            else:
                sys.exit( 'Error: bad i/o mode: %r' % line )
        except( ValueError ):
            sys.exit( 'Error: bad i/o spec: %r' % line )
        filename = os.path.expanduser( filename )
        mode = mode.replace( 'f', '' )
        if field not in fieldnames.all:
            sys.exit( 'Error: unknown field: %r' % line )
        if pm.faultnormal == 0 and field in fieldnames.fault:
            sys.exit( 'Error: field only for ruptures: %r' % line )
        if 'w' not in mode and field not in fieldnames.input:
            sys.exit( 'Error: field is ouput only: %r' % line )
        nn = list( pm.nn ) + [pm.nt]
        if field in fieldnames.cell:
            mode = mode.replace( 'c', 'C' )
            base = 1.5
        else:
            base = 1
        if 'i' in mode:
            x1 = util.expand_slice( pm.nn, ii[:3], base, round=False )
            x1 = tuple( i[0] + 1 - base for i in x1 )
            i1 = tuple( math.ceil( i )  for i in x1 )
            ii = ( util.expand_slice( pm.nn, i1, 1 )
                 + util.expand_slice( [pm.nt], ii[3:], 1 ) )
        else:
            ii = ( util.expand_slice( pm.nn, ii[:3], base )
                 + util.expand_slice( [pm.nt], ii[3:], 1 ) )
        if field in fieldnames.initial:
            ii[3] = 0, 0, 1
        if field in fieldnames.fault:
            i = pm.faultnormal - 1
            ii[i] = 2 * (irup,) + (1,)
        nn = [ (ii[i][1] - ii[i][0] + 1) / ii[i][2] for i in range(4) ]
        nb = ( min( pm.itio, pm.nt ) - 1 ) / ii[3][2] + 1
        nb = max( 1, min( nb, nn[3] ) )
        n = nn[0] * nn[1] * nn[2]
        if n > (pm.nn[0] + pm.nn[1] + pm.nn[2]) ** 2:
            nb = 1
        elif n > 1:
            nb = min( nb, itbuff )
        fieldio += [
            (op + mode, tfunc, period, x1, x2, nb, ii, field, filename, val)
        ]
    f = [ line[8] for line in fieldio if line[8] != '-' ]
    for i in range( len( f ) ):
        if f[i] in f[:i]:
            sys.exit( 'Error: duplicate filename: %r' % f[i] )
    pm.fieldio = fieldio
    return pm

def launch( cf ):
    """
    Launch or queue job.
    """
    cwd = os.getcwd()
    os.chdir( cf.rundir )
    if cf.run == 'q':
        print( 'queue.sh' )
        if cf.host not in cf.hosts:
            sys.exit( 'Error: hostname %r does not match configuration %r'
                % (cf.host, cf.machine) )
        if os.system( os.path.join( '.', 'queue.sh' ) ):
            sys.exit( 'Error queing job' )
    elif cf.run:
        print( 'run.sh -' + cf.run )
        if cf.host not in cf.hosts:
            sys.exit( 'Error: hostname %r does not match configuration %r'
                % (cf.host, cf.machine) )
        if os.system( os.path.join( '.', 'run.sh -' + cf.run ) ):
            sys.exit( 'Error running job' )
    os.chdir( cwd )
    return

def run( inputs ):
    """
    Combined stage and launch in one step.
    """
    cf = stage( inputs )
    launch( cf )
    return cf

