#!/usr/bin/env python
"""
SORD tests
"""
import subprocess, shutil
import cst

def test_pml():
    """
    Test SORD parallelization with PML
    """

    # parameters
    run = 'exec'
    argv = []
    force = True
    debug = 0
    itstats = 1
    shape = 21, 21, 21, 11
    delta = 100.0, 100.0, 100.0, 0.0075
    bc1 = 10, 10, 10
    bc2 = 10, 10, 10

    # source
    source = 'potency'
    ihypo = 11, 11, 11
    source1 = 1e10, 1e10, 1e10
    source2 =  0.0,  0.0,  0.0
    timefunction = 'delta'

    # material
    hourglass = 1.0, 1.0
    fieldio = [
        ( '=', 'rho', [], 2670.0 ),
        ( '=', 'vp',  [], 6000.0 ),
        ( '=', 'vs',  [], 3464.0 ),
        ( '=', 'gam', [], 0.3 ),
    ]

    # output
    for f in cst.sord.fieldnames.volume:
        fieldio += [ ('=w', f, [], f) ]

    # single process
    rundir = 'tmp/s'
    cst.sord.run( locals() )

    # multiple processes
    for i, nproc3 in enumerate( [(4, 1, 1), (1, 2, 3)] ):
        rundir = 'tmp/%s' % i
        cst.sord.run( locals() )
        cmd_ = (
            'diff',
            '--brief',
            '--recursive',
            '--exclude=prof',
            '--exclude=conf.py',
            '--exclude=meta.py',
            '--exclude=material.py',
            '--exclude=parameters.py',
            '--exclude=sord-sO4',
            '--exclude=sord-mO4',
            'tmp/s', rundir,
        )
        pid_ = subprocess.Popen( cmd_, stdout=subprocess.PIPE )
        out_ = pid_.communicate()[0]
        print out_
        assert out_ == ''

    # cleanup
    shutil.rmtree( 'tmp' )

# continue if command line
if __name__ == '__main__':
    test_pml()

