#!/usr/bin/env python
"""
Setup Coseis
"""

# module test
import os, sys
if __name__ != '__main__':
    sys.exit('Error, not a module: %s' % __file__)

# command line args
import getopt
opts, args = getopt.getopt(sys.argv[1:], 'v', ['verbose', 'machine='])
machine = None
for k, v in opts:
    if k == '--machine':
        machine = os.path.basename(opts[0][1])

# configure
import pprint
from cst import util
cf = util.configure(None, machine, save_site=True)[0]
if machine or cf.verbose:
    print(cf.__doc__)
if cf.verbose:
    print(cf.__doc__)
    cf = cf.__dict__
    del cf['__doc__']
    pprint.pprint(cf)

# setup target
import shutil
import cst
for target in args:
    if target == 'build':
        cst.sord._build()
        cst.cvms._build()
        cst.util.build()
    elif target == 'cvms':
        cst.cvms._build(version='2.2')
        cst.cvms._build(version='3.0')
        cst.cvms._build(version='4.0')
    elif target == 'clean':
        d = os.path.dirname(__file__)
        f = os.path.join(d, 'cst', 'build')
        if os.path.exists(f):
            shutil.rmtree(f)
        for f in 'rspectra.so', 'interpolate.so':
            f = os.path.join(d, 'cst', f)
            if os.path.exists(f):
                os.unlink(f)
    elif target == 'test':
        import nose
        argv = ['', '--verbose', '--with-doctest', '--all-modules', '--exe']
        nose.run(argv=argv)
    else:
        sys.exit('Unknown target')

