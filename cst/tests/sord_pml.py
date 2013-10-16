#!/usr/bin/env python

def test(argv=[]):
    """
    Test SORD parallelization with PML
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
    prm['shape'] = [21, 21, 21, 11]
    prm['delta'] = [100.0, 100.0, 100.0, 0.0075]

    # material
    prm['rho'] = [2670.0]
    prm['vp']  = [6000.0]
    prm['vs']  = [3464.0]
    prm['gam'] = [0.3]
    prm['hourglass'] = [1.0, 1.0]

    # boundary conditions
    prm['bc1'] = ['pml', 'pml', 'pml']
    prm['bc2'] = ['pml', 'pml', 'pml']

    # source
    prm['pxx'] = [(s_[10,10,10,:], '.', 1e10, 'delta', 1.0)]
    prm['pyy'] = [(s_[10,10,10,:], '.', 1e10, 'delta', 1.0)]
    prm['pzz'] = [(s_[10,10,10,:], '.', 1e10, 'delta', 1.0)]

    # output
    fns = cst.sord.fieldnames()
    for k in fns['volume']:
        if k not in prm:
            prm[k] = []
        prm[k] += [([], '=>',  k + '.bin')]

    # master
    prm['path'] = d0 = os.path.join('run', 'sord_pml') + os.sep
    os.makedirs(d0)
    cst.sord.run(prm)

    # variations
    max_err_all_ = 0.0
    for i, n in enumerate([[4, 1, 1], [1, 2, 3]]):
        prm['nproc3'] = n
        prm['path'] = d = os.path.join('run', 'sord_pml%s' % i) + os.sep
        os.makedirs(d)
        job = cst.sord.run(prm)
        max_err_ = 0.0
        for k in fns['volume']:
            f1 = d0 + k + '.bin'
            f2 = d + k + '.bin'
            v1 = np.fromfile(f1, job['dtype'])
            v2 = np.fromfile(f2, job['dtype'])
            dv = v1 - v2
            e = np.abs(dv).max()
            if e:
                e /= np.abs(v1).max()
                print('%s error: %s' % (k, e))
                max_err_ = max(max_err_, e)
        print('max error: ', max_err_)
        max_err_all_ = max(max_err_all_, max_err_)
    assert max_err_all_ == 0.0

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

