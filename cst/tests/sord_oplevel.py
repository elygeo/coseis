#!/usr/bin/env python

def test(argv=[]):
    """
    Test SORD operators
    """
    import os
    import numpy as np
    import cst
    prm = {}
    s_ = cst.sord.get_slices()

    # parameters
    prm['argv'] = argv
    prm['itstats'] = 1

    # dimensions
    prm['nproc3'] = [2, 1, 1]
    prm['nproc3'] = [1, 1, 1]
    prm['shape'] = [5, 4, 2, 2]
    prm['delta'] = [100.0, 100.0, 100.0, 0.0075]

    # material
    prm['rho'] = [2670.0]
    prm['vp']  = [6000.0]
    prm['vs']  = [3464.0]
    prm['gam'] = [0.3]
    prm['hourglass'] = [1.0, 1.0]

    # boundary conditions
    prm['bc1'] = [0, 0, 0]
    prm['bc2'] = [0, 0, 0]

    # source
    i = s_[1.5,1.5,1.5,:]
    i = s_[3.0,1.5,1.5,:]
    prm['p11'] = [(i, '.', 1e10, 'delta', 1.0)]
    prm['p22'] = [(i, '.', 1e10, 'delta', 1.0)]
    prm['p33'] = [(i, '.', 1e10, 'delta', 1.0)]

    # output
    fld = cst.sord.fieldnames()
    for k in fld['volume']:
        if k not in prm:
            k = []
        prm[k] += [([], '>', k + '.bin')]

    # master
    prm['oplevel'] = i = 5
    prm['rundir'] = d0 = os.path.join('run', 'sord_oplevel%s' % i) + os.sep
    os.makedirs(d0)
    cst.sord.run(prm)

    # variations
    max_err_all_ = 0.0
    for i in 6,:
        prm['oplevel'] = i
        prm['rundir'] = d = os.path.join('run', 'sord_oplevel%s' % i)
        os.makedirs(d)
        job = cst.sord.run(prm)
        max_err_ = 0.0
        for k, v in fld.items():
            if v.fault:
                continue
            f1 = d0 + k + '.bin'
            f2 = d + k + '.bin'
            v1 = np.fromfile(f1, job.dtype)
            v2 = np.fromfile(f2, job.dtype)
            dv = v1 - v2
            e = np.abs(dv).max()
            if e:
                e = 0.5 * e / (np.abs(v1).max() + np.abs(v2).max())
                print('%s error: %s' % (k, e))
                max_err_ = max(max_err_, e)
        print('max error: ', max_err_)
        max_err_all_ = max(max_err_all_, max_err_)
    assert max_err_all_ == 0.0

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

