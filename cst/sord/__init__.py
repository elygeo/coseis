"""
Support Operator Rupture Dynamics
"""
from ..util import launch, storage
from .. import conf
from . import fieldnames
from . import parameters as parameters_default

def parameters():
    return storage(**parameters_default.__dict__)

class get_slices:
    def __getitem__(self, item):
        return item
s_ = get_slices()

def build(job=None):
    """
    Build SORD code.
    """
    import os, shlex
    import numpy as np
    from .. import util

    # configure
    if job == None:
        job = util.storage(**conf.__dict__)
    if not job.mode:
        job.mode = 'sm'
    dtype = np.dtype(job.dtype).str
    dsize = dtype[-1]
    new = False

    # setup build directory
    path = os.path.dirname(__file__)
    src = os.path.join(path, 'src')
    bld = os.path.realpath(os.path.join(path, '..', 'build')) + os.sep
    cwd = os.getcwd()
    os.chdir(src)
    if not os.path.isdir(bld):
        os.mkdir(bld)

    # source files
    base = [
        'globals.f90',
        'diffcn.f90',
        'diffnc.f90',
        'hourglass.f90',
        'bc.f90',
        'surfnormals.f90',
        'util.f90',
        'fio.f90',
    ]
    common = [
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
    ]

    # serial compile
    if 's' in job.mode:
        source = base + ['serial.f90'] + common
        for opt in job.optimize:
            object_ = bld + 'sord-s' + opt + dsize
            cmd = (
                [job.fortran_serial] +
                shlex.split(job.fortran_flags['f']) +
                shlex.split(job.fortran_flags[opt])
            )
            if dtype != job.dtype_f:
                cmd += shlex.split(job.fortran_flags[dsize])
            new |= util.make(cmd + ['-o'], object_, source)

    # mpi compile
    if 'm' in job.mode and job.fortran_mpi:
        source = base + ['mpi.f90'] + common
        for opt in job.optimize:
            object_ = bld + 'sord-m' + opt + dsize
            cmd = (
                [job.fortran_mpi] +
                shlex.split(job.fortran_flags['f']) +
                shlex.split(job.fortran_flags[opt])
            )
            if dtype != job.dtype_f:
                cmd += shlex.split(job.fortran_flags[dsize])
            new |= util.make(cmd + ['-o'], object_, source)

    # archive source code
    if new:
        util.archive()

    # finished
    os.chdir(cwd)
    return

