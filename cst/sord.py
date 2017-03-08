"""
Support Operator Rupture Dynamics
"""
import os
import sys
import json
import shutil
import subprocess
from . import job as joblib

src_path = os.path.dirname(__file__)
src_path = os.path.realpath(src_path)
src_path = os.path.dirname(src_path)
src_path = os.path.join(src_path, 'sord')

parameters = {
    'nproc3': [1, 1, 1],
    'nthread': -1,
    'mpin': 1,
    'mpout': 1,
    'itstats': 10,
    'itio': 50,
    'itbuff': 10,
    'debug': 0,
    'shape': [41, 41, 41, 41],
    'delta': [100.0, 100.0, 100.0, 0.0075],
    'affine': [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]],
    'rexpand': 1.06,
    'n1expand': [0, 0, 0],
    'n2expand': [0, 0, 0],
    'gridnoise': 0.0,
    'tm0': 0.0,
    'rho': [2670.0],
    'vp': [6000.0],
    'vs': [3464.0],
    'gam': [0.0],
    'rho_min': -1.0,
    'rho_max': -1.0,
    'vp_min': -1.0,
    'vp_max': -1.0,
    'vs_min': -1.0,
    'vs_max': -1.0,
    'gam_min': -1.0,
    'gam_max': 0.8,
    'hourglass': [1.0, 1.0],
    'vdamp': -1.0,
    'bc1': ['free', 'free', 'free'],
    'bc2': ['free', 'free', 'free'],
    'npml': 10,
    'ppml': 2,
    'vpml': -1.0,
    'nsource': 0,
    'source': 'potency',
    'hypocenter': [0.0, 0.0, 0.0],
    'slipvector': [1.0, 0.0, 0.0],
    'faultnormal': 'none',
    'faultopening': 0,
    'vrup': -1.0,
    'rcrit': 1000.0,
    'trelax': 0.075,
    'svtol': 0.001,
}

# n node, c cell, f fault, ~ time varying, < input
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
    'svx': ['f~', '\dot s_x', 'Slip velocity'],
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

source_files = [
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


class typed_dict(dict):
    def __setitem__(self, k, v):
        if isinstance(self[k], type(v)):
            raise TypeError(k, self[k], v)
        dict.__setitem__(self, k, v)


def expand_slices(shape, slices):
    n = len(shape)
    if len(slices) == 0:
        slices = n * [[]]
    elif len(slices) != n:
        raise Exception('error in indices: %r' % (slices,))
    ss = []
    for n, s in zip(shape, slices):
        if isinstance(s, (list, tuple)):
            s = slice(*s).indices(n)
        else:
            s = (s % n, s % n + 1, 1)
        ss.append(s)
    return ss


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
    cwd = os.getcwd()
    os.chdir(src_path)
    if force or not os.path.exists('Makefile'):
        rules = []
        objects = []
        for s in source_files[::-1]:
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
        c = joblib.hostname()[1]
        m = open('Makefile.in').read()
        m = m.format(machine=c, objects=objects, rules=rules)
        open('Makefile', 'w').write(m)
    os.chdir(cwd)
    return


def make(force=False):
    configure(force)
    if force:
        x = 'make', '-C', src_path, 'clean'
        subprocess.check_call(x)
    x = 'make', '-C', src_path, '-j', '4'
    subprocess.check_call(x)
    x = os.path.join(src_path, 'config.json')
    x = json.load(open(x))
    return x


def prepare(prm, fio):

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
            if isinstance(prm[k][i], str):
                prm[k][i] = boundary_conditions[prm[k][i]]

    # field i/o
    fio_ = []
    filenames = []
    shapes = {}
    deltas = {}
    indices = {}
    for field in sorted(fio):
        ios = fio[field]
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
        if isinstance(ios, (float, int)):
            ios = [ios]
        elif len(ios) > 1 and isinstance(ios[1], str):
            ios = [ios]
        ios_ = []
        for io in ios:
            fname, val, tau = 'const', 0.0, 0.0
            x1, x2 = [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]
            if isinstance(io, (float, int)):
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
            # s = '[' + ','.join('%s:%s:%s' % tuple(s) for s in slices) + ']'
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


def stage(args=None, **kwargs):
    if args is None:
        args = {}
    args.update(kwargs)
    prm = {}
    fio = {}
    job = {}
    for k in parameters:
        v = parameters[k]
        if k in fieldnames:
            fio[k] = v
        else:
            prm[k] = v
    fio = typed_dict(fio)
    prm = typed_dict(prm)
    for k in args:
        v = args[k]
        if k in fieldnames:
            fio[k] = v
        elif k in parameters:
            prm[k] = v
        else:
            job[k] = v

    cfg = make()  # process, thread, realsize
    prm, fio, meta = prepare(prm, fio)

    job['name'] = 'sord'
    job['executable'] = s = os.path.join('.', 'sord.x')
    if cfg['process'] == 'serial':
        job['execute'] = s

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
    nvars = 23
    nb = cfg['realsize']
    nm = (nl[0] + 2) * (nl[1] + 2) * (nl[2] + 2)
    job['pmem'] = (1 + nm * nvars * nb // 30000) * 32
    m = (1 + (nt + 10) * nm // 420000000) * 10
    if m > 60:
        m = (1 + (nt + 10) * nm // 70000000) * 60
    job['minutes'] = m

    f = os.path.join(src_path, 'sord.x')
    shutil.copy2(f, '.')
    if prm['debug'] > 2:
        os.mkdir('debug')

    out = [prm[i] for i in sorted(prm)]
    out = json.dumps(out) + '\n'
    for i in fio:
        out += json.dumps(i) + '\n'
    for i in '",[]':
        out = out.replace(i, '')
    open('sord.in', 'w').write(out)

    d = {'little': '<', 'big': '>'}[sys.byteorder]
    meta['dtype'] = d + 'f%s' % cfg['realsize']
    prm.update({'~fieldio': fio})

    json.dump(args, open('parameters.json', 'w'), indent=4, sort_keys=True)
    json.dump(job, open('job.json', 'w'), indent=4, sort_keys=True)
    json.dump(prm, open('sord.json', 'w'), indent=4, sort_keys=True)
    json.dump(meta, open('meta.json', 'w'), indent=4, sort_keys=True)

    return job


def run(args=None, **kwargs):
    job = stage(args, **kwargs)
    joblib.launch(job)
    return job


if __name__ == '__main__':
    if sys.argv[1:]:
        args = {}
        for i in sys.argv[1:]:
            args.update(json.load(open(i)))
    else:
        args = json.load(sys.stdin)
    run(args)
