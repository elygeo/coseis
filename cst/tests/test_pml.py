def test_pml():
    """
    Test SORD parallelization with PML
    """
    import os
    import numpy as np
    import cst
    prm = cst.sord.parameters()

    # parameters
    prm.itstats = 1
    prm.shape = 21, 21, 21, 11
    prm.delta = 100.0, 100.0, 100.0, 0.0075
    prm.bc1 = 10, 10, 10
    prm.bc2 = 10, 10, 10

    # source
    prm.source = 'potency'
    prm.ihypo = 11, 11, 11
    prm.source1 = 1e10, 1e10, 1e10
    prm.source2 =  0.0,  0.0,  0.0
    prm.pulse = 'delta'

    # material
    prm.hourglass = 1.0, 1.0
    prm.fieldio = [
        ('=', 'rho', [], 2670.0),
        ('=', 'vp',  [], 6000.0),
        ('=', 'vs',  [], 3464.0),
        ('=', 'gam', [], 0.3),
    ]

    # output
    for f in cst.sord.fieldnames.volume:
        prm.fieldio += [('=w', f, [], f + '.bin')]

    # single process
    job = cst.sord.run(
        prm,
        name = 'pml',
        run = 'exec',
        force = True,
        argv = [],
    )

    # multiple processes
    max_err_all_ = 0.0
    for i, n in enumerate([(4, 1, 1), (1, 2, 3)]):
        prm.nproc3 = n
        job1 = cst.sord.run(
            prm,
            name = 'pml%s' % i,
            run = 'exec',
            force = True,
            argv = [],
        )
        max_err_ = 0.0
        for f in cst.sord.fieldnames.volume:
            f1 = os.path.join(job.rundir, '%s.bin' % f)
            f2 = os.path.join(job1.rundir, '%s.bin' % f)
            v1 = np.fromfile(f1, job.dtype)
            v2 = np.fromfile(f2, job.dtype)
            dv = v1 - v2
            e = np.abs(dv).max()
            if e:
                e /= np.abs(v1).max()
                print('%s error: %s' % (f, e))
                max_err_ = max(max_err_, e)
        print('max error: ', max_err_)
        max_err_all_ = max(max_err_all_, max_err_)
    assert max_err_all_ == 0.0

# continue if command line
if __name__ == '__main__':
    test_pml()