def stage(prm, **kwargs):
    """
    Stage job
    """
    import os, glob, shutil, pprint
    from .. import util, conf

    print('\nSORD setup')

    # old-style dictionary parameters
    if type(prm) == dict:
        print('Warning: using old-style parameters')
        kwargs = util.prune(prm.copy(), '(^_)|(_$)|(^.$)|(^..$)').update(kwargs)
        prm = parameters()
        for k in kwargs:
            if k in prm:
                prm[k] = kwargs[k]
                del(kwargs[k])

    # job configuration
    job, kwargs = util.configure(conf, **kwargs)
    if kwargs:
        print('Unknown parameters:')
        pprint.pprint(kwargs)
        raise Exception

    prm = prepare_param(prm)

    # partition for parallelization
    nx, ny, nz = prm.shape[:3]
    n = job.maxnodes * job.maxcores
    if not job.mode and n == 1:
        job.mode = 's'
    j, k, l = prm.nproc3
    if job.mode == 's':
        j, k, l = 1, 1, 1
    nl = [
        (nx - 1) // j + 1,
        (ny - 1) // k + 1,
        (nz - 1) // l + 1,
    ]
    i = abs(prm.faultnormal) - 1
    if i >= 0:
        nl[i] = max(nl[i], 2)
    j = (nx - 1) // nl[0] + 1
    k = (ny - 1) // nl[1] + 1
    l = (nz - 1) // nl[2] + 1
    prm.nproc3 = j, k, l
    job.nproc = j * k * l
    if not job.mode:
        job.mode = 's'
        if job.nproc > 1:
            job.mode = 'm'

    # resources
    if prm.oplevel in (1, 2):
        nvars = 20
    elif prm.oplevel in (3, 4, 5):
        nvars = 23
    else:
        nvars = 44
    nm = (nl[0] + 2) * (nl[1] + 2) * (nl[2] + 2)
    job.pmem = 32 + int(1.2 * nm * nvars * int(job.dtype[-1]) / 1024 / 1024)
    job.seconds = (prm.shape[3] + 10) * nm / job.rate

    # configure options
    job.command = os.path.join('.', 'sord-' + job.mode + job.optimize + job.dtype[-1])
    job = util.prepare(job)

    # compile code
    if not job.prepare:
        return job
    _build(job)

    # create run directory
    path = os.path.dirname(__file__)
    stagein = os.path.join(path, '..', 'build', job.command),
    f = os.path.join(path, '..', 'build', 'coseis.tgz')
    if os.path.isfile(f):
        stagein += f,
    if job.optimize == 'g':
        for f in glob.glob(path + '/src/*.f90'):
            stagein += f,
    if prm.debug > 2:
        stagein += 'debug/',
    if prm.itcheck != 0:
        stagein += 'checkpoint/',
    stagein += 'prof/', 'stats/'
    stagein += tuple(job.stagein)
    if job.force == True and os.path.isdir(job.rundir):
        shutil.rmtree(job.rundir)
    util.skeleton(job, stagein)

    # conf, parameter files
    cwd = os.path.realpath(os.getcwd())
    os.chdir(job.rundir)
    delattr(prm, 'itbuff')
    util.save('parameters.py', prm, expand=['fieldio'], header='# modelXX parameters\n')
    util.save('conf.py', job, header = '# configuration\n')

    # metadata
    xis = {}
    indices = {}
    shapes = {}
    deltas = {}
    for f in prm.fieldio:
        op, k = f[0], f[8]
        if k != '-':
            if 'wi' in op:
                xis[k] = f[4]
            indices[k] = f[7]
            shapes[k] = []
            deltas[k] = []
            for i, ii in enumerate(indices[k]):
                n = (ii[1] - ii[0]) // ii[2] + 1
                d = prm.delta[i] * ii[2]
                if n > 1:
                    shapes[k] += [n]
                    deltas[k] += [d]
            if shapes[k] == []:
                shapes[k] = [1]

    # save metadata
    meta = util.save(None,
        job,
        header = '# configuration\n',
        keep=['name', 'rundate', 'rundir', 'user', 'os_', 'dtype'],
    )
    meta += util.save(None,
        prm,
        header = '\n# model parameters\n',
        expand=['fieldio'],
    )
    meta += util.save(None,
        dict(shapes=shapes, deltas=deltas, xis=xis, indices=indices),
        header = '\n# output dimensions\n',
        expand=['indices', 'shapes', 'deltas', 'xis'],
    )
    open('meta.py', 'w').write(meta)

    # return to initial directory
    os.chdir(cwd)
    job.update(prm)
    return job

def run(prm, **kwargs):
    """
    Stage and launch job.
    """
    job = stage(prm, **kwargs)
    launch(job)
    return job

