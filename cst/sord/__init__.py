"""
Support Operator Rupture Dynamics
"""

difference_operators = [
    'auto',
    'cons',
    'rect',
    'para',
    'quad',
    'exac',
    'save',
]

boundary_conditions = {
    'free': 0,
    'rigid': 3,
    '+node': 1,
    '+cell': 2, 
    '-node': -1,
    '-cell': -2, 
    'pml': 10,
}

time_functions = [
    'const',
    'delta',
    'step', 'integral_delta',
    'brune',
    'integral_brune',
    'hann',
    'integral_hann',
    'gaussian', 'integral_ricker1',
    'ricker1', 'integral_ricker2',
    'ricker2',
]

def parameters():
    import os, yaml
    from .. import util
    x = os.path.dirname(__file__)
    x = os.path.join(x, 'parameters.yaml')
    x = open(x).read()
    x = yaml.safe_load(x)
    x = util.storage(**x)
    return x

def fieldnames():
    import os, yaml
    x = os.path.dirname(__file__)
    x = os.path.join(x, 'fieldnames.yaml')
    x = open(x).read()
    x = yaml.safe_load(x)
    return x

def f90modules(path):
    mods = set()
    deps = set()
    for line in open(path):
        tok = line.split()
        if tok:
            if tok[0] == 'module':
                mods.update(tok[1:])
            elif tok[0] == 'use':
                deps.update(tok[1:])
    return list(mods), list(deps)

def configure(force=False):
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
            'thread_single.f90',
            'thread_omp.f90',
            'process_serial.f90',
            'process_mpi.f90',
            'input_output.f90',
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
                rules += [o + ': ' + s + '\n	$(CC) $(CFLAGS) -c $<']
            elif ext == '.f90':
                d = f90modules(s)[1]
                d = [s] + [k + '.mod' for k in d if k != 'mpi']
                d = ' \\\n        '.join(d)
                rules += [o + ': ' + d + '\n	$(FC) $(FFLAGS) -c $<']
            else:
                raise Exception
            if 'process' not in o and 'thread' not in o:
                objects.append(o)
        objects = ' \\\n        '.join(objects)
        rules = '	\n\n'.join(rules)

        # makefile
        host, machine = util.hostname()
        m = open('Makefile.in').read()
        m = m.format(machine=machine, objects=objects, rules=rules)
        open('Makefile', 'w').write(m)

    # finished
    os.chdir(cwd)

    return


def make(force=False):
    """
    Build SORD code.
    """
    import os, yaml, subprocess
    configure(force)
    p = os.path.dirname(__file__) + os.sep
    if force:
        subprocess.check_call(['make', '-C', p, 'clean'])
    subprocess.check_call(['make', '-C', p, '-j', '4'])
    cfg = yaml.safe_load(open(p + 'config.json'))
    return cfg


