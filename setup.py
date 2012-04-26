#!/usr/bin/env python
"""
Setup Coseis
"""
import os, sys, getopt, pprint, shutil
import cst

# guard against importing since this directory is in the path.
if __name__ != '__main__':
    sys.exit('Error, not a module: %s' % __file__)

# command line options
opts, args = getopt.getopt(sys.argv[1:], 'v', ['verbose', 'machine='])
machine = None
for k, v in opts:
    if k == '--machine':
        machine = os.path.basename(opts[0][1])

# configure
cf = cst.util.configure(None, machine, save_site=True)[0]
if machine or cf.verbose:
    print(cf.__doc__)
if cf.verbose:
    print(cf.__doc__)
    cf = cf.__dict__
    del cf['__doc__']
    pprint.pprint(cf)

# choose a task
for target in args:
    if target == 'build':
        cst.util.build()
        cst.sord._build()
        cst.cvms._build()
    elif target in ('test', 'tests'):
        import nose
        argv = ['', '--verbose', '--with-doctest', '--all-modules', '--exe']
        nose.run(argv=argv)
    elif target == 'clean':
        d = os.path.join(os.path.dirname(__file__), 'cst') + os.sep
        for f in os.listdir(d):
            if f == 'build':
                shutil.rmtree(d + f)
            if f.endswith('.pyc') or f.endswith('.so'):
                os.unlink(d + f)
    else:
        sys.exit('Unknown target')

