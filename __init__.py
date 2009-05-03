#!/usr/bin/env python
"""
Support Operator Rupture Dynamics
"""
import util, configure, fieldnames

def stage( inputs ):
    """Setup, and optionally launch, a SORD job."""
    import os, sys, pwd, glob, time, getopt, shutil
    import util, configure, setup

    # Save start time
    starttime = time.asctime()
    print( 'SORD setup' )

    # Read defaults
    prm = util.load( os.path.join( os.path.dirname( __file__ ), 'default-prm.py' ) )
    if 'machine' in inputs:
        cfg = configure.configure( machine=inputs['machine'] )
    else:
        cfg = configure.configure()

    # Merge inputs
    for k, v in inputs.iteritems():
        if k[0] is not '_' and type(v) not in [type(os), type(os.walk)]:
            if k in cfg:
                cfg[k] = v
            elif k in prm:
                prm[k] = v
            else:
                sys.exit( 'Unknown parameter: %s = %r' % ( k, v ) )
    cfg = util.objectify( cfg )
    cfg.rundir = os.path.expanduser( cfg.rundir )
    prm = prepare_prm( util.objectify( prm ), cfg.itbuff )

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
    opts, args = getopt.getopt( sys.argv[1:], options, long_options )
    for o, v in opts:
        if   o in ('-n', '--dry-run'):     cfg.prepare = False
        elif o in ('-s', '--serial'):      cfg.mode = 's'
        elif o in ('-m', '--mpi'):         cfg.mode = 'm'
        elif o in ('-i', '--interactive'): cfg.run = 'i'
        elif o in ('-q', '--queue'):       cfg.run = 'q'
        elif o in ('-d', '--debug'):       cfg.optimize = 'g'; cfg.run = 'g'
        elif o in ('-g', '--debugging'):   cfg.optimize = 'g'
        elif o in ('-t', '--testing'):     cfg.optimize = 't'
        elif o in ('-p', '--profiling'):   cfg.optimize = 'p'
        elif o in ('-O', '--optimized'):   cfg.optimize = 'O'
        elif o in ('-f', '--force'):
            if os.path.isdir( cfg.rundir ): shutil.rmtree( cfg.rundir )
        else: sys.exit( 'Error: unknown option: ' + o )
    if not cfg.prepare: cfg.run = False

    # Partition for parallelization
    prm.nn = tuple([ int( i ) for i in  prm.nn ])
    maxtotalcores = cfg.maxnodes * cfg.maxcores
    if not cfg.mode and maxtotalcores == 1:
        cfg.mode = 's'
    np3 = prm.np3[:]
    if cfg.mode == 's':
        np3 = [ 1, 1, 1 ]
    nl = [ ( prm.nn[i] - 1 ) / np3[i] + 1 for i in range(3) ]
    i  = abs( prm.faultnormal ) - 1
    if i >= 0:
        nl[i] = max( nl[i], 2 )
    np3 = [ ( prm.nn[i] - 1 ) / nl[i] + 1 for i in range(3) ]
    prm.np3 = tuple( np3 )
    cfg.np = np3[0] * np3[1] * np3[2]
    if not cfg.mode:
        cfg.mode = 's'
        if cfg.np > 1:
            cfg.mode = 'm'

    # Resources
    if cfg.maxcores:
        cfg.nodes = min( cfg.maxnodes, ( cfg.np - 1 ) / cfg.maxcores + 1 )
        cfg.ppn = ( cfg.np - 1 ) / cfg.nodes + 1
        cfg.cores = min( cfg.maxcores, cfg.ppn )
        cfg.totalcores = cfg.nodes * cfg.maxcores
    else:
        cfg.nodes = 1
        cfg.ppn = cfg.np
        cfg.cores = cfg.np
        cfg.totalcores = cfg.np

    # RAM and Wall time usage
    if prm.oplevel in (1,2):
         nvars = 20
    elif prm.oplevel in (3,4,5):
         nvars = 23
    else:
         nvars = 44
    nm = ( nl[0] + 2 ) * ( nl[1] + 2 ) * ( nl[2] + 2 )
    cfg.pmem = 32 + int( 1.2 * nm * nvars * int( cfg.dtype[-1] ) / 1024 / 1024 )
    cfg.ram = cfg.pmem * cfg.ppn
    sus = int( ( prm.nt + 10 ) * cfg.ppn * nm / cfg.cores / cfg.rate / 3600 * cfg.totalcores + 1 )
    mm  =      ( prm.nt + 10 ) * cfg.ppn * nm / cfg.cores / cfg.rate / 60 * 3.0 + 10
    if cfg.maxtime:
        mm = min( 60*cfg.maxtime[0] + cfg.maxtime[1], mm )
    hh = mm / 60
    mm = mm % 60
    cfg.walltime = '%d:%02d:00' % ( hh, mm )
    print( 'Machine: ' + cfg.machine )
    print( 'Cores: %s of %s' % ( cfg.np, maxtotalcores ) )
    print( 'Nodes: %s of %s' % ( cfg.nodes, cfg.maxnodes ) )
    print( 'RAM: %sMb of %sMb per node' % ( cfg.ram, cfg.maxram ) )
    print( 'Time limit: ' + cfg.walltime )
    print( 'SUs: %s' % sus )
    if cfg.maxcores and cfg.ppn > cfg.maxcores:
        print( 'Warning: exceding available cores per node (%s)' % cfg.maxcores )
    if cfg.ram and cfg.ram > cfg.maxram:
        print( 'Warning: exceding available RAM per node (%sMb)' % cfg.maxram )

    # Compile code
    if not cfg.prepare:
        return cfg
    setup.build( cfg.mode, cfg.optimize )

    # Create run directory
    print( 'Run directory: ' + cfg.rundir )
    try:
        os.makedirs( cfg.rundir )
    except:
        sys.exit( 'Directory %r already exists or cannot be created. Use --force to overwrite.' % cfg.rundir )
    for f in ( 'in', 'out', 'prof', 'stats', 'debug', 'checkpoint' ):
        os.mkdir( os.path.join( cfg.rundir, f ) )

    # Link input files
    for i, line in enumerate( prm.fieldio ):
        if 'r' in line[0] or 'R' in line[0] and os.sep in line[8]:
            filename = os.path.expanduser( line[8] )
            f = os.path.basename( filename )
            line = line[:8] + ( f, ) + line[9:]
            prm.fieldio[i] = line
            f = os.path.join( cfg.rundir, 'in', f )
            try:
                os.link( filename, f )
            except:
                os.symlink( filename, f )
    for pat in cfg.infiles:
        for filename in glob.glob( os.path.expanduser( pat ) ):
            f = os.path.basename( filename )
            f = os.path.join( cfg.rundir, 'in', f )
            try:
                os.link( filename, f )
            except:
                os.symlink( filename, f )

    # Copy files to run directory
    cwd = os.path.realpath( os.getcwd() )
    cfg.rundate = time.asctime()
    cfg.name = os.path.basename( cfg.rundir )
    cfg.rundir = os.path.realpath( cfg.rundir )
    os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )
    cfg.bin = os.path.join( '.', 'sord-' + cfg.mode + cfg.optimize )
    shutil.copy( os.path.join( 'bin', 'sord-' + cfg.mode + cfg.optimize ), cfg.rundir )
    if os.path.isfile( 'sord.tgz' ):
        shutil.copy( 'sord.tgz', cfg.rundir )
    if cfg.optimize == 'g':
        for f in glob.glob( os.path.join( 'src', '*.f90' ) ):
            shutil.copy( f, cfg.rundir )
    f = os.path.join( 'conf', cfg.machine, 'templates' )
    if not os.path.isdir( f ):
        f = os.path.join( 'conf', 'default', 'templates' )
    for d in [ os.path.join( 'conf', 'common', 'templates' ), f ]:
        for f in glob.glob( os.path.join( d, '*' ) ):
            ff = os.path.join( cfg.rundir, os.path.basename( f ) )
            out = open( f, 'r' ).read() % util.dictify( cfg )
            open( ff, 'w' ).write( out )
            shutil.copymode( f, ff )

    # Write files
    os.chdir( cfg.rundir )
    log = open( 'log', 'w' )
    log.write( starttime + ': setup started\n' )
    util.save( 'parameters.py', util.dictify( prm ), [ 'fieldio' ] )
    util.save( 'conf.py', util.dictify( cfg ) )

    # Return to initial directory
    os.chdir( cwd )
    return cfg

