#!/usr/bin/env python
"""
SORD main module
"""

import os, sys, pwd, glob, time, getopt, shutil
import util, setup, configure, fieldnames
callcount = 0

def run( params, prepare=True, run=False, mode=None, optimize='O', machine=None ):
    """
    Prepare, and optionally launch, a SORD job.

    machine: site specific configuration located in conf/
    params: a dictionary of simulation parameters
    prepare:
        True:  compile code and setup run/ directory
        False: dry run. parameter check only
    run:
        i' run interactively
       'q' que batch job
       'g' run in a debugger
    mode:
       's' serial
       'm' multiprocessor
    optimize:
       'O' fully optimized
       'g' debugging
       't' testing
       'p' profiling
    """

    # Save start time
    starttime = time.asctime()
    print "SORD setup"
    global callcount
    callcount += 1

    # Command line options
    opts, args = getopt.getopt( sys.argv[1:], 'niqsmgGtpOd' )
    for o, v in opts:
        if   o == '-n': prepare = False
        elif o == '-i': run = 'i'
        elif o == '-q': run = 'q'
        elif o == '-s': mode = 's'
        elif o == '-m': mode = 'm'
        elif o == '-g': optimize = 'g'
        elif o == '-G': optimize = 'g'; run = 'g'
        elif o == '-t': optimize = 't'
        elif o == '-p': optimize = 'p'
        elif o == '-O': optimize = 'O'
        elif o == '-d':
            if callcount is 1:
                f = 'run' + os.sep + '[0-9][0-9]'
                for f in glob.glob( f ): shutil.rmtree( f )
        else: sys.exit( 'Error: unknown option: %s %s' % ( o, v ) )
    if not prepare: run = False

    # Configure machine
    if args:
        machine = args[0]
    cfg = util.objectify( configure.configure( False, machine ) )
    print 'Machine: ' + cfg.machine

    # Prepare parameters 
    params = prepare_params( params )

    # Partition for parallelization
    maxcores = cfg.nodes * cfg.cores
    if not mode and maxcores == 1:
        mode = 's'
    np3 = params.np[:]
    if mode == 's':
        np3 = [ 1, 1, 1 ]
    nl = [ ( params.nn[i] - 1 ) / np3[i] + 1 for i in range(3) ]
    i  = abs( params.faultnormal ) - 1
    if i >= 0:
        nl[i] = max( nl[i], 2 )
    np3 = [ ( params.nn[i] - 1 ) / nl[i] + 1 for i in range(3) ]
    params.np = tuple( np3 )
    np = np3[0] * np3[1] * np3[2]
    if not mode:
        mode = 's'
        if np > 1:
            mode = 'm'

    # Resources
    if cfg.cores:
        nodes = min( cfg.nodes, ( np - 1 ) / cfg.cores + 1 )
        ppn = ( np - 1 ) / nodes + 1
        cores = min( cfg.cores, ppn )
        totalcores = nodes * cfg.cores
    else:
        nodes = 1
        ppn = np
        cores = np
        totalcores = np

    # RAM and Wall time usage
    floatsize = 4
    if params.oplevel in (1,2): nvars = 20
    elif params.oplevel in (3,4,5): nvars = 23
    else: nvars = 44
    nm = ( nl[0] + 2 ) * ( nl[1] + 2 ) * ( nl[2] + 2 )
    ramcore = ( nm * nvars * floatsize / 1024 / 1024 + 10 ) * 1.5
    ramnode = ( nm * nvars * floatsize / 1024 / 1024 + 10 ) * ppn
    sus = int( ( params.nt + 10 ) * ppn * nm / cores / cfg.rate / 3600 * nodes * cfg.cores + 1 )
    mm  = ( params.nt + 10 ) * ppn * nm / cores / cfg.rate / 60 * 1.5 + 10
    if cfg.timelimit: mm = min( 60*cfg.timelimit[0] + cfg.timelimit[1], mm )
    hh = mm / 60
    mm = mm % 60
    walltime = '%d:%02d:00' % ( hh, mm )
    print 'Cores: %s of %s' % ( np, maxcores )
    print 'Nodes: %s of %s' % ( nodes, cfg.nodes )
    print 'RAM: %sMb of %sMb per node' % ( ramnode, cfg.ram )
    print 'Time limit: ' + walltime
    print 'SUs: %s' % sus
    if cfg.cores and ppn > cfg.cores:
        print 'Warning: exceding available cores per node (%s)' % cfg.cores
    if cfg.ram and ramnode > cfg.ram:
        print 'Warning: exceding available RAM per node (%sMb)' % cfg.ram

    # Compile code
    if not prepare: return
    setup.build( mode, optimize )

    # Create run directory
    try: os.mkdir( 'run' )
    except: pass
    count = glob.glob( 'run' + os.sep + '[0-9][0-9]' )
    try: count = count[-1].split( os.sep )[-1]
    except: count = 0
    count = '%02d' % ( int( count ) + 1 )
    rundir = 'run' + os.sep + str( count )
    print 'Run directory: ' + rundir
    rundir = os.path.realpath( rundir )
    os.mkdir( rundir )
    for f in ( 'in', 'out', 'prof', 'stats', 'debug', 'checkpoint' ):
        os.mkdir( rundir + os.sep + f )

    # Link input files
    for i, line in enumerate( params.fieldio ):
        if 'r' in line[0] and os.sep in line[3]:
            filename = line[3]
            f = os.path.basename( filename )
            line = line[:3] + ( f, ) + line[4:]
            params.fieldio[i] = line
            f = 'in' + os.sep + filename
            try:
                os.link( filename, rundir + os.sep + f )
            except:
                shutil.copy( filename, rundir + os.sep + f )

    # Template variables
    code = 'sord'
    pre = ''
    bin = './sord-' + mode + optimize
    post = ''
    os_ = os.uname()[3]
    host = os.uname()[1]
    user = pwd.getpwuid(os.geteuid())[0]
    #user = os.getlogin()
    rundate = time.asctime()
    machine = cfg.machine

    # Email address
    cwd = os.path.realpath( os.getcwd() )
    os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )
    if os.path.isfile( 'email' ):
        email = file( 'email', 'r' ).read().strip()
    else:
        #email = os.getlogin()
        email = pwd.getpwuid(os.geteuid())[0]
        file( 'email', 'w' ).write( email )

    # Copy files to run directory
    shutil.copy( 'bin' + os.sep + 'sord-' + mode + optimize, rundir )
    try: shutil.cop( 'sord.tgz', rundir )
    except: pass
    if optimize == 'g':
        for f in glob.glob( 'src/*.f90' ):
            shutil.copy( f, rundir )
    for d in cfg.templates:
        for f in glob.glob( d + os.sep + '*' ):
            ff = rundir + os.sep + os.path.basename( f )
            out = file( f, 'r' ).read() % locals()
            file( ff, 'w' ).write( out )
            shutil.copymode( f, ff )

    # Write parameter file
    os.chdir( rundir )
    log = file( 'log', 'w' )
    log.write( starttime + ': SORD setup started\n' )
    write_params( params )

    # Run or que job
    if run == 'q':
        print 'que.sh'
        if os.uname()[1] not in cfg.hosts:
            sys.exit( 'Error: hostname %r does not match configuration %r' % ( host, machine ) )
        #if subprocess.call( '.' + os.sep + 'que.sh' ):
        if os.system( '.' + os.sep + 'que.sh' ):
            sys.exit( 'Error queing job' )
    elif run:
        print 'run.sh -' + run
        if os.uname()[1] not in cfg.hosts:
            sys.exit( 'Error: hostname %r does not match configuration %r' % ( host, machine ) )
        #if subprocess.call( [ '.' + os.sep + 'run.sh', '-' + run ] ):
        if os.system( '.' + os.sep + 'run.sh -' + run ):
            sys.exit( 'Error running job' )

    # Return to initial directory
    os.chdir( cwd )

