"""
Support Operator Rupture Dynamics
"""
from __future__ import division, absolute_import, print_function #unicode_literals
import os, sys, math, glob, shutil, pprint
import numpy as np
from ..conf import launch
from . import fieldnames

path = os.path.realpath( os.path.dirname( __file__ ) )

def _build( mode=None, optimize=None, dtype=None ):
    """
    Build SORD code.
    """
    import cst
    cf = cst.conf.configure()[0]
    if not optimize:
        optimize = cf.optimize
    if not mode:
        mode = cf.mode
    if not mode:
        mode = 'sm'
    if not dtype:
        dtype = cf.dtype
    base = (
        'globals.f90',
        'diffcn.f90',
        'diffnc.f90',
        'hourglass.f90',
        'bc.f90',
        'surfnormals.f90',
        'util.f90',
        'fio.f90',
    )
    common = (
        'arrays.f90',
        'fieldio.f90',
        'stats.f90',
        'parameters.f90',
        'setup.f90',
        'gridgen.f90',
        'material.f90',
        'source.f90',
        'rupture.f90',
        'resample.f90',
        'checkpoint.f90',
        'timestep.f90',
        'stress.f90',
        'acceleration.f90',
        'sord.f90',
    )
    dtype = np.dtype( dtype ).str
    dsize = dtype[-1]
    new = False
    cwd = os.getcwd()
    src = os.path.join( path, 'src' )
    bld = os.path.join( os.path.dirname( path ), 'build' ) + os.sep
    os.chdir( src )
    if not os.path.isdir( bld ):
        os.mkdir( bld )
    if 's' in mode:
        source = base + ('serial.f90',) + common
        for opt in optimize:
            object_ = bld + 'sord-s' + opt + dsize
            fflags = cf.fortran_flags['f'], cf.fortran_flags[opt]
            if dtype != cf.dtype_f:
                fflags = fflags + (cf.fortran_flags[dsize],)
            compiler = (cf.fortran_serial,) + fflags + ('-o',)
            new |= cst.conf.make( compiler, object_, source )
    if 'm' in mode and cf.fortran_mpi[0]:
        source = base + ('mpi.f90',) + common
        for opt in optimize:
            object_ = bld + 'sord-m' + opt + dsize
            fflags = cf.fortran_flags['f'], cf.fortran_flags[opt]
            if dtype != cf.dtype_f:
                fflags = fflags + (cf.fortran_flags[dsize],)
            compiler = (cf.fortran_mpi,) + fflags + ('-o',)
            new |= cst.conf.make( compiler, object_, source )
    if new:
        cst._archive()
    os.chdir( cwd )
    return

