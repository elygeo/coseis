#!/usr/bin/env python

def test(argv=[]):
    """
    Test SORD operators
    """
    import os
    import numpy as np
    import cst

    # parameters
    prm = {
        'argv': argv,
        #'nproc3': [2, 1, 1],
        'nproc3': [1, 1, 1],
        'debug': 0,
        'itstats': 1,
        'shape': [5, 4, 2, 2],
        'delta': [100.0, 100.0, 100.0, 0.0075],
        'bc1': [0, 0, 0],
        'bc2': [0, 0, 0],

        # source
        'source': 'potency',
        'ihypo': [1.5, 1.5, 1.5],
        'ihypo': [3.0, 1.5, 1.5],
        'source1': [1e10, 1e10, 1e10],
        'source2': [0.0,  0.0,  0.0],
        'pulse': 'delta',

        # material
        'hourglass': [1.0, 1.0],
        'fieldio': [
            ['=', 'rho', [], 2670.0],
            ['=', 'vp',  [], 6000.0],
            ['=', 'vs',  [], 3464.0],
            ['=', 'gam', [], 0.3],
        ],
    }

    # output
    for f in cst.sord.fieldnames.volume:
        prm['fieldio'] += [['=w', f, [], f + '.bin']]

    # master
    prm['oplevel'] = 5
    cwd = os.getcwd()
    d0 = os.path.join('run', 'oplevel%s' % prm['oplevel']) + os.sep
    os.makedirs(d0)
    os.chdir(d0)
    cst.sord.run(prm)
    os.chdir(cwd)

    # variations
    max_err_all_ = 0.0
    for i in 6,:
        prm['oplevel'] = i
        d = os.path.join(cwd, 'run', 'oplevel%s' % i)
        os.makedirs(d)
        os.chdir(d)
        job = cst.sord.run(prm)
        os.chdir(cwd)
        max_err_ = 0.0
        for f in cst.sord.fieldnames.volume:
            f1 = d0 + f + '.bin'
            f2 = d + f + '.bin'
            v1 = np.fromfile(f1, job.dtype)
            v2 = np.fromfile(f2, job.dtype)
            dv = v1 - v2
            e = np.abs(dv).max()
            if e:
                e = 0.5 * e / (np.abs(v1).max() + np.abs(v2).max())
                print('%s error: %s' % (f, e))
                max_err_ = max(max_err_, e)
        print('max error: ', max_err_)
        max_err_all_ = max(max_err_all_, max_err_)
    assert max_err_all_ == 0.0

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

