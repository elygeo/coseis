#!/usr/bin/env python

def test(argv=[]):
    """
    Kostrov circular crack test.
    """
    import os
    import numpy as np
    import cst
    prm = cst.sord.parameters()
    fld = cst.sord.fieldnames()

    # parameters
    prm['argv'] = argv

    # dimensions
    dx, dt = 100.0, 0.0075
    nx, ny, nz, nt = 51, 51, 24, 200
    prm['delta'] = [dx, dx, dx, dt]
    prm['shape'] = [nx, ny, nz, nt]
    prm['nproc3'] = [1, 1, 2]

    # material properties
    rho = 2670.0
    vp = 6000.0
    vs = 3464.0
    prm['hourglass'] = [1.0, 1.0]
    prm['fieldio'] = [
        fld['rho'] == rho,
        fld['vp'] == vp,
        fld['vs'] == vs,
        fld['gam'] == 1.0,
    ]

    # boundary conditions
    prm['bc1'] = [10, 10, 10]
    prm['bc2'] = [-1, 1, -2]

    # rupture
    dtau = 10e6
    prm['faultnormal'] = 3
    prm['ihypo'] = [-1, -1, -1.5]
    prm['vrup'] = vr = 0.9 * vs
    prm['rcrit'] = 1e9
    prm['trelax'] = 0.0
    prm['fieldio'] += [
        fld['mud'] == 1.0,
        fld['mus'] == 1e9,
        fld['dc'] == 1e9,
        fld['tn'] == -90e6,
        fld['ts'] == -90e6 - dtau,
    ]

    # receivers
    prm['fieldio'] += [
        fld['svm'][ -1,-21,-1,-1] >> 'p20a.bin',
        fld['svm'][-13,-17,-1,-1] >> 'p20b.bin',
        fld['svm'][-17,-13,-1,-1] >> 'p20c.bin',
        fld['svm'][-21, -1,-1,-1] >> 'p20d.bin',
    ]

    # analytical solution
    r = 2000.0
    t = (nt - 1.5) * dt - r / prm['vrup']
    #v = cst.kostrov.slip_rate(rho, vp, vs, vr, dtau, r, t, 0.82)
    v = cst.kostrov.slip_rate(rho, vp, vs, vr, dtau, r, t)

    # run SORD
    prm['rundir'] = d = os.path.join('run', 'kostrov') + os.sep
    os.makedirs(d)
    cfg = cst.sord.run(prm)

    # compare with analytical solution
    for p in 'abcd':
        f = d + 'p20%s.bin' % p
        dv = v - np.fromfile(f, cfg['dtype'])[-1]
        err = dv / v
        print(v, err)
        assert abs(err) < 0.015

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

