#!/usr/bin/env python

def test(argv=[]):
    """
    Kostrov circular crack test.
    """
    import os
    import numpy as np
    import cst

    # parameters
    prm = cst.sord.parameters()
    prm.nproc3 = 1, 1, 2
    prm.delta = 100.0, 100.0, 100.0, 0.0075
    prm.shape = 51, 51, 24, 200

    # material properties
    rho = 2670.0
    vp = 6000.0
    vs = 3464.0
    prm.hourglass = 1.0, 1.0
    prm.fieldio = [
        ('=', 'rho', [], rho),
        ('=', 'vp',  [], vp),
        ('=', 'vs',  [], vs),
        ('=', 'gam', [], 1.0),
    ]

    # boundary conditions
    prm.bc1 = 10, 10, 10
    prm.bc2 = -1, 1, -2

    # rupture parameters
    prm.faultnormal = 3
    prm.ihypo = -1, -1, -1.5
    prm.vrup = 0.9 * 3464.0
    prm.rcrit = 1e9
    prm.trelax = 0.0
    dtau = 10e6
    prm.fieldio += [
        ('=', 'mud', [], 1.0),
        ('=', 'mus', [], 1e9),
        ('=', 'dc',  [], 1e9),
        ('=', 'tn',  [], -90e6),
        ('=', 'ts',  [], -90e6 - dtau),
    ]

    # recievers
    prm.fieldio += [
        ('=w', 'svm', [ -1,-21,-1,-1], 'p20a.bin'),
        ('=w', 'svm', [-13,-17,-1,-1], 'p20b.bin'),
        ('=w', 'svm', [-17,-13,-1,-1], 'p20c.bin'),
        ('=w', 'svm', [-21, -1,-1,-1], 'p20d.bin'),
    ]

    # analytical solution
    r = 2000.0
    t = (prm.shape[-1] - 1.5) * prm.delta[-1] - r / prm.vrup
    #v = cst.kostrov.slip_rate(rho, vp, vs, prm.vrup, dtau, r, t, 0.82)
    v = cst.kostrov.slip_rate(rho, vp, vs, prm.vrup, dtau, r, t)

    # run SORD
    d = 'run/kostrov'
    os.makedirs(d)
    job = cst.sord.run(
        prm,
        rundir = d,
        run = 'exec',
        argv = argv,
    )

    # compare with analytical solution
    for p in 'abcd':
        f = os.path.join(job.rundir, 'p20%s.bin' % p)
        dv = v - np.fromfile(f, job.dtype)[-1]
        err = dv / v
        print(v, err)
        assert abs(err) < 0.015

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