def expand_slices(shape, slices=[], base=0, new_base=None, round=True):
    """
    >>> shape = 8, 8, 8, 8

    >>> expand_slices(shape, [])
    [(0, 8, 1), (0, 8, 1), (0, 8, 1), (0, 8, 1)]

    >>> expand_slices(shape, [0.4, 0.6, -0.6, -0.4])
    [(0, 1, 1), (1, 2, 1), (7, 8, 1), (8, 9, 1)]

    >>> expand_slices(shape, s_[0.4, 0.6, -0.6:-0.4:2, :])
    [(0, 1, 1), (1, 2, 1), (7, 8, 2), (0, 8, 1)]

    >>> expand_slices(shape, s_[0.9, 1.1, -1.1:-0.9:2, :], base=0.5)
    [(0, 1, 1), (1, 2, 1), (6, 7, 2), (0, 7, 1)]

    >>> expand_slices(shape, s_[1.4, 1.6, -1.6:-1.4:2, :], base=1)
    [(1, 1, 1), (2, 2, 1), (7, 8, 2), (1, 8, 1)]

    >>> expand_slices(shape, s_[1.9, 2.1, -2.1:-1.9:2, :], base=1.5)
    [(1, 1, 1), (2, 2, 1), (6, 7, 2), (1, 7, 1)]

    >>> expand_slices(shape, [0, 1, 2, ()], base=0, new_base=1)
    [(1, 1, 1), (2, 2, 1), (3, 3, 1), (1, 8, 1)]
    """

    # normalize type
    n = len(shape)
    slices = list(slices)
    if len(slices) == 0:
        slices = n * [()]
    elif len(slices) != n:
        raise Exception('error in indices: %r' % (slices,))

    # default no base conversion
    if new_base is None:
        new_base = base

    # loop over slices
    for i, s in enumerate(slices):

        # convert to tuple
        if type(s) == slice:
            s = s.start, s.stop, s.step
        elif type(s) not in (tuple, list):
            s = s,

        # fill missing values
        wraparound = shape[i] + int(base)
        if len(s) == 0:
            s = None, None, 1
        elif len(s) == 1:
            s = s[0]
            if s < 0:
                s += wraparound
            s = s, s + 1 - int(base), 1
        elif len(s) == 2:
            s = s[0], s[1], 1
        elif len(s) != 3:
            raise Exception('error in indices: %r' % (slices,))

        # handle None
        start, stop, step = s
        if start is None:
            start = base
        if stop is None:
            stop = -base + wraparound
        if step is None:
            step = 1

        # handle negative indices
        if start < 0:
            start += wraparound
        if stop < 0:
            stop += wraparound

        # convert base
        if new_base != base:
            r = new_base - base
            start += r
            stop += r - int(r)

        # round and finish
        if round:
            r = new_base - int(new_base)
            start = int(start - r + 0.5)
            stop  = int(stop  - r + 0.5)
        slices[i] = start, stop, step

    return slices

