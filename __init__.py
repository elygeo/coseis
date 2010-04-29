#!/usr/bin/env python
"""
Support Operator Rupture Dynamics
"""
import os, sys, re, math
import numpy as np
import fieldnames
import conf
from util import swab, util, coord, signal, source, data, viz, plt, mlab, egmm
try:
    from util import rspectra
except( ImportError ):
    pass

def stage( inputs ):
    """
    Setup, and optionally launch, a SORD job.
    """
    import glob, time, getopt, shutil
    import setup

    # save start time
    starttime = time.asctime()
    print( 'SORD setup' )

    # read defaults
    pm = {}
    f = os.path.join( os.path.dirname( __file__ ), 'parameters.py' )
    exec open( f ) in pm
    if 'machine' in inputs:
        cf = conf.configure( machine=inputs['machine'], module='sord' )
    else:
        cf = conf.configure( module='sord' )

    # test for depreciated variables
    for k, msg in (
        ('np3', "Parameter 'np3' is renamed to 'nproc3'."),
        ('nn',  "Parameter 'nn' discontinued. Use: shape = nx, ny, nz, nt."),
        ('nt',  "Parameter 'nn' discontinued. Use: shape = nx, ny, nz, nt."),
        ('dx',  "Parameter 'dx' discontinued. Use: delta = dx, dy, dz, dt."),
        ('dt',  "Parameter 'dt' discontinued. Use: delta = dx, dy, dz, dt."),
    ):
        if k in inputs:
            sys.exit( msg )

    # merge inputs
    inputs = inputs.copy()
    util.prune( inputs )
    util.prune( pm )
    util.prune( cf, pattern='(^_)|(^.$)|(^..$)' )
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

    # command line options
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
        '8', 'realsize8',
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
        elif o in ('-8', '--realsize8'):
            cf.dtype = 'f8'
        elif o in ('-f', '--force'):
            if os.path.isdir( cf.rundir ):
                shutil.rmtree( cf.rundir )
        else:
            sys.exit( 'Error: unknown option: ' + o )
    if not cf.prepare:
        cf.run = False
    cf.dtype = np.dtype( cf.dtype ).str

    # partition for parallelization
    nx, ny, nz = pm.shape[:3]
    maxtotalcores = cf.maxnodes * cf.maxcores
    if not cf.mode and maxtotalcores == 1:
        cf.mode = 's'
    j, k, l = pm.nproc3
    if cf.mode == 's':
        j, k, l = 1, 1, 1
    nl = [
        (nx - 1) / j + 1,
        (ny - 1) / k + 1,
        (nz - 1) / l + 1,
    ]
    i = abs( pm.faultnormal ) - 1
    if i >= 0:
        nl[i] = max( nl[i], 2 )
    j = (nx - 1) / nl[0] + 1
    k = (ny - 1) / nl[1] + 1
    l = (nz - 1) / nl[2] + 1
    pm.nproc3 = j, k, l
    cf.nproc = j * k * l
    if not cf.mode:
        cf.mode = 's'
        if cf.nproc > 1:
            cf.mode = 'm'

    # resources
    n = conf.parallel( cf.nproc, cf.maxcores, cf.maxnodes )
    cf.nodes, cf.ppn, cf.cores, cf.totalcores = n

    # ram and wall time usage
    if pm.oplevel in (1, 2):
        nvars = 20
    elif pm.oplevel in (3, 4, 5):
        nvars = 23
    else:
        nvars = 44
    nm = (nl[0] + 2) * (nl[1] + 2) * (nl[2] + 2)
    cf.pmem = 32 + int(1.2 * nm * nvars * int( cf.dtype[-1] ) / 1024 / 1024)
    cf.ram = cf.pmem * cf.ppn
    ss = (pm.shape[3] + 10) * cf.ppn * nm / cf.cores / cf.rate
    sus = int( ss / 3600 * cf.totalcores + 1 )
    mm = ss / 60 * 3.0 + 10
    if cf.maxtime:
        mm = min( mm, 60 * cf.maxtime[0] + cf.maxtime[1] )
    hh = mm / 60
    mm = mm % 60
    cf.walltime = '%d:%02d:00' % (hh, mm)
    print( 'Machine: ' + cf.machine )
    print( 'Cores: %s of %s' % (cf.nproc, maxtotalcores) )
    print( 'Nodes: %s of %s' % (cf.nodes, cf.maxnodes) )
    print( 'RAM: %sMb of %sMb per node' % (cf.ram, cf.maxram) )
    print( 'Time limit: ' + cf.walltime )
    print( 'SUs: %s' % sus )
    if cf.maxcores and cf.ppn > cf.maxcores:
        print( 'Warning: exceding available cores per node (%s)' % cf.maxcores )
    if cf.ram and cf.ram > cf.maxram:
        print( 'Warning: exceding available RAM per node (%sMb)' % cf.maxram )

    # compile code
    if not cf.prepare:
        return cf
    setup.build( cf.mode, cf.optimize, cf.dtype )

    # config options
    print( 'Run directory: ' + cf.rundir )
    cf.rundate = time.strftime( '%Y %b %d' )
    cf.rundir = os.path.realpath( cf.rundir )
    cf.bin = os.path.join( '.', 'sord-' + cf.mode + cf.optimize + cf.dtype[-1] )

    # create run directory
    src = os.path.realpath( os.path.dirname( __file__ ) ) + os.sep
    files = os.path.join( src, 'bin', cf.bin ),
    if os.path.isfile( src + 'sord.tgz' ):
        files += src + 'sord.tgz',
    if cf.optimize == 'g':
        for f in glob.glob( os.path.join( 'src', '*.f90' ) ):
            files += f,
    conf.skeleton( cf.__dict__, files )

    # log, conf, parameter files
    cwd = os.path.realpath( os.getcwd() )
    os.chdir( cf.rundir )
    log = open( 'log', 'w' )
    log.write( starttime + ': setup started\n' )
    util.save( 'conf.py', cf, header = '# configuration\n' )
    util.save( 'parameters.py', pm, expand=['fieldio'], header='# model parameters\n' )

    # metadata
    xis = {}
    indices = {}
    shapes = {}
    deltas = {}
    for f in pm.fieldio:
        op, k = f[0], f[8]
        if k != '-':
            if 'wi' in op:
                xis[k] = f[4]
            indices[k] = f[7]
            shapes[k] = []
            deltas[k] = []
            for i, ii in enumerate( indices[k] ):
                n = (ii[1] - ii[0]) / ii[2] + 1
                d = pm.delta[i] * ii[2]
                if n > 1:
                    shapes[k] += [n]
                    deltas[k] += [d]
            if shapes[k] == []:
                shapes[k] = [1]

    # save metadata
    meta = util.save( None,
        cf,
        header = '# configuration\n',
        keep=['name', 'rundate', 'rundir', 'user', 'os_', 'dtype'],
    )
    meta += util.save( None,
        pm,
        header = '\n# model parameters\n',
        expand=['fieldio'],
    )
    meta += util.save( None,
        dict( shapes=shapes, deltas=deltas, xis=xis, indices=indices ),
        header = '\n# file dimensions\n',
        expand=['indices', 'shapes', 'deltas', 'xis'],
    )
    open( 'meta.py', 'w' ).write( meta )

    # return to initial directory
    os.chdir( cwd )
    cf.__dict__.update( pm.__dict__ )
    return cf

