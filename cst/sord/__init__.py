"""
Support Operator Rupture Dynamics
"""
from ..util import launch, storage
from . import fieldnames
from . import parameters as parameters_default
launch # silence pyflakes warning

def parameters():
    d = parameters_default.__dict__
    d = {k: d[k] for k in d if not k.startswith('_')}
    return storage(**d)

class get_slices:
    def __getitem__(self, item):
        return item
s_ = get_slices()

def configure(job=None, force=False, **kwargs):
    """
    Create SORD Makefile.
    """
    import os
    from .. import util

    # source directory
    cwd = os.getcwd()
    path = os.path.dirname(__file__)
    os.chdir(path)

    # makefile
    if force or not os.path.exists('Makefile'):

        # source files
        sources = [
            'globals.f90',
            'kernels.f90',
            'diff_cn_op.f90',
            'diff_nc_op.f90',
            'hourglass_op.f90',
            'boundary_cond.f90',
            'surf_normals.f90',
            'utilities.f90',
            'arrays.f90',
            'fortran_io.f90',
            'collective_serial.f90',
            'collective_mpi.f90',
            'field_io_mod.f90',
            'parameters.f90',
            'statistics.f90',
            'setup.f90',
            'grid_generation.f90',
            'material_model.f90',
            'boundary_pml.f90',
            'kinematic_source.f90',
            'material_resample.f90',
            'time_integration.f90',
            'stress.f90',
            'dynamic_rupture.f90',
            'acceleration.f90',
            'sord.f90',
        ]

        # rules
        rules = []
        objects = []
        for s in sources[::-1]:
            base, ext = os.path.splitext(s)
            o = base + '.o'
            if ext == '.c':
                rules += [o + ' : ' + s + '\n	$(CC) $(CFLAGS) -c $<']
            elif ext == '.f90':
                d = util.f90modules(s)[1]
                d = [s] + [k + '.mod' for k in d if k != 'mpi']
                d = ' \\\n        '.join(d)
                rules += [o + ' : ' + d + '\n	$(FC) $(FFLAGS) -c $<']
            else:
                raise Exception
            if 'collective' not in o:
                objects.append(o)
        objects = ' \\\n        '.join(objects)
        rules = '	\n\n'.join(rules)

        # makefile
        if job == None:
            job = util.configure(options=[], **kwargs)
        p = 'conf' + os.path.sep
        try:
            local = open(p + job.machine + '.mk').read()
        except:
            local = open(p + 'GCC.mk').read()
        m = open(p + 'base.mk').read()
        m = m.format(local=local, objects=objects, rules=rules)
        m = '# This Makefile is auto-generated and will be overwritten.\n\n' + m
        open('Makefile', 'w').write(m)

    # finished
    os.chdir(cwd)

    return

def make(job=None, **kwargs):
    """
    Build SORD code.
    """
    import os, subprocess
    configure(job, **kwargs)
    p = os.path.dirname(__file__)
    subprocess.check_call(['make', '-j', '4', '-C', p])
    return

def stage(prm, **kwargs):
    """
    Stage job
    """
    import os, re, shutil
    from .. import util

    print('\nSORD: Support Operator Rupture Dynamics')

    # old-style parameters
    if type(prm) == dict:
        import numpy
        keep_types = (
            [type(None), bool, str, unicode, int, long, float, tuple, list, dict] +
            numpy.typeDict.values()
        )
        print('Warning: using old-style parameters')
        grep = re.compile('(^_)|(_$)|(^.$)|(^..$)')
        prm_ = parameters()
        kwargs_ = {}
        for k in prm:
            if grep.search(k):
                continue
            if type(prm[k]) not in keep_types:
                continue
            if k in prm_:
                prm_[k] = prm[k]
            else:
                kwargs_[k] = prm[k]
        kwargs_.update(kwargs)
        prm, kwargs = prm_, kwargs_
    else:
        prm = util.storage(**prm)

    # prepare parameters
    prm = prepare_param(prm)
    job = util.configure(**kwargs)

    # partition for parallelization
    nx, ny, nz = prm.shape[:3]
    j, k, l = prm.nproc3
    if not job.build_mpi:
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

    # resources
    if prm.oplevel in (1, 2):
        nvars = 20
    elif prm.oplevel in (3, 4, 5):
        nvars = 23
    else:
        nvars = 44
    nm = (nl[0] + 2) * (nl[1] + 2) * (nl[2] + 2)
    job.pmem = 32 + int(1.2 * nm * nvars * int(job.dtype[-1]) / 1024 / 1024)
    if not job.minutes:
        job.minutes = 10 + int((prm.shape[3] + 10) * nm // (40 * job.rate))

    # configure and build
    job.command = os.path.join('.', 'sord.x')
    job = util.prepare(job)
    path = job.rundir + os.sep
    make(job)

    # check for previous run
    if os.path.exists(path + 'parameters.json'):
        raise Exception('Previous run found in %s' % path)

    # create run scripts 
    util.skeleton(job)
    util.archive(path + 'coseis.tgz')
    d = os.path.dirname(__file__)
    f = os.path.join(d, 'sord.x')
    shutil.copy2(f, path)
    if prm.debug > 2:
        os.mkdir(path + 'debug')

    # save input parameters
    f = util.dumps(prm, expand=['fieldio'])
    open(path + 'parameters.json', 'w').write(f)

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
    m = [
        ('# configuration', None),
        ('name',    job.name),
        ('rundate', job.rundate),
        ('machine', job.machine),
        ('host',    job.host),
        ('rundir',  job.rundir),
        ('dtype',   job.dtype),
        ('# model parameters', None),
    ] + sorted(i for i in prm.items() if i[0] != 'fieldio') + [
        ('fieldio', prm.fieldio),
        ('# output dimensions', None),
        ('shapes',  shapes),
        ('deltas',  deltas),
        ('xis',     xis),
        ('indices', indices),
    ]
    m = util.dumps(m, expand=['fieldio', 'shapes', 'deltas', 'xis', 'indices'])
    open(path + 'meta.json', 'w').write(m)

    return job

def run(prm, **kwargs):
    """
    Stage and launch job.
    """
    from .. import util
    job = stage(prm, **kwargs)
    util.launch(job)
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
            if field not in fieldnames.all_:
                raise Exception('Error: unknown field: %r' % line)
            if field not in fieldnames.input_ and 'w' not in mode:
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
    del(prm['itbuff'])
    return prm

def test_fieldnames():
    f = fieldnames.all
    for i in range(len(f)):
        if f[i] in f[:i]:
            print('Error: duplicate field: %r' % f[i])

