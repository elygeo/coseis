#!/usr/bin/env python
"""
SORD tests
"""
import subprocess, shutil
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
    for i, nproc3 in enumerate( [(3, 1, 1), (2, 2, 1)] ):
        rundir = 'tmp/%s' % i
        cst.sord.run( locals() )
        cmd_ = (
            'diff',
            '--brief',
            '--recursive',
            '--exclude=prof',
            '--exclude=conf.py',
            '--exclude=meta.py',
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
    test_point()