def prepare_prm( prm, itbuff ):
    """Prepare input paramers"""
    import os, sys, util, fieldnames

    # inervals
    prm.itio = max( 1, min( prm.itio, prm.nt ) )
    if prm.itcheck % prm.itio != 0:
        prm.itcheck = ( prm.itcheck / prm.itio + 1 ) * prm.itio

    # hypocenter coordinates
    xi = list( prm.ihypo )
    for i in range( 3 ):
        xi[i] = 0.0 + xi[i]
        if xi[i] == 0.0:
            xi[i] = 0.5 * ( prm.nn[i] + 1 )
        elif xi[i] <= -1.0:
            xi[i] = xi[i] + prm.nn[i] + 1
        if xi[i] < 1.0 or xi[i] > prm.nn[i]:
            sys.exit( 'Error: ihypo %s out of bounds' % xi )
    prm.ihypo = tuple( xi )

    # Rupture boundary conditions
    i1 = list( prm.bc1 )
    i2 = list( prm.bc2 )
    i = abs( prm.faultnormal ) - 1
    if i >= 0:
        irup = int( xi[i] )
        if irup == 1:             i1[i] = -2
        if irup == prm.nn[i] - 1: i2[i] = -2
        if irup < 1 or irup > ( prm.nn[i] - 1 ):
            sys.exit( 'Error: ihypo %s out of bounds' % xi )
    prm.bc1 = tuple( i1 )
    prm.bc2 = tuple( i2 )

    # PML region
    i1 = [ 0, 0, 0 ]
    i2 = [ n+1 for n in prm.nn ]
    if prm.npml > 0:
        for i in range( 3 ):
            if prm.bc1[i] == 10: i1[i] = prm.npml
            if prm.bc2[i] == 10: i2[i] = prm.nn[i] - prm.npml + 1
            if i1[i] > i2[i]: sys.exit( 'Error: model too small for PML' )
    prm.i1pml = tuple( i1 )
    prm.i2pml = tuple( i2 )

    # I/O sequence
    fieldio = []
    for line in prm.fieldio:
        line = list( line )
        filename = '-'
        tfunc, val, period = 'const', 1.0, 1.0
        x1 = x2 = 0., 0., 0.
        op = line[0][0]
        mode = line[0][1:]
        if op not in '=+': sys.exit( 'Error: unsupported operator: %r' % line )
        try:
            if len(line) is 10:
                tfunc, period, x1, x2, nb, ii, field, filename, val               = line[1:]
            elif mode in [ '', 's']:        field, ii, val                        = line[1:]
            elif mode in [ 'x', 'sx']:      field, ii, val, x1                    = line[1:]
            elif mode in [ 'c' ]:           field, ii, val, x1, x2                = line[1:]
            elif mode in [ 'f', 'fs' ]:     field, ii, val, tfunc, period         = line[1:]
            elif mode in [ 'fx', 'fsx' ]:   field, ii, val, tfunc, period, x1     = line[1:]
            elif mode in [ 'fc' ]:          field, ii, val, tfunc, period, x1, x2 = line[1:]
            elif mode in [ 'r', 'R', 'w' ]: field, ii, filename                   = line[1:]
            elif mode in [ 'rx', 'wx' ]:    field, ii, filename, x1               = line[1:]
            else: sys.exit( 'Error: bad i/o mode: %r' % line )
        except:
            sys.exit( 'Error: bad i/o spec: %r' % line )
        filename = os.path.expanduser( filename )
        mode = mode.replace( 'f', '' )
        if field not in fieldnames.all:
            sys.exit( 'Error: unknown field: %r' % line )
        if prm.faultnormal == 0 and field in fieldnames.fault:
            sys.exit( 'Error: field only for ruptures: %r' % line )
        if 'w' not in mode and field not in fieldnames.input:
            sys.exit( 'Error: field is ouput only: %r' % line )
        nn = list( prm.nn ) + [ prm.nt ]
        if field in fieldnames.cell:
            mode = mode.replace( 'x', 'X' )
            mode = mode.replace( 'c', 'C' )
            base = 1.5
        else:
            base = 1
        ii = ( util.expand_indices( ii[:3], prm.nn, base )
             + util.expand_indices( ii[3:], [prm.nt], 1 ) )
        if field in fieldnames.initial:
            ii[3] = 0, 0, 1
        if field in fieldnames.fault:
            i = prm.faultnormal - 1
            ii[i] = 2 * ( prm.irup, ) + ( 1, )
        nn = [ ( ii[i][1] - ii[i][0] + 1 ) / ii[i][2] for i in range(4) ]
        nb = ( min( prm.itio, prm.nt ) - 1 ) / ii[3][2] + 1
        nb = max( 1, min( nb, nn[3] ) )
        if 'x' not in mode and 'X' not in mode:
            n = nn[0] * nn[1] * nn[2]
            if n > ( prm.nn[0] + prm.nn[1] + prm.nn[2] ) ** 2:
                nb = 1
            elif n > 1:
                nb = min( nb, itbuff )
        fieldio += [( op+mode, tfunc, period, x1, x2, nb, ii, field, filename, val )]
    f = [ line[8] for line in fieldio if line[8] != '-' ]
    for i in range( len( f ) ):
        if f[i] in f[:i]:
            sys.exit( 'Error: duplicate filename: %r' % f[i] )
    prm.fieldio = fieldio
    return prm

def launch( cfg ):
    """Launch or queue job."""
    import os, sys
    cwd = os.getcwd()
    if cfg.run == 'q':
        os.chdir( cfg.rundir )
        print( 'queue.sh' )
        if cfg.host not in cfg.hosts:
            sys.exit( 'Error: hostname %r does not match configuration %r' % ( cfg.host, cfg.machine ) )
        if os.system( os.path.join( '.', 'queue.sh' ) ):
            sys.exit( 'Error queing job' )
    elif cfg.run:
        os.chdir( cfg.rundir )
        print( 'run.sh -' + cfg.run )
        if cfg.host not in cfg.hosts:
            sys.exit( 'Error: hostname %r does not match configuration %r' % ( cfg.host, cfg.machine ) )
        if os.system( os.path.join( '.', 'run.sh -' + cfg.run ) ):
            sys.exit( 'Error running job' )
    os.chdir( cwd )
    return

def run( inputs ):
    """Combined stage and launch in one step."""
    cfg = stage( inputs )
    launch( cfg )
    return cfg