def prepare_param(prm):
    """
    Prepare input parameters
    """
    import os, math

    # checks
    if prm.source not in ('potency', 'moment', 'force', 'none'):
        raise Exception('Error: unknown source type %r' % prm.source)

    # intervals
    nt = prm.shape[3]
    prm.itio = max(1, min(prm.itio, nt))
    if prm.itcheck % prm.itio != 0:
        prm.itcheck = (prm.itcheck // prm.itio + 1) * prm.itio

    # hypocenter coordinates
    nn = prm.shape[:3]
    xi = list(prm.ihypo)
    for i in range(3):
        xi[i] = 0.0 + xi[i]
        if xi[i] == 0.0:
            xi[i] = 0.5 * (nn[i] + 1)
        elif xi[i] <= -1.0:
            xi[i] = xi[i] + nn[i] + 1
        if xi[i] < 1.0 or xi[i] > nn[i]:
            raise Exception('Error: ihypo %s out of bounds' % xi)
    prm.ihypo = tuple(xi)

    # rupture boundary conditions
    nn = prm.shape[:3]
    i1 = list(prm.bc1)
    i2 = list(prm.bc2)
    i = abs(prm.faultnormal) - 1
    if i >= 0:
        irup = int(xi[i])
        if irup == 1:
            i1[i] = -2
        if irup == nn[i] - 1:
            i2[i] = -2
        if irup < 1 or irup > (nn[i] - 1):
            raise Exception('Error: ihypo %s out of bounds' % xi)
    prm.bc1 = tuple(i1)
    prm.bc2 = tuple(i2)

    # pml region
    nn = prm.shape[:3]
    i1 = [0, 0, 0]
    i2 = [nn[0]+1, nn[1]+1, nn[2]+1]
    if prm.npml > 0:
        for i in range(3):
            if prm.bc1[i] == 10:
                i1[i] = prm.npml
            if prm.bc2[i] == 10:
                i2[i] = nn[i] - prm.npml + 1
            if i1[i] > i2[i]:
                raise Exception('Error: model too small for PML')
    prm.i1pml = tuple(i1)
    prm.i2pml = tuple(i2)

    # i/o sequence
    fieldio = []
    for line in prm.fieldio:
        line = list(line)
        filename = '-'
        pulse, val, tau = 'const', 1.0, 1.0
        x1 = x2 = 0.0, 0.0, 0.0

        # parse line
        op = line[0][0]
        mode = line[0][1:]
        if op not in '=+#':
            raise Exception('Error: unsupported operator: %r' % line)
        try:
            if len(line) is 11:
                nc, pulse, tau, x1, x2, nb, ii, filename, val, fields = line[1:]
            elif mode in ['r', 'R', 'w', 'wi']:
                fields, ii, filename = line[1:]
            elif mode in ['', 's', 'i']:
                fields, ii, val = line[1:]
            elif mode in ['f', 'fs', 'fi']:
                fields, ii, val, pulse, tau = line[1:]
            elif mode in ['c']:
                fields, ii, val, x1, x2 = line[1:]
            elif mode in ['fc']:
                fields, ii, val, pulse, tau, x1, x2 = line[1:]
            else:
                raise Exception('Error: bad i/o mode: %r' % line)
        except ValueError:
            print('Error: bad i/o spec: %r' % line)
            raise

        filename = os.path.expanduser(filename)
        mode = mode.replace('f', '')
        if isinstance(fields, basestring):
            fields = [fields]

        # error check
        for field in fields:
            if field not in fieldnames.all:
                raise Exception('Error: unknown field: %r' % line)
            if field not in fieldnames.input and 'w' not in mode:
                raise Exception('Error: field is ouput only: %r' % line)
            if (field in fieldnames.cell) != (fields[0] in fieldnames.cell):
                raise Exception('Error: cannot mix node and cell i/o: %r' % line)
            if field in fieldnames.fault:
                if fields[0] not in fieldnames.fault:
                    raise Exception('Error: cannot mix fault and non-fault i/o: %r' % line)
                if prm.faultnormal == 0:
                    raise Exception('Error: field only for ruptures: %r' % line)

        # cell or node registration
        if field in fieldnames.cell:
            mode = mode.replace('c', 'C')
            base = 1.5
        else:
            base = 1

        # indices
        nn = prm.shape[:3]
        nt = prm.shape[3]
        if 'i' in mode:
            x1 = expand_slices(nn, ii[:3], base, round=False)
            x1 = tuple(i[0] + 1 - base for i in x1)
            i1 = tuple(math.ceil(i) for i in x1)
            ii = (expand_slices(nn, i1, 1)
                 + expand_slices([nt], ii[3:], 1))
        else:
            ii = (expand_slices(nn, ii[:3], base)
                 + expand_slices([nt], ii[3:], 1))
        if field in fieldnames.initial:
            ii[3] = 0, 0, 1
        if field in fieldnames.fault:
            i = abs(prm.faultnormal) - 1
            ii[i] = 2 * (irup,) + (1,)

        # buffer size
        shape = [(i[1] - i[0]) // i[2] + 1 for i in ii]
        nb = (min(prm.itio, nt) - 1) // ii[3][2] + 1
        nb = max(1, min(nb, shape[3]))
        n = shape[0] * shape[1] * shape[2]
        if n > (nn[0] + nn[1] + nn[2]) ** 2:
            nb = 1
        elif n > 1:
            nb = min(nb, prm.itbuff)
        nc = len(fields)

        # append to list
        fieldio += [
            (op + mode, nc, pulse, tau, x1, x2, nb, ii, filename, val, fields)
        ]

    # check for duplicate filename
    f = [line[8] for line in fieldio if line[8] != '-']
    for i in range(len(f)):
        if f[i] in f[:i]:
            raise Exception('Error: duplicate filename: %r' % f[i])

    # done
    prm.fieldio = fieldio
    return prm

def test_fieldnames():
    f = fieldnames.all
    for i in range(len(f)):
        if f[i] in f[:i]:
            print('Error: duplicate field: %r' % f[i])

