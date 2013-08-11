#!/usr/bin/env python

def test(argv=[]):
    """
    Test SORD parallelization with PML
    """
    import os
    import numpy as np
    import cst
    prm = cst.sord.parameters()

    # parameters
    prm.itstats = 1
    prm.shape = [21, 21, 21, 11]
    prm.delta = [100.0, 100.0, 100.0, 0.0075]
    prm.bc1 = [10, 10, 10]
    prm.bc2 = [10, 10, 10]

    # source
    prm.source = 'potency'
    prm.ihypo = [11, 11, 11]
    prm.source1 = [1e10, 1e10, 1e10]
    prm.source2 =  [0.0,  0.0,  0.0]
    prm.pulse = 'delta'

    # material
    prm.hourglass = [1.0, 1.0]
    prm.fieldio = [
        ['=', 'rho', [], 2670.0],
        ['=', 'vp',  [], 6000.0],
        ['=', 'vs',  [], 3464.0],
        ['=', 'gam', [], 0.3],
    ]

    # output
    for f in cst.sord.fieldnames()['volume']:
        prm.fieldio += [['=w', f, [], f + '.bin']]

    # master
    cwd = os.getcwd()
    d0 = os.path.join('run', 'pml_boundary') + os.sep
    os.makedirs(d0)
    os.chdir(d0)
    cst.sord.run(prm, run='exec', argv=argv)
    os.chdir(cwd)

    # variations
    max_err_all_ = 0.0
    for i, n in enumerate([[4, 1, 1], [1, 2, 3]]):
        prm.nproc3 = n
        d = os.path.join('run', 'pml_boundary%s' % i) + os.sep
        os.makedirs(d)
        os.chdir(d)
        job = cst.sord.run(prm, run='exec', argv=argv)
        os.chdir(cwd)
        max_err_ = 0.0
        for f in cst.sord.fieldnames()['volume']:
            f1 = d0 + f + '.bin'
            f2 = d + f + '.bin'
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
    import sys
    test(sys.argv[1:])

