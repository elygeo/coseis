#!/usr/bin/env python

def test(argv=[]):
    """
    Test SORD parallelization with point source
    """
    import os, subprocess
    import numpy as np
    import cst
    prm = {}

    # parameters
    prm['argv'] = argv
    prm['itstats'] = 1

    # dimensions
    prm['shape'] = [5, 4, 2, 2]
    prm['delta'] = [100.0, 100.0, 100.0, 0.0075]

    # material
    prm['rho'] = [2670.0]
    prm['vp']  = [6000.0]
    prm['vs']  = [3464.0]
    prm['gam'] = [0.3]
    prm['hourglass'] = [1.0, 1.0]

    # boundary conditions
    prm['bc1'] = ['free', 'free', 'free']
    prm['bc2'] = ['free', 'free', 'free']

    # output
    fns = cst.sord.fieldnames()
    fns = sorted(fns['node']) + sorted(fns['cell'])
    for k in fns:
        prm[k] += [([], '=>', k + '.bin')]

    # potency source
    prm['pxx'] += [([0,0,0,0], '=', 1e10)]
    prm['pyy'] += [([0,0,0,0], '=', 1e10)]
    prm['pzz'] += [([0,0,0,0], '=', 1e10)]

    # master
    cwd = os.getcwd()
    d0 = os.path.join('run', 'sord_mpi') + os.sep
    os.makedirs(d0)
    os.chdir(d0)
    job = cst.sord.run(prm)
    subprocess.check_call(job['launch'])
    os.chdir(cwd)

    # variations
    max_err_all_ = 0.0
    for i, n in enumerate([[3, 1, 1], [2, 2, 1]]):
        prm['nproc3'] = n
        d = os.path.join('run', 'sord_mpi%s' % i) + os.sep
        os.makedirs(d)
        os.chdir(d)
        job = cst.sord.stage(prm)
        subprocess.check_call(job['launch'])
        os.chdir(cwd)
        max_err_ = 0.0
        for k in fns:
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