def prepare_param( pm, itbuff ):
    """
    Prepare input paramers
    """

    # inervals
    nt = pm.shape[3]
    pm.itio = max( 1, min(pm.itio, nt) )
    if pm.itcheck % pm.itio != 0:
        pm.itcheck = (pm.itcheck / pm.itio + 1) * pm.itio

    # hypocenter coordinates
    nn = pm.shape[:3]
    xi = list( pm.ihypo )
    for i in range( 3 ):
        xi[i] = 0.0 + xi[i]
        if xi[i] == 0.0:
            xi[i] = 0.5 * (nn[i] + 1)
        elif xi[i] <= -1.0:
            xi[i] = xi[i] + nn[i] + 1
        if xi[i] < 1.0 or xi[i] > nn[i]:
            sys.exit( 'Error: ihypo %s out of bounds' % xi )
    pm.ihypo = tuple( xi )

    # rupture boundary conditions
    nn = pm.shape[:3]
    i1 = list( pm.bc1 )
    i2 = list( pm.bc2 )
    i = abs( pm.faultnormal ) - 1
    if i >= 0:
        irup = int( xi[i] )
        if irup == 1:
            i1[i] = -2
        if irup == nn[i] - 1:
            i2[i] = -2
        if irup < 1 or irup > (nn[i] - 1):
            sys.exit( 'Error: ihypo %s out of bounds' % xi )
    pm.bc1 = tuple( i1 )
    pm.bc2 = tuple( i2 )

    # pml region
    nn = pm.shape[:3]
    i1 = [0, 0, 0]
    i2 = [nn[0]+1, nn[1]+1, nn[2]+1]
    if pm.npml > 0:
        for i in range( 3 ):
            if pm.bc1[i] == 10:
                i1[i] = pm.npml
            if pm.bc2[i] == 10:
                i2[i] = nn[i] - pm.npml + 1
            if i1[i] > i2[i]:
                sys.exit( 'Error: model too small for PML' )
    pm.i1pml = tuple( i1 )
    pm.i2pml = tuple( i2 )

    # i/o sequence
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
            if len( line ) is 11:
                nc, tfunc, period, x1, x2, nb, ii, filename, val, fields = line[1:]
            elif mode in ['r', 'R', 'w', 'wi']:
                fields, ii, filename = line[1:]
            elif mode in ['', 's', 'i']:
                fields, ii, val = line[1:]
            elif mode in ['f', 'fs', 'fi']:
                fields, ii, val, tfunc, period = line[1:]
            elif mode in ['c']:
                fields, ii, val, x1, x2 = line[1:]
            elif mode in ['fc']:
                fields, ii, val, tfunc, period, x1, x2 = line[1:]
            else:
                sys.exit( 'Error: bad i/o mode: %r' % line )
        except( ValueError ):
            sys.exit( 'Error: bad i/o spec: %r' % line )
        filename = os.path.expanduser( filename )
        mode = mode.replace( 'f', '' )
        if type( fields ) == str:
            fields = [fields]
        for field in fields:
            if field not in fieldnames.all:
                sys.exit( 'Error: unknown field: %r' % line )
            if field not in fieldnames.input and 'w' not in mode:
                sys.exit( 'Error: field is ouput only: %r' % line )
            if (field in fieldnames.cell) != (fields[0] in fieldnames.cell):
                sys.exit( 'Error: cannot mix node and cell i/o: %r' % line )
            if field in fieldnames.fault:
                if fields[0] not in fieldnames.fault:
                    sys.exit( 'Error: cannot mix fault and non-fault i/o: %r' % line )
                if pm.faultnormal == 0:
                    sys.exit( 'Error: field only for ruptures: %r' % line )
        if field in fieldnames.cell:
            mode = mode.replace( 'c', 'C' )
            base = 1.5
        else:
            base = 1
        nn = pm.shape[:3]
        nt = pm.shape[3]
        if 'i' in mode:
            x1 = util.expand_slice( nn, ii[:3], base, round=False )
            x1 = tuple( i[0] + 1 - base for i in x1 )
            i1 = tuple( math.ceil( i ) for i in x1 )
            ii = ( util.expand_slice( nn, i1, 1 )
                 + util.expand_slice( [nt], ii[3:], 1 ) )
        else:
            ii = ( util.expand_slice( nn, ii[:3], base )
                 + util.expand_slice( [nt], ii[3:], 1 ) )
        if field in fieldnames.initial:
            ii[3] = 0, 0, 1
        if field in fieldnames.fault:
            i = abs( pm.faultnormal ) - 1
            ii[i] = 2 * (irup,) + (1,)
        shape = [ (i[1] - i[0]) / i[2] + 1 for i in ii ]
        nb = ( min( pm.itio, nt ) - 1 ) / ii[3][2] + 1
        nb = max( 1, min( nb, shape[3] ) )
        n = shape[0] * shape[1] * shape[2]
        if n > (nn[0] + nn[1] + nn[2]) ** 2:
            nb = 1
        elif n > 1:
            nb = min( nb, itbuff )
        nc = len( fields )
        fieldio += [
            (op + mode, nc, tfunc, period, x1, x2, nb, ii, filename, val, fields)
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
        if cf.host not in cf.hosts:
            sys.exit( 'Error: hostname %r does not match configuration %r'
                % (cf.host, cf.machine) )
        print( 'bash queue.sh' )
        if os.system( 'bash queue.sh' ):
            sys.exit( 'Error queing job' )
    elif cf.run:
        if cf.host not in cf.hosts:
            sys.exit( 'Error: hostname %r does not match configuration %r'
                % (cf.host, cf.machine) )
        print( 'bash run.sh -' + cf.run )
        if os.system( 'bash run.sh -' + cf.run ):
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

