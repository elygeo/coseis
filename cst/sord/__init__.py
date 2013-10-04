"""
Support Operator Rupture Dynamics
"""
from ..util import launch
launch # silence pyflakes warning

def parameters():
    import os, json
    f = os.path.dirname(__file__)
    f = os.path.join(f, 'parameters.json')
    d = json.load(open(f))
    d = {str(k): v for k, v in d.items()}
    return d

def fieldnames():
    import os, json
    f = os.path.dirname(__file__)
    f = os.path.join(f, 'fieldnames.json')
    d = json.load(open(f))
    d = {str(k): v for k, v in d.items()}
    return {
        'dict': d,
        'input':   [k for k in d if '<' in d[k][-1]],
        'initial': [k for k in d if '0' in d[k][-1]],
        'cell':    [k for k in d if 'c' in d[k][-1]],
        'fault':   [k for k in d if 'f' in d[k][-1]],
        'volume':  [k for k in d if 'f' not in d[k][-1]],
    }

tfuncs = [
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

class get_slices:
    def __getitem__(self, item):
        return item
s_ = get_slices()

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
                d = f90modules(s)[1]
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
    import os, json, subprocess
    p = os.path.dirname(__file__) + os.sep
    if force:
        subprocess.check_call(['make', '-C', p, 'distclean'])
    configure(force)
    subprocess.check_call(['make', '-C', p, '-j', '4'])
    cfg = json.load(open(p + 'config.json'))
    return cfg

def stage(args, **kwargs):
    """
    Stage job
    """
    import os, json, shutil
    import numpy as np
    from .. import util

    print('SORD: Support Operator Rupture Dynamics')

    # configure and make
    prm = parameters()
    fld = fieldnames()['dict']
    fio = {}
    cfg = {}
    args.update(kwargs)
    for k, v in prm.items():
        if k in fld:
            fio[k] = v
            del(prm[k])
    for k, v in args.items():
        if k in fld:
            fio[k] = v
        elif k in prm:
            prm[k] = v
        else:
            cfg[k] = v
    cfg = util.configure(**cfg)
    cfg.update(**make())
    if cfg['real8']:
        d = 'd'
    else:
        d = 'f'
    cfg.update({'dtype': np.dtype(d).str})
    prm.update({'nthread': cfg['nthread']})
    prm, fio = prepare_param(prm, fio)

    # partition for parallelization
    nx, ny, nz, nt = prm['shape']
    j, k, l = prm['nproc3']
    nl = [
        (nx - 1) // j + 1,
        (ny - 1) // k + 1,
        (nz - 1) // l + 1,
    ]
    i = abs(prm['faultnormal']) - 1
    if i >= 0:
        nl[i] = max(nl[i], 2)
    j = (nx - 1) // nl[0] + 1
    k = (ny - 1) // nl[1] + 1
    l = (nz - 1) // nl[2] + 1
    prm['nproc3'] = [j, k, l]
    cfg['nproc'] = j * k * l
    if cfg['nproc'] > 1 and cfg['mode'] != 'mpi':
        raise('MPI build required for multiprocessing') 

    # resources
    if prm['oplevel'] in (1, 2):
        nvars = 20
    elif prm['oplevel'] in (3, 4, 5):
        nvars = 23
    else:
        nvars = 44
    nm = (nl[0] + 2) * (nl[1] + 2) * (nl[2] + 2)
    cfg['pmem'] = 32 + int(1.2 * nm * nvars * int(cfg['dtype'][-1]) / 1024 / 1024)
    if not cfg['minutes']:
        cfg['minutes'] = 10 + int((nt + 10) * nm // (40 * cfg['rate']))

    # configure and stage
    cfg['command'] = os.path.join('.', 'sord.x')
    cfg = util.prepare(cfg)
    util.stage(cfg)

    # create run scripts 
    cwd = os.getcwd()
    os.chdir(cfg['rundir'])
    util.archive('coseis.tgz')
    d = os.path.dirname(__file__)
    f = os.path.join(d, 'sord.x')
    shutil.copy2(f, '.')
    if prm['debug'] > 2:
        os.mkdir('debug')

    # save input parameters
    json.dump(prm, open('parameters.json', 'w'), indent=4, sort_keys=True)
    out = ''
    for i in sorted(prm):
        out += str(prm[i]) + '\n'
    out += '%s\n>\n' % len(fio)
    for i in fio:
        out += str(i) + '\n'
    for i in "',[]":
        out = out.replace(i, '')
    open('parameters.txt', 'w').write(out)

    # metadata
    # [field, reg, ii, nb, x1, x2, val, tau, op, fname]
    xis = {}
    indices = {}
    shapes = {}
    deltas = {}
    for f in fio:
        op, k = f[-2], f[-1]
        if op[-1] in '<>':
            if '.' in op:
                xis[k] = f[4]
            indices[k] = f[2]
            shapes[k] = []
            deltas[k] = []
            for i, ii in enumerate(indices[k]):
                n = (ii[1] - ii[0]) // ii[2] + 1
                d = prm['delta'][i] * ii[2]
                if n > 1:
                    shapes[k] += [n]
                    deltas[k] += [d]
            if shapes[k] == []:
                shapes[k] = [1]
            if deltas[k] == []:
                del(deltas[k])

    # save metadata
    m = {
        'dtype':   cfg['dtype'],
        'shapes':  shapes,
        'deltas':  deltas,
        'xis':     xis,
        'indices': indices,
    }
    m.update(prm)
    f = open('meta.json', 'w')
    json.dump(m, f, indent=4, sort_keys=True)

    os.chdir(cwd)
    return cfg

def run(args, **kwargs):
    """
    Stage and launch job.
    """
    from .. import util
    cfg = stage(args, **kwargs)
    util.launch(cfg)
    return cfg

def expand_slices(shape, slices=[], base=0, new_base=None, round=True):
    """
    >>> shape = [8, 8, 8, 8]

    >>> expand_slices(shape, [])
    [[0, 8, 1], [0, 8, 1], [0, 8, 1], [0, 8, 1]]

    >>> expand_slices(shape, '')
    [[0, 8, 1], [0, 8, 1], [0, 8, 1], [0, 8, 1]]

    >>> expand_slices(shape, [0.4,0.6,-0.6,-0.4])
    [[0, 1, 1], [1, 2, 1], [7, 8, 1], [8, 9, 1]]

    >>> expand_slices(shape, '[0.4,0.6,-0.6:-0.4:2,:]')
    [[0, 1, 1], [1, 2, 1], [7, 8, 2], [0, 8, 1]]

    >>> expand_slices(shape, '[0.9,1.1,-1.1:-0.9:2,:]', base=0.5)
    [[0, 1, 1], [1, 2, 1], [6, 7, 2], [0, 7, 1]]

    >>> expand_slices(shape, '[1.4,1.6,-1.6:-1.4:2,:]', base=1)
    [[1, 1, 1], [2, 2, 1], [7, 8, 2], [1, 8, 1]]

    >>> expand_slices(shape, '[1.9,2.1,-2.1:-1.9:2,:]', base=1.5)
    [[1, 1, 1], [2, 2, 1], [6, 7, 2], [1, 7, 1]]

    >>> expand_slices(shape, [0,1,2,[]], base=0, new_base=1)
    [[1, 1, 1], [2, 2, 1], [3, 3, 1], [1, 8, 1]]
    """

    # string style
    if isinstance(slices, basestring):
        if slices == '':
            slices = []
        elif slices[0] + slices[-1] == '[]':
            slices = slices[1:-1].split(',')
        else:
            raise Exception('error in indices: %r' % (slices,))

    # list style
    slices = slices[:]
    n = len(shape)
    if len(slices) == 0:
        slices = n * [[]]
    elif len(slices) != n:
        raise Exception('error in indices: %r' % (slices,))

    # index base
    if new_base is None:
        new_base = base
    if type(base) in (int, float):
        base = n * [base]
    if type(new_base) in (int, float):
        new_base = n * [new_base]

    # loop over slices
    for i, s in enumerate(slices):

        # convert to list
        if type(s) == slice:
            s = [s.start, s.stop, s.step]
        if isinstance(s, basestring):
            s_ = []
            for j in s.split(':'):
                if j == '':
                    s_.append(None)
                elif '.' in j:
                    s_.append(float(j))
                else:
                    s_.append(int(j))
            s = s_
        elif type(s) not in (tuple, list):
            s = [s]

        # fill missing values
        wraparound = shape[i] + int(base[i])
        if len(s) == 0:
            s = [None, None, 1]
        elif len(s) == 1:
            s = s[0]
            if s < 0:
                s += wraparound
            s = [s, s + 1 - int(base[i]), 1]
        elif len(s) == 2:
            s = [s[0], s[1], 1]
        elif len(s) != 3:
            raise Exception('error in indices: %r' % (slices,))

        # handle None
        start, stop, step = s
        if start is None:
            start = base[i]
        if stop is None:
            stop = -base[i] + wraparound
        if step is None:
            step = 1

        # handle negative indices
        if start < 0:
            start += wraparound
        if stop < 0:
            stop += wraparound

        # convert base
        if new_base[i] != base[i]:
            r = new_base[i] - base[i]
            start += r
            stop += r - int(r)

        # round and finish
        if round:
            r = new_base[i] - int(new_base[i])
            start = int(start - r + 0.5)
            stop  = int(stop  - r + 0.5)
        slices[i] = [start, stop, step]

    return slices

def prepare_param(prm, fio):
    """
    Prepare input parameters
    """
    import os

    # checks
    if prm['source'] not in ('potency', 'moment', 'force', 'none'):
        raise Exception('Error: unknown source type %r' % prm['source'])

    # intervals
    nt = prm['shape'][3]
    prm['itio'] = max(1, min(prm['itio'], nt))

    # hypocenter coordinates
    nn = prm['shape'][:3]
    xi = prm['ihypo']
    for i in range(3):
        xi[i] = 0.0 + xi[i]
        if xi[i] <= -1.0:
            xi[i] = xi[i] + nn[i] + 1
        if xi[i] < 1.0 or xi[i] > nn[i]:
            raise Exception('Error: ihypo %s out of bounds' % xi)

    # rupture boundary conditions
    nn = prm['shape'][:3]
    i1 = prm['bc1']
    i2 = prm['bc2']
    i = abs(prm['faultnormal']) - 1
    if i >= 0:
        irup = int(xi[i])
        if irup == 1:
            i1[i] = -2
        if irup == nn[i] - 1:
            i2[i] = -2
        if irup < 1 or irup > (nn[i] - 1):
            raise Exception('Error: ihypo %s out of bounds' % xi)

    # pml region
    nn = prm['shape'][:3]
    i1 = [0, 0, 0]
    i2 = [nn[0] + 1, nn[1] + 1, nn[2] + 1]
    if prm['npml'] > 0:
        for i in range(3):
            if prm['bc1'][i] == 10:
                i1[i] = prm['npml']
            if prm['bc2'][i] == 10:
                i2[i] = nn[i] - prm['npml'] + 1
            if i1[i] > i2[i]:
                raise Exception('Error: model too small for PML')
    prm.update({'i1pml': i1, 'i2pml': i2})

    # field i/o 
    fld = fieldnames()
    fieldio = []
    filenames = []
    for field, ios in sorted(fio.items()):
        if type(ios) in (float, int):
            ios = [ios]
        elif len(ios) > 1 and isinstance(ios[1], basestring):
            ios = [ios]
        ios_ = []
        it1, it2 = prm['shape'][-1] + 1, -1
        for io in ios:
            x1 = x2 = [0.0, 0.0, 0.0]
            fname, val, tau = 'const', 0.0, 0.0
            if type(io) in (float, int):
                ii, op, rhs = [], '=', [io]
            else:
                ii, op, rhs = io[0], io[1], io[2:]
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
                filename = os.path.expanduser(fname)
            else:
                raise Exception('Error: bad i/o operation: %r' % io)

            # error check
            if len(fname) > 32:
                raise Exception('File/function name too long: ' + fname)
            if field in fld['input'] and op == '>':
                raise Exception('Error: field is ouput only: %r' % field)
            if field in fld['fault'] and prm['faultnormal'] == 0:
                raise Exception('Error: field only for ruptures: %r' % field)

            # cell or node registration
            if field in fld['cell']:
                reg = 'c'
                base = 1.5, 1.5, 1.5, 1
            else:
                reg = 'n'
                base = 1, 1, 1, 1

            # indices
            nn = prm['shape']
            if field in fld['initial']:
                nn = nn[:3]
            if '.' in op:
                x1 = expand_slices(nn, ii, base, round=False)
                x1 = [x1[0][0], x1[1][0], x1[2][0]]
            ii = expand_slices(nn, ii, base)
            if field in fld['initial']:
                ii += [[0, 0, 1]]
            if field in fld['fault']:
                i = abs(prm['faultnormal']) - 1
                ii[i] = [irup, irup, 1]
            it1 = min(it1, ii[-1][0])
            it2 = max(it2, ii[-1][1])

            # buffer size
            shape = [(i[1] - i[0]) // i[2] + 1 for i in ii]
            nb = (min(prm['itio'], nt) - 1) // ii[3][2] + 1
            nb = max(1, min(nb, shape[3]))
            n = shape[0] * shape[1] * shape[2]
            if n > (nn[0] + nn[1] + nn[2]) ** 2:
                nb = 1
            elif n > 1:
                nb = min(nb, prm['itbuff'])

            # append to list
            ios_ += [[field, reg, ii, nb, x1, x2, val, tau, op, fname]]

        fieldio += [(it1, it2, ios_)]

    fieldio = [g for f in sorted(fieldio) for g in f[2]]

    # done
    del(prm['itbuff'])
    return prm, fieldio

