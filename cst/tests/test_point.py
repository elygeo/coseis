def test_point():
    """
    Test SORD parallelization with point source
    """
    import shutil
    import numpy as np
    import cst
    prm = cst.sord.parameters()

    # parameters
    prm.debug = 0
    prm.itstats = 1
    prm.shape = 5, 4, 2, 2
    prm.delta = 100.0, 100.0, 100.0, 0.0075
    prm.bc1 = 0, 0, 0
    prm.bc2 = 0, 0, 0

    # source
    prm.source = 'potency'
    prm.ihypo = 1.5, 1.5, 1.5
    prm.ihypo = 3.0, 1.5, 1.5
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
    cst.sord.run(
        prm,
        rundir = 'tmp/s',
        run = 'exec',
        argv = [],
    )

    # multiple processes
    max_err_all_ = 0.0
    for i, n in enumerate([(3, 1, 1), (2, 2, 1)]):
        prm.nproc3 = n
        job = cst.sord.run(
            prm,
            rundir = 'tmp/%s' % i,
            run = 'exec',
            argv = [],
        )
        max_err_ = 0.0
        for f in cst.sord.fieldnames.volume:
            f1 = 'tmp/s/%s.bin' % f
            f2 = 'tmp/%s/%s.bin' % (i, f)
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

    # cleanup
    shutil.rmtree('tmp')

# continue if command line
if __name__ == '__main__':
    test_point()

