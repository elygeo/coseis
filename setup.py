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
job = cst.util.configure(None, machine, save_site=True)[0]
if machine or job.verbose:
    print(job.__doc__)
if job.verbose:
    print(job.__doc__)
    job = job.__dict__
    del job['__doc__']
    pprint.pprint(job)

# choose a task
for target in args:
    if target == 'build_ext':
        cst.util.build_ext()
    elif target == 'build_fext':
        cst.util.build_fext()
    elif target == 'sord':
        cst.sord._build()
    elif target == 'cvms':
        cst.cvms._build()
    elif target == 'cvmh':
        cst.cvmh.cvmh_voxet()
    elif target == 'cfm':
        cst.cvms.catalog()
    elif target == 'mapdata':
        cst.data.mapdata()
        cst.data.etopo1()
        cst.data.globe30()
    elif target == 'clean':
        try:
            shutil.rmtree('cst/build')
        except OSError:
            pass
        for d in 'cst/', 'cst/sord/', 'cst/cvms/', 'cst/tests/':
            for f in os.listdir(d):
                if f.endswith('.pyc') or f.endswith('.so'):
                    os.unlink(d + f)
    else:
        sys.exit('Unknown target')

