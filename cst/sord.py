#!/usr/bin/env python
"""
Support Operator Rupture Dynamics
"""

# default simulation parameters
parameters = {
    'nproc3': [1, 1, 1], # number of processors in [j, k, l]
    'mpin': 1, # MPI-IO input: 0=off, 1=collective, -1=non-collective
    'mpout': 1, # MPI-IO output: 0=off, 1=collective, -1=non-collective
    'itstats': 10, # interval for calculating statistics
    'itio': 50, # interval for writing i/o buffers
    'itbuff': 10, # buffer size for time series output
    'debug': 0, # >1 sync, >2 MPI vars, >3 I/O
    'diffop': 'auto', # spatial difference operator
    'shape': [41, 41, 41, 41], # mesh size [nx, ny, nz, nt]
    'delta': [100.0, 100.0, 100.0, 0.0075], # step size [dx, dy, dz, dt]
    'affine': [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]], # transform
    'rexpand': 1.06, # grid expansion ratio
    'n1expand': [0, 0, 0], # number of grid expansion nodes - near side
    'n2expand': [0, 0, 0], # number of grid expansion nodes - far side
    'gridnoise': 0.0, # random noise added to mesh, assumes planar fault
    'tm0': 0.0, # initial time
    'rho': [2670.0], # density
    'vp':  [6000.0], # P-wave speed
    'vs':  [3464.0], # S-wave speed
    'gam': [0.0], # viscosity
    'rho_min': -1.0, # min density
    'rho_max': -1.0, # max density
    'vp_min': -1.0, # min P-wave speed
    'vp_max': -1.0, # max P-wave speed
    'vs_min': -1.0, # min S-wave speed
    'vs_max': -1.0, # max S-wave speed
    'gam_min': -1.0, # min viscosity
    'gam_max': 0.8, # max viscosity
    'hourglass': [1.0, 1.0], # hourglass stiffness (1) and viscosity (2)
    'vdamp': -1.0, # Vs dependent damping
    'bc1': ['free', 'free', 'free'], # boundary cond: near x, y, z surface
    'bc2': ['free', 'free', 'free'], # boundary cond: far x, y, z surface
    'npml': 10, # number of PML damping nodes
    'ppml': 2, # PML exponent, 1-4. Generally 2 is best.
    'vpml': -1.0, # damping velocity, <0 default to min, max V_s harmonic mean
    'nsource': 0, # number of finite source sub-faults
    'source': 'potency', # finite source type: potency, moment, force
    'hypocenter': [0.0, 0.0, 0.0], # hypocenter logical coordinates
    'slipvector': [1.0, 0.0, 0.0], # shear traction direction for ts1
    'faultnormal': 'none', # fault normal direction: +x, +y, +z, -x, -y, -z
    'faultopening': 0, # 0=not allowed, 1=allowed
    'vrup': -1.0, # nucleation rupture velocity, negative = no nucleation
    'rcrit': 1000.0, # nucleation critical radius
    'trelax': 0.075, # nucleation relaxation time
    'svtol': 0.001, # slip velocity considered rupturing
}

