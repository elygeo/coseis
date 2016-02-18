#!/usr/bin/env python
"""Test SORD parallelization with PML"""
import os
import json
import numpy as np
import cst


def test(**kwargs):

    # parameters
    prm = {
        'itstats': 1,
        'shape': [22, 22, 22, 11],
        'delta': [100.0, 100.0, 100.0, 0.0075],
        'rho': [2670.0],
        'vp': [6000.0],
        'vs': [3464.0],
        'gam': [0.3],
        'hourglass': [1.0, 1.0],
        'bc1': ['pml', 'pml', 'pml'],
        'bc2': ['pml', 'pml', 'pml'],
    }

    # output
    fns = cst.sord.fieldnames()
    for k, v in fns.items():
        if v[0][0] in 'nc':
            prm[k] = [([], '=>',  k + '.bin')]

    # potency source
    prm['pxx'] += [([10, 10, 10, 0], '=', 1e10)]
    prm['pyy'] += [([10, 10, 10, 0], '=', 1e10)]
    prm['pzz'] += [([10, 10, 10, 0], '=', 1e10)]

    # master
    cwd = os.getcwd()
    d0 = os.path.join('run', 'sord_pml') + os.sep
    os.makedirs(d0)
    os.chdir(d0)
    cst.sord.run(prm, **kwargs)
    meta = open('meta.json')
    dtype = json.load(meta)['dtype']
    os.chdir(cwd)

    # variations
    max_err_all_ = 0.0
    for i, n in enumerate([[4, 1, 1], [1, 2, 3]]):
        prm['nproc3'] = n
        d = os.path.join('run', 'sord_pml%s' % i) + os.sep
        os.makedirs(d)
        os.chdir(d)
        cst.sord.run(prm, **kwargs)
        os.chdir(cwd)
        max_err_ = 0.0
        for k in fns:
            f1 = d0 + k + '.bin'
            f2 = d + k + '.bin'
            v1 = np.fromfile(f1, dtype)
            v2 = np.fromfile(f2, dtype)
            dv = v1 - v2
            e = np.abs(dv).max()
            if e:
                e /= np.abs(v1).max()
                print('%s error: %s' % (k, e))
                max_err_ = max(max_err_, e)
        print('max error: ', max_err_)
        max_err_all_ = max(max_err_all_, max_err_)
    assert max_err_all_ == 0.0


if __name__ == '__main__':
    test()
