#!/usr/bin/env python
"""
SORD tests
"""
import subprocess, shutil
import numpy as np
import cst

def test_point():
    """
    Test SORD parallelization with point source
    """

    # parameters
    run = 'exec'
    argv = []
    force = True
    debug = 0
    itstats = 1
    shape = 5, 4, 2, 2
    delta = 100.0, 100.0, 100.0, 0.0075
    bc1 = 0, 0, 0
    bc2 = 0, 0, 0

    # source
    source = 'potency'
    ihypo = 1.5, 1.5, 1.5
    ihypo = 3.0, 1.5, 1.5
    source1 = 1e10, 1e10, 1e10
    source2 =  0.0,  0.0,  0.0
    pulse = 'delta'

    # material
    hourglass = 1.0, 1.0
    fieldio = [
        ('=', 'rho', [], 2670.0),
        ('=', 'vp',  [], 6000.0),
        ('=', 'vs',  [], 3464.0),
        ('=', 'gam', [], 0.3),
    ]

    # output
    for f in cst.sord.fieldnames.volume:
        fieldio += [('=w', f, [], 'out/' + f + '.bin')]

    # single process
    rundir = 'tmp/s'
    cst.sord.run(locals())

    # multiple processes
    for i, nproc3 in enumerate([(3, 1, 1), (2, 2, 1)]):
        rundir = 'tmp/%s' % i
        cst.sord.run(locals())
        maxerr_ = 0.0
        for f in cst.sord.fieldnames.volume:
            f1 = 'tmp/s/out/%s.bin' % f
            f2 = 'tmp/%s/out/%s.bin' % (i, f)
            v1 = np.fromfile(f1, 'f')
            v2 = np.fromfile(f2, 'f')
            dv = v1 - v2
            e = (dv * dv).max()
            if e:
                e /= (v1 * v1).max()
                maxerr_ = max(maxerr_, e)
                print('%s %s' % (f, e))
        assert maxerr_ < 1e-7

    # cleanup
    shutil.rmtree('tmp')

# continue if command line
if __name__ == '__main__':
    test_point()