# Multi-dimensional field variable names for input and output.
# n: node registered volume field
# c: cell registered volume field
# f: fault rupture field
# ~: time varying field
# <: input/output field, otherwise output only.
# Note: For efficiency, magnitudes of 3D fields [am2, vm2, um2, wm2] are
# magnitude squared because square roots are computationally expensive. Also
# stress magnitude (wm2) is the square of the Frobenius Norm, as finding the
# true stress tensor magnitude requires computing eigenvalues at every
# location.
fieldnames = {
    'x': ['n<', 'x', 'Node coordinate'],
    'y': ['n<', 'y', 'Node coordinate'],
    'z': ['n<', 'z', 'Node coordinate'],
    'fx': ['n~<', 'f_x', 'Force'],
    'fy': ['n~<', 'f_y', 'Force'],
    'fz': ['n~<', 'f_z', 'Force'],
    'ax': ['n~<', 'a_x', 'Acceleration'],
    'ay': ['n~<', 'a_y', 'Acceleration'],
    'az': ['n~<', 'a_z', 'Acceleration'],
    'vx': ['n~<', 'v_x', 'Velocity'],
    'vy': ['n~<', 'v_y', 'Velocity'],
    'vz': ['n~<', 'v_z', 'Velocity'],
    'ux': ['n~<', 'u_x', 'Displacement'],
    'uy': ['n~<', 'u_y', 'Displacement'],
    'uz': ['n~<', 'u_z', 'Displacement'],
    'am2': ['n~', '|a|', 'Acceleration magnitude'],
    'vm2': ['n~', '|v|', 'Velocity magnitude'],
    'um2': ['n~', '|u|', 'Displacement magnitude'],
    'rho': ['c<', '\rho', 'Density'],
    'vp':  ['c<', 'V_p', 'P-wave velocity'],
    'vs':  ['c<', 'V_s', 'S-wave velocity'],
    'gam': ['c<', '\gamma', 'Viscosity'],
    'xc':  ['c', 'x', 'Cell coordinate'],
    'yc':  ['c', 'y', 'Cell coordinate'],
    'zc':  ['c', 'z', 'Cell coordinate'],
    'vc':  ['c', 'V^C', 'Cell volume'],
    'nu':  ['c', '\nu', 'Poisson ratio'],
    'mu':  ['c', '\mu', 'Elastic modulus'],
    'lam': ['c', '\lambda', 'Elastic modulus'],
    'pxx': ['c~<', 'p_{xx}', 'Seismic potency'],
    'pyy': ['c~<', 'p_{yy}', 'Seismic potency'],
    'pzz': ['c~<', 'p_{zz}', 'Seismic potency'],
    'pyz': ['c~<', 'p_{yz}', 'Seismic potency'],
    'pzx': ['c~<', 'p_{zx}', 'Seismic potency'],
    'pxy': ['c~<', 'p_{xy}', 'Seismic potency'],
    'mxx': ['c~<', 'm_{xx}', 'Seismic moment'],
    'myy': ['c~<', 'm_{yy}', 'Seismic moment'],
    'mzz': ['c~<', 'm_{zz}', 'Seismic moment'],
    'myz': ['c~<', 'm_{yz}', 'Seismic moment'],
    'mzx': ['c~<', 'm_{zx}', 'Seismic moment'],
    'mxy': ['c~<', 'm_{xy}', 'Seismic moment'],
    'wxx': ['c~<', '\sigma_{xx}', 'Stress'],
    'wyy': ['c~<', '\sigma_{yy}', 'Stress'],
    'wzz': ['c~<', '\sigma_{zz}', 'Stress'],
    'wyz': ['c~<', '\sigma_{yz}', 'Stress'],
    'wzx': ['c~<', '\sigma_{zx}', 'Stress'],
    'wxy': ['c~<', '\sigma_{xy}', 'Stress'],
    'wm2': ['c~', '||\sigma||_F', 'Stress Frobenius norm'],
    'mus': ['f<', '\mu_s', 'Static friction coefficient'],
    'mud': ['f<', '\mu_d', 'Dynamic friction coefficient'],
    'dc':  ['f<', 'D_c', 'Slip weakening distance'],
    'co':  ['f<', 'co', 'Cohesion'],
    'tn':  ['f<', '\tau_n', 'Pre-traction normal component'],
    'ts':  ['f<', '\tau_s', 'Pre-traction strike component'],
    'td':  ['f<', '\tau_d', 'Pre-traction dip component'],
    'sxx': ['f<', '\sigma_{xx}', 'Pre-stress'],
    'syy': ['f<', '\sigma_{yy}', 'Pre-stress'],
    'szz': ['f<', '\sigma_{zz}', 'Pre-stress'],
    'syz': ['f<', '\sigma_{yz}', 'Pre-stress'],
    'szx': ['f<', '\sigma_{zx}', 'Pre-stress'],
    'sxy': ['f<', '\sigma_{xy}', 'Pre-stress'],
    'nsx': ['f', 'n_x', 'Fault surface normal'],
    'nsy': ['f', 'n_y', 'Fault surface normal'],
    'nsz': ['f', 'n_z', 'Fault surface normal'],
    '_f0': ['f<', 'f_0', 'Steady state friction at V_0'],
    '_fw': ['f<', 'f_w', 'Fully weakened fiction'],
    '_v0': ['f<', 'V_0', 'Reference slip velocity'],
    '_vw': ['f<', 'V_w', 'Weakening slip velocity'],
    '_ll': ['f<', 'L', 'State evolution distance'],
    '_af': ['f<', 'a', 'Direct effect parameter'],
    '_bf': ['f<', 'b', 'Evolution effect parameter'],
    'tx':  ['f~', '\tau_x', 'Traction'],
    'ty':  ['f~', '\tau_y', 'Traction'],
    'tz':  ['f~', '\tau_z', 'Traction'],
    'tsx': ['f~', '\tau^s_x', 'Shear traction'],
    'tsy': ['f~', '\tau^s_y', 'Shear traction'],
    'tsz': ['f~', '\tau^s_z', 'Shear traction'],
    'tnm': ['f~', '\tau^n', 'Normal traction'],
    'tsm': ['f~', '|\tau^s|', 'Shear traction magnitude'],
    'fr':  ['f~', '\tau_c', 'Friction'],
    'sax': ['f~', '\ddot s_x', 'Slip acceleration'],
    'say': ['f~', '\ddot s_y', 'Slip acceleration'],
    'saz': ['f~', '\ddot s_z', 'Slip acceleration'],
    'sam': ['f~', '|\ddot s|', 'Slip acceleration magnitude'],
    'svz': ['f~', '\dot s_x', 'Slip velocity'],
    'svy': ['f~', '\dot s_y', 'Slip velocity'],
    'svz': ['f~', '\dot s_z', 'Slip velocity'],
    'svm': ['f~', '|\dot s|', 'Slip velocity magnitude'],
    'psv': ['f~', '|\dot s|_{peak}', 'Peak slip velocity'],
    'sux': ['f~', 's_x', 'Slip'],
    'suy': ['f~', 's_y', 'Slip'],
    'suz': ['f~', 's_z', 'Slip'],
    'sum': ['f~', '|s|', 'Slip magnitude'],
    'sl':  ['f~', '\ell', 'Slip path length'],
    'trup': ['f~', 't_{rupture}', 'Rupture time'],
    'tarr': ['f~', 't_{arrest}', 'Arrest time'],
    '_psi': ['f~', '\psi', 'State variable'],
}

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