def prepare_params( pp ):
    """Prepare input paramers"""

    # max buffer size for 2D slices. should this go in a settings file?
    itbuff = 10

    # merge input parameters with defaults
    f = os.path.dirname( __file__ ) + os.sep + 'defaults.py'
    p = util.load( f )
    for k, v in pp.iteritems():
        if k[0] is not '_' and type(v) is not type(sys):
            if k not in p:
                sys.exit( 'Unknown SORD parameter: %s = %r' % ( k, v ) )
            p[k] = v
    p = util.objectify( p )

    # inervals
    p.itio = max( 1, min( p.itio, p.nt ) )
    if p.itcheck % p.itio != 0:
        p.itcheck = ( p.itcheck / p.itio + 1 ) * p.itio

    # hypocenter node
    ii = list( p.ihypo )
    for i in range( 3 ):
        if ii[i] == 0:
            ii[i] = p.nn[i] / 2
        elif ii[i] < 0:
            ii[i] = ii[i] + p.nn[i] + 1
        if ii[i] < 1 or ii[i] > p.nn[i]:
            sys.exit( 'Error: ihypo %s out of bounds' % ii )
    p.ihypo = tuple( ii )

    # boundary conditions
    i1 = list( p.bc1 )
    i2 = list( p.bc2 )
    i = abs( p.faultnormal ) - 1
    if i >= 0:
        if p.ihypo[i] >= p.nn[i]: sys.exit( 'Error: ihypo %s out of bounds' % ii )
        if p.ihypo[i] == p.nn[i] - 1: i1[i] = -2
        if p.ihypo[i] == 1:           i2[i] = -2
    p.bc1 = tuple( i1 )
    p.bc2 = tuple( i2 )

    # PML region
    i1 = [ 0, 0, 0 ]
    i2 = [ n+1 for n in p.nn ]
    if p.npml > 0:
        for i in range( 3 ):
            if p.bc1[i] == 10: i1[i] = p.npml
            if p.bc2[i] == 10: i2[i] = p.nn[i] - p.npml + 1
            if i1[i] > i2[i]: sys.exit( 'Error: model too small for PML' )
    p.i1pml = tuple( i1 )
    p.i2pml = tuple( i2 )

    # I/O sequence
    fieldio = []
    for line in p.fieldio:
        line = list( line )
        filename = '-'
        tfunc, val, period = 'const', 1.0, 1.0
        x1 = x2 = 0., 0., 0.
        op = line[0][0]
        mode = line[0][1:]
        if op not in '=+': sys.exit( 'Error: unsupported operator: %r' % line )
        try:
            if len(line) is 10:
                tfunc, period, x1, x2, nb, ii, field, filename, val   = line[1:]
            elif mode == '':    field, ii, val                        = line[1:]
            elif mode == 's':   field, ii, val                        = line[1:]
            elif mode == 'x':   field, ii, val, x1                    = line[1:]
            elif mode == 'sx':  field, ii, val, x1                    = line[1:]
            elif mode == 'c':   field, ii, val, x1, x2                = line[1:]
            elif mode == 'f':   field, ii, val, tfunc, period         = line[1:]
            elif mode == 'fs':  field, ii, val, tfunc, period         = line[1:]
            elif mode == 'fx':  field, ii, val, tfunc, period, x1     = line[1:]
            elif mode == 'fsx': field, ii, val, tfunc, period, x1     = line[1:]
            elif mode == 'fc':  field, ii, val, tfunc, period, x1, x2 = line[1:]
            elif mode == 'r':   field, ii, filename                   = line[1:]
            elif mode == 'w':   field, ii, filename                   = line[1:]
            elif mode == 'rx':  field, ii, filename, x1               = line[1:]
            elif mode == 'wx':  field, ii, filename, x1               = line[1:]
            else: sys.exit( 'Error: bad i/o mode: %r' % line )
        except:
            sys.exit( 'Error: bad i/o spec: %r' % line )
        mode = mode.replace( 'f', '' )
        if field not in fieldnames.all:
            sys.exit( 'Error: unknown field: %r' % line )
        if p.faultnormal == 0 and field in fieldnames.fault:
            sys.exit( 'Error: field only for ruptures: %r' % line )
        if 'w' not in mode and field not in fieldnames.input:
            sys.exit( 'Error: field is ouput only: %r' % line )
        if 'r' in mode:
            fn = os.path.dirname( filename ) + os.sep + 'endian'
            if file( fn, 'r' ).read()[0] != sys.byteorder[0]:
                sys.exit( 'Error: wrong byte order for ' + filename )
        if field in fieldnames.cell:
            mode = mode.replace( 'x', 'X' )
            mode = mode.replace( 'c', 'C' )
            nn = [ n-1 for n in p.nn ] + [ p.nt ]
        else:
            nn = list( p.nn ) + [ p.nt ]
        ii = util.indices( ii, nn )
        if field in fieldnames.initial:
            ii[3] = 0, 0, 1
        if field in fieldnames.fault:
            i = p.faultnormal - 1
            ii[i] = 2 * ( p.ihypo[i], ) + ( 1, )
        nn = [ ( ii[i][1] - ii[i][0] + 1 ) / ii[i][2] for i in range(4) ]
        nb = ( min( p.itio, p.nt ) - 1 ) / ii[3][2] + 1
        nb = max( 1, min( nb, nn[3] ) )
        n = nn[0] * nn[1] * nn[2]
        if n > ( p.nn[0] + p.nn[1] + p.nn[2] ) ** 2:
            nb = 1
        elif n > 1:
            nb = min( nb, itbuff )
        fieldio += [( op+mode, tfunc, period, x1, x2, nb, ii, field, filename, val )]
    f = [ line[8] for line in fieldio if line[8] != '-' ]
    for i in range( len( f ) ):
        if f[i] in f[:i]:
            sys.exit( 'Error: duplicate filename: %r' % f[i] )
    p.fieldio = fieldio
    return p

def write_params( params, filename='parameters.py' ):
    """Write input file that will be read by SORD Fortran code"""
    f = file( filename, 'w' )
    f.write( '# Auto-generated SORD input file\n' )
    for k in dir( params ):
        v = getattr( params, k )
        if k[0] is not '_' and k is not 'fieldio' and type(v) is not type(os):
            f.write( '%s = %r\n' % ( k, v ) )
    f.write( 'fieldio = [\n' )
    for line in params.fieldio: f.write( repr( line ) + ',\n' )
    f.write( ']\n' )

