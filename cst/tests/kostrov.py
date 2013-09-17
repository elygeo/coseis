#!/usr/bin/env python

def test(argv=[]):
    """
    Kostrov circular crack test.
    """
    import os
    import numpy as np
    import cst
    prm = {}

    # parameters
    prm['argv'] = argv

    # dimensions
    prm['nproc3'] = [1, 1, 2]
    prm['delta'] = [100.0, 100.0, 100.0, 0.0075]
    prm['shape'] = [51, 51, 24, 200]

    # material properties
    rho = 2670.0
    vp = 6000.0
    vs = 3464.0
    prm['hourglass'] = [1.0, 1.0]
    prm['fieldio'] = [
        'rho = {}'.format(rho),
        'vp  = {}'.format(vp),
        'vs  = {}'.format(vs),
        'gam = 1.0',
    ]

    # boundary conditions
    prm['bc1'] = [10, 10, 10]
    prm['bc2'] = [-1, 1, -2]

    # rupture
    dtau = 10e6
    prm['faultnormal'] = 3
    prm['ihypo'] = [-1, -1, -1.5]
    prm['vrup'] = 0.9 * vs
    prm['rcrit'] = 1e9
    prm['trelax'] = 0.0
    prm['fieldio'] += [
        'mud = 1.0',
        'mus = 1e9',
        'dc = 1e9',
        'tn = {}'.format(-90e6),
        'ts = {}'.format(-90e6 - dtau),
    ]

    # receivers
    prm['fieldio'] += [
        'svm[ -1,-21,-1,-1] write p20a.bin',
        'svm[-13,-17,-1,-1] write p20b.bin',
        'svm[-17,-13,-1,-1] write p20c.bin',
        'svm[-21, -1,-1,-1] write p20d.bin',
    ]

    # analytical solution
    r = 2000.0
    t = (prm['shape'][-1] - 1.5) * prm['delta'][-1] - r / prm['vrup']
    #v = cst.kostrov.slip_rate(rho, vp, vs, prm['vrup'], dtau, r, t, 0.82)
    v = cst.kostrov.slip_rate(rho, vp, vs, prm['vrup'], dtau, r, t)

    # run SORD
    prm['rundir'] = d = os.path.join('run', 'kostrov') + os.sep
    os.makedirs(d)
    cfg = cst.sord.run(prm)

    # compare with analytical solution
    for p in 'abcd':
        f = d + 'p20{}.bin'.format(p)
        dv = v - np.fromfile(f, cfg['dtype'])[-1]
        err = dv / v
        print(v, err)
        assert abs(err) < 0.015

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