def stage( dictargs={}, **kwargs ):
    """
    Stage job
    """
    import cst

    # save start time
    print( 'SORD setup' )

    # update inputs
    inputs = {'name': 'sord'}
    inputs.update( dictargs )
    inputs.update( kwargs )

    # test for depreciated parameters
    depreciated = [
        ('np3', "Parameter 'np3' is renamed to 'nproc3'."),
        ('nn',  "Parameter 'nn' depreciated. Use: shape = nx, ny, nz, nt."),
        ('nt',  "Parameter 'nn' depreciated. Use: shape = nx, ny, nz, nt."),
        ('dx',  "Parameter 'dx' depreciated. Use: delta = dx, dy, dz, dt."),
        ('dt',  "Parameter 'dt' depreciated. Use: delta = dx, dy, dz, dt."),
    ]
    error = None
    for k, msg in depreciated:
        if k in inputs:
            print( msg )
            error = True
    if error:
        sys.exit()

    # configure
    job, inputs = cst.conf.configure( **inputs )
    job.dtype = np.dtype( job.dtype ).str
    if not job.prepare:
        job.run = False
    if job.run == 'g':
        job.optimize = 'g'

    # read parameters
    pm = {}
    f = os.path.join( os.path.dirname( __file__ ), 'parameters.py' )
    exec open( f ) in pm
    cst.util.prune( pm )
    for k, v in inputs.copy().iteritems():
        if k in pm:
            pm[k] = v
            del( inputs[k] )
    if inputs:
        print( 'Unknown parameters:' )
        pprint.pprint( inputs )
        sys.exit()

    pm = cst.util.namespace( pm )
    pm = prepare_param( pm )

    # partition for parallelization
    nx, ny, nz = pm.shape[:3]
    n = job.maxnodes * job.maxcores
    if not job.mode and n == 1:
        job.mode = 's'
    j, k, l = pm.nproc3
    if job.mode == 's':
        j, k, l = 1, 1, 1
    nl = [
        (nx - 1) // j + 1,
        (ny - 1) // k + 1,
        (nz - 1) // l + 1,
    ]
    i = abs( pm.faultnormal ) - 1
    if i >= 0:
        nl[i] = max( nl[i], 2 )
    j = (nx - 1) // nl[0] + 1
    k = (ny - 1) // nl[1] + 1
    l = (nz - 1) // nl[2] + 1
    pm.nproc3 = j, k, l
    job.nproc = j * k * l
    if not job.mode:
        job.mode = 's'
        if job.nproc > 1:
            job.mode = 'm'

    # resources
    if pm.oplevel in (1, 2):
        nvars = 20
    elif pm.oplevel in (3, 4, 5):
        nvars = 23
    else:
        nvars = 44
    nm = (nl[0] + 2) * (nl[1] + 2) * (nl[2] + 2)
    job.pmem = 32 + int(1.2 * nm * nvars * int( job.dtype[-1] ) / 1024 / 1024)
    job.seconds = (pm.shape[3] + 10) * nm / job.rate

    # configure options
    job.command = os.path.join( '.', 'sord-' + job.mode + job.optimize + job.dtype[-1] )
    job = cst.conf.prepare( job )

    # compile code
    if not job.prepare:
        return job
    _build( job.mode, job.optimize, job.dtype )

    # create run directory
    files = os.path.join( cst.path, 'build', job.command ),
    f = os.path.join( cst.path, 'build', 'coseis.tgz' )
    if os.path.isfile( f ):
        files += f,
    if job.optimize == 'g':
        for f in glob.glob( path + '/src/*.f90' ):
            files += f,
    if job.force == True and os.path.isdir( job.rundir ):
        shutil.rmtree( job.rundir )
    cst.conf.skeleton( job, files )

    # conf, parameter files
    cwd = os.path.realpath( os.getcwd() )
    os.chdir( job.rundir )
    for f in 'in', 'out', 'prof', 'stats', 'debug', 'checkpoint':
        os.mkdir( f )
    delattr( pm, 'itbuff' )
    cst.util.save( 'parameters.py', pm, expand=['fieldio'], header='# model parameters\n' )
    cst.util.save( 'conf.py', job, header = '# configuration\n' )

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
                n = (ii[1] - ii[0]) // ii[2] + 1
                d = pm.delta[i] * ii[2]
                if n > 1:
                    shapes[k] += [n]
                    deltas[k] += [d]
            if shapes[k] == []:
                shapes[k] = [1]

    # save metadata
    meta = cst.util.save( None,
        job,
        header = '# configuration\n',
        keep=['name', 'rundate', 'rundir', 'user', 'os_', 'dtype'],
    )
    meta += cst.util.save( None,
        pm,
        header = '\n# model parameters\n',
        expand=['fieldio'],
    )
    meta += cst.util.save( None,
        dict( shapes=shapes, deltas=deltas, xis=xis, indices=indices ),
        header = '\n# output dimensions\n',
        expand=['indices', 'shapes', 'deltas', 'xis'],
    )
    open( 'meta.py', 'w' ).write( meta )

    # return to initial directory
    os.chdir( cwd )
    job.__dict__.update( pm.__dict__ )
    return job

def run( job=None, **kwargs ):
    """
    Stage (if necessary) and launch job
    """
    if job is None:
        job = stage( **kwargs )
    elif type( job ) == dict:
        job.update( kwargs )
        job = stage( job )
    launch( job )
    return job

def prepare_param( pm ):
    """
    Prepare input paramers
    """
    import cst

    # inervals
    nt = pm.shape[3]
    pm.itio = max( 1, min(pm.itio, nt) )
    if pm.itcheck % pm.itio != 0:
        pm.itcheck = (pm.itcheck // pm.itio + 1) * pm.itio

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
        if op not in '=+#':
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
            x1 = cst.util.expand_slice( nn, ii[:3], base, round=False )
            x1 = tuple( i[0] + 1 - base for i in x1 )
            i1 = tuple( math.ceil( i ) for i in x1 )
            ii = ( cst.util.expand_slice( nn, i1, 1 )
                 + cst.util.expand_slice( [nt], ii[3:], 1 ) )
        else:
            ii = ( cst.util.expand_slice( nn, ii[:3], base )
                 + cst.util.expand_slice( [nt], ii[3:], 1 ) )
        if field in fieldnames.initial:
            ii[3] = 0, 0, 1
        if field in fieldnames.fault:
            i = abs( pm.faultnormal ) - 1
            ii[i] = 2 * (irup,) + (1,)
        shape = [ (i[1] - i[0]) // i[2] + 1 for i in ii ]
        nb = ( min( pm.itio, nt ) - 1 ) // ii[3][2] + 1
        nb = max( 1, min( nb, shape[3] ) )
        n = shape[0] * shape[1] * shape[2]
        if n > (nn[0] + nn[1] + nn[2]) ** 2:
            nb = 1
        elif n > 1:
            nb = min( nb, pm.itbuff )
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