def prepare_param(prm, fio):
    """
    Prepare input parameters
    """
    import os

    # checks
    assert(prm['source'] in ('potency', 'moment', 'force', 'none'))
    assert(prm['faultnormal'] in ('none', '-x', '-y', '-z', '+x', '+y', '+z'))

    # intervals
    nx, ny, nz, nt = shape = prm['shape']
    prm['itio'] = max(1, min(prm['itio'], nt))

    # rupture
    ifn = prm['faultnormal'][1:]
    if ifn in 'xyz':
        ifn = {'x': 0, 'y': 1, 'z': 2}[ifn]
        for i in 0, 1, 2:
            prm['hypocenter'][i] %= shape[i]
            assert(prm['hypocenter'][i] <= shape[i] - 1)
        irup = int(prm['hypocenter'][ifn])
        if irup == 0:
            prm['bc1'][ifn] = '-cell'
        if irup == shape[ifn] - 2:
            prm['bc2'][ifn] = '-cell'

    # pml
    i1 = [0, 0, 0]
    i2 = [nx, ny, nz]
    if prm['npml'] > 0:
        for i in 0, 1, 2:
            if prm['bc1'][i] == 'pml':
                i1[i] += prm['npml']
            if prm['bc2'][i] == 'pml':
                i2[i] -= prm['npml']
            if i1[i] >= i2[i]:
                raise Exception('Error: model too small for PML')
    prm.update({'i1pml': i1, 'i2pml': i2})

    # convert boundary conditions to numeric ids
    for k in 'bc1', 'bc2':
        for i in 0, 1, 2:
            if isinstance(prm[k][i], basestring):
                prm[k][i] = boundary_conditions[prm[k][i]]

    # field i/o
    fns = fieldnames()
    fio_ = []
    filenames = []
    shapes = {}
    deltas = {}
    indices = {}
    for field, ios in sorted(fio.items()):
        tags = fns[field][0]
        reg = tags[0]
        input_ = '<' in tags
        static = '~' not in tags
        nx, ny, nz, nt = prm['shape']
        it1, it2 = nt + 1, -1
        if reg == 'c':
            shape = [nx - 1, ny - 1, nz - 1]
        else:
            shape = [nz, ny, nz]
        if reg == 'f':
            del(shape[ifn])
        if not static:
            shape += [nt]
        if type(ios) in (float, int):
            ios = [ios]
        elif len(ios) > 1 and isinstance(ios[1], basestring):
            ios = [ios]
        ios_ = []
        for io in ios:
            fname, val, tau = 'const', 0.0, 0.0
            x1, x2 = [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]
            if type(io) in (float, int):
                slices, op, rhs = [], '=', [io]
            else:
                slices, op, rhs = io[0], io[1], io[2:]
            if op == '#':
                pass
            elif op in ['.', '=', '+', '*', '=~', '+~', '*~']:
                if len(rhs) == 1:
                    val, = rhs
                else:
                    val, fname, tau = rhs
            elif op in ['=@', '+@', '*@']:
                if len(rhs) == 3:
                    x1, x2, val = rhs
                else:
                    x1, x2, val, fname, tau = rhs
            elif op in ['.<', '=<', '+<', '*<', '.>', '=>']:
                fname, = rhs
                if fname in filenames:
                    raise Exception('Error: duplicate filename: ' + fname)
                filenames.append(fname)
                fname = os.path.expanduser(fname)
            else:
                raise Exception('Error: bad i/o operation: %r' % io)

            # error check
            if len(fname) > 32:
                raise Exception('File/function name too long: ' + fname)
            if '>' not in op and not input_:
                raise Exception('Error: field is ouput only: %r' % field)
            if prm['faultnormal'] == 'none' and reg == 'f':
                raise Exception('Error: field only for ruptures: %r' % field)

            # slices
            slices = expand_slices(shape, slices)
            if reg == 'f':
                slices.insert(ifn, [irup, irup+1, 1])
            if static:
                slices.append([-1, 0, 1])
            if '.' in op:
                for i in 0, 1, 2:
                    x1[i] = slices[i][0]
                    assert(x1[i] <= shape[i] - 1)
                    slices[i][0] = int(slices[i][0])
                    slices[i][1] = int(slices[i][1])
            it1 = min(it1, slices[-1][0])
            it2 = max(it2, slices[-1][1])

            # buffer size
            nn = [(i[1] - i[0] - 1) // i[2] + 1 for i in slices]
            nb = (min(prm['itio'], nt) - 1) // slices[3][2] + 1
            nb = max(1, min(nb, nn[3]))
            n = nn[0] * nn[1] * nn[2]
            if n > (nx + ny + nz) ** 2:
                nb = 1
            elif n > 1:
                nb = min(nb, prm['itbuff'])

            # append to list
            #s = '[' + ','.join('%s:%s:%s' % tuple(s) for s in slices) + ']'
            ios_ += [[field, reg, slices, nb, x1, x2, val, tau, op, fname]]

            # metadata
            if op[-1] in '<>':
                ii = []
                nn = []
                dd = []
                for i, s in enumerate(slices):
                    start, stop, step = s
                    d = prm['delta'][i] * step
                    n = (stop - start - 1) // step + 1
                    if n == 1:
                        ii += [start]
                    else:
                        dd += [d]
                        nn += [n]
                        if step == 1:
                            ii += [[start, stop]]
                        else:
                            ii += [[start, stop, step]]
                if nn != []:
                    shapes[fname] = nn
                if dd != []:
                    deltas[fname] = dd
                if '.' in op:
                    indices[fname] = x1
                else:
                    indices[fname] = ii

        fio_ += [(it1, it2, ios_)]

    # done
    fio_ = [g for f in sorted(fio_) for g in f[2]]
    del(prm['itbuff'])
    prm.update({'nfieldio': len(fio_)})
    meta = {
        'indices': indices,
        'deltas': deltas,
        'shapes': shapes,
    }
    return prm, fio_, meta

def run(args=None, **kwargs):
    """
    Stage and launch job.
    """
    import os, json, shutil
    import numpy as np
    from .. import util

    print('SORD: Support Operator Rupture Dynamics')

    # arguments
    if args == None:
        args = {}
    args.update(kwargs)

    # configure and make
    prm = parameters()
    fns = fieldnames()
    fio = {}
    job = {}
    for k, v in prm.items():
        if k in fns:
            fio[k] = v
            del(prm[k])
    for k, v in args.items():
        if k in fns:
            if type(v) != list:
                v = [v]
            elif len(v) > 1 and isinstance(v[1], basestring):
                v = [v]
            for i, io in enumerate(v):
                if type(io) in (tuple, list):
                    ii = repr_slices(io[0])
                    io = [ii] + list(io[1:])
                    v[i] = io
            if len(v) == 1:
                v = v[0]
            args[k] = v
            fio[k] = v
        elif k in prm:
            prm[k] = v
        else:
            job[k] = v

    cfg = make() # process thread realsize
    prm, fio, meta = prepare_param(prm, fio)

    job = {}
    job['name'] = 'sord'
    job['executable'] = os.path.join('.', 'sord.x')
    if cfg['process'] == 'serial':
        job['execute'] = job['executable']

    # partition for parallelization
    nx, ny, nz, nt = prm['shape']
    j, k, l = prm['nproc3']
    nl = [
        (nx - 1) // j + 1,
        (ny - 1) // k + 1,
        (nz - 1) // l + 1,
    ]
    i = prm['faultnormal'][1:]
    i = {'one': None, 'x': 0, 'y': 1, 'z': 2}[i]
    if i:
        nl[i] = max(nl[i], 2)
    j = (nx - 1) // nl[0] + 1
    k = (ny - 1) // nl[1] + 1
    l = (nz - 1) // nl[2] + 1
    prm['nproc3'] = [j, k, l]
    job['nproc'] = n = j * k * l
    if cfg['process'] == 'serial' and n > 1:
        raise('MPI build required for multiprocessing') 

    # resources
    if prm['diffop'] in ('cons', 'rect'):
        nvars = 20
    elif prm['diffop'] in ('para', 'quad', 'exac'):
        nvars = 23
    else:
        nvars = 44
    nb = int(cfg['realsize'])
    nm = (nl[0] + 2) * (nl[1] + 2) * (nl[2] + 2)
    job['pmem'] = (1 + nm * nvars * nb // 30000) * 32
    m = (1 + (nt + 10) * nm // 420000000) * 10
    if m > 60:
        m = (1 + (nt + 10) * nm // 70000000) * 60
    job['minutes'] = m

    # configure and stage
    job = util.prepare(**job)
    prm.update({'nthread': job['nthread']})

    # create run files 
    d = os.path.dirname(__file__)
    f = os.path.join(d, 'sord.x')
    shutil.copy2(f, '.')
    if prm['debug'] > 2:
        os.mkdir('debug')

    # fortran parameters
    out = [prm[k] for k in sorted(prm)]
    out = json.dumps(out) + '\n'
    for i in fio:
        out += json.dumps(i) + '\n'
    for i in '",[]':
        out = out.replace(i, '')
    open('sord.in', 'w').write(out)

    # save parametes
    prm.update({'~fieldio': fio})
    meta.update({'dtype': np.dtype('f' +  cfg['realsize']).str})
    out = json.dumps(args, sort_keys=True, indent=4)
    open('parameters.json', 'w').write(out)
    out = json.dumps(job, sort_keys=True, indent=4)
    open('job.json', 'w').write(out)
    out = json.dumps(prm, sort_keys=True, indent=4)
    open('sord.json', 'w').write(out)
    out = json.dumps(meta, sort_keys=True, indent=4)
    open('meta.json', 'w').write(out)

    # save archive and start job
    util.archive('coseis.tgz')
    util.launch(job)

    return job

class get_slices:
    def __getitem__(self, slices):
        return slices
s_ = get_slices()

def repr_slices(slices):
    """
    String representation of slice object
    """
    if isinstance(slices, basestring):
        return slices
    elif type(slices) in (tuple, list):
        slices = list(slices)
    else:
        slices = [slices]
    for i, s in enumerate(slices):
        if type(s) in (tuple, list):
            if len(s) == 0:
                s = slice(None)
            else:
                s = slice(*s)
        if type(s) == slice:
            if s.step in (1, None):
                s = '%s:%s' % (s.start, s.stop)
            else:
                s = '%s:%s:%s' % (s.start, s.stop, s.step)
            s = s.replace('None', '')
        else:
            s = str(s)
        slices[i] = s
    slices = '[' + ','.join(slices) + ']'
    return slices

def expand_slices(shape, slices=[]):
    """
    >>> shape = [8, 8, 8, 8]

    >>> expand_slices(shape, [])
    [[0, 8, 1], [0, 8, 1], [0, 8, 1], [0, 8, 1]]

    >>> expand_slices(shape, '[0,:-4,-4:,:]')
    [[0, 1, 1], [0, 4, 1], [4, 8, 1], [0, 8, 1]]
    """

    # normalize to list
    if isinstance(slices, basestring):
        assert(slices[0] + slices[-1] == '[]')
        if slices == '[]':
            slices = []
        else:
            slices = slices[1:-1].split(',')
    elif type(slices) in (tuple, list):
        slices = list(slices)
    else:
        slices = [slices]

    # prep
    n = len(shape)
    if len(slices) == 0:
        slices = n * [[]]
    elif len(slices) != n:
        raise Exception('error in indices: %r' % (slices,))

    # loop over slices
    for i, s in enumerate(slices):
        if isinstance(s, basestring):
            t = []
            for j in s.split(':'):
                if j == '':
                    t.append(None)
                elif '.' in j:
                    t.append(float(j))
                else:
                    t.append(int(j))
            s = t
        if type(s) in (tuple, list):
            if len(s) == 0:
                s = slice(None)
            elif len(s) == 1:
                s = s[0]
            else:
                s = slice(*s)
        if type(s) == slice:
            s = list(s.indices(shape[i]))
        else:
            s %= shape[i]
            s = [s, s + 1, 1]
        slices[i] = s

    return slices