class typed_dict(dict):
    def __setitem__(self, k, v):
        if type(v) != type(self[k]):
            raise TypeError(key, self[k], v)
        dict.__setitem__(self, k, v)

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
    import os
    from . import util

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
    import os, json, subprocess
    configure(force)
    p = __file__[:-3] + os.sep
    if force:
        subprocess.check_call(['make', '-C', p, 'clean'])
    subprocess.check_call(['make', '-C', p, '-j', '4'])
    cfg = json.load(open(p + 'config.json'))
    return cfg


def prepare_param(prm, fio):
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
            if type(prm[k][i]) == str:
                prm[k][i] = boundary_conditions[prm[k][i]]

    # field i/o
    fio_ = []
    filenames = []
    shapes = {}
    deltas = {}
    indices = {}
    for field, ios in sorted(fio.items()):
        tags = fieldnames[field][0]
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
        elif len(ios) > 1 and type(ios[1]) == str:
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
    import os, json, shutil
    import numpy as np
    from . import util

    print('SORD: Support Operator Rupture Dynamics')

    # arguments
    if args == None:
        args = {}
    args.update(kwargs)

    # configure and make
    prm = {}
    fio = {}
    job = {}
    for k, v in parameters.items():
        if k in fieldnames:
            fio[k] = v
        else:
            prm[k] = v
    for k, v in args.items():
        if k in fieldnames:
            if type(v) != list:
                v = [v]
            elif len(v) > 1 and type(v[1]) == str:
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
        elif k in parameters:
            u = parameters[k]
            if u != None and v != None and type(u) != type(v):
                raise TypeError(k, v, u)
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
        raise Exception('MPI build required for multiprocessing') 

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
    out = json.dumps(args, indent=4, sort_keys=True)
    open('parameters.json', 'w').write(out)
    out = json.dumps(job, indent=4, sort_keys=True)
    open('job.json', 'w').write(out)
    out = json.dumps(prm, indent=4, sort_keys=True)
    open('sord.json', 'w').write(out)
    out = json.dumps(meta, indent=4, sort_keys=True)
    open('meta.json', 'w').write(out)

    # save archive and start job
    util.launch(job)

    return job

class get_slices:
    def __getitem__(self, slices):
        return slices
s_ = get_slices()

# String representation of slice object
def repr_slices(slices):
    if type(slices) == str:
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
    if type(slices) == str:
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
        if type(s) == str:
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

def command_line():
    import sys, json, yaml
    files = []
    args = {}
    prm = open(sys.argv[1])
    prm = yaml.load(prm)
    del(sys.argv[1])
    cst.sord.run(prm)

    # command line parameters
    for i in job['argv']:
        if not i.startswith('--'):
            raise Exception('Bad argument ' + i)
        k, v = i[2:].split('=')
        if len(v) and not v[0].isalpha():
            v = json.loads(v)
        job[k] = v


if __name__ == '__main__':
    command_line()

