#!/usr/bin/env python

def test(argv=[]):
    """
    Test SORD parallelization with point source
    """
    import os
    import numpy as np
    import cst
    prm = {}

    # parameters
    prm['argv'] = argv
    prm['itstats'] = 1

    # dimensions
    prm['shape'] = [5, 4, 2, 2]
    prm['delta'] = [100.0, 100.0, 100.0, 0.0075]

    # boundary conditions
    prm['bc1'] = [0, 0, 0]
    prm['bc2'] = [0, 0, 0]

    # source
    prm['ihypo'] = [3.0, 1.5, 1.5]
    prm['ihypo'] = [1.5, 1.5, 1.5]
    prm['pulse'] = 'delta'
    prm['source'] = 'potency'
    prm['source1'] = [1e10, 1e10, 1e10]
    prm['source2'] = [0.0,  0.0,  0.0]

    # material
    prm['hourglass'] = [1.0, 1.0]
    prm['fieldio'] = [
        ['rho', [], '=', 2670.0],
        ['vp',  [], '=', 6000.0],
        ['vs',  [], '=', 3464.0],
        ['gam', [], '=', 0.3],
    ]

    # output
    for f in cst.sord.fieldnames()['volume']:
        prm['fieldio'] += [[f, [], 'write', f + '.bin']]

    # master
    prm['rundir'] = d0 = os.path.join('run', 'point_source') + os.sep
    os.makedirs(d0)
    cst.sord.run(prm)

    # variations
    max_err_all_ = 0.0
    for i, n in enumerate([[3, 1, 1], [2, 2, 1]]):
        prm['nproc3'] = n
        prm['rundir'] = d = os.path.join('run', 'point_source%s' % i) + os.sep
        os.makedirs(d)
        job = cst.sord.run(prm)
        max_err_ = 0.0
        for f in cst.sord.fieldnames()['volume']:
            f1 = d0 + f + '.bin'
            f2 = d + f + '.bin'
            v1 = np.fromfile(f1, job['dtype'])
            v2 = np.fromfile(f2, job['dtype'])
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

