#!/usr/bin/env python
"""
Setup Coseis
"""
import os, sys, pprint, shutil
import cst

# guard against importing since this directory is in the path.
if __name__ != '__main__':
    sys.exit('Error, not a module: %s' % __file__)

# site specific configuration
cfg = cst.util.configure(sys.argv[1:])[0]
f = os.path.join(cst.path, 'site.py')
open(f, 'w').write("""
machine = {machine!r}
account = {account!r}
""".format(**cfg))
reload(cst.site)

# print configuration
if sys.argv[1:]:
    doc = cfg['__doc__']
    del cfg['__doc__']
    pprint.pprint(doc)
    if cfg['verbose']:
        pprint.pprint(cfg)

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
        for d in '', 'sord', 'cvms', 'tests':
            d = os.path.join(cst.path, d)
            for f in os.listdir(d):
                if f.endswith('.pyc') or f.endswith('.so'):
                    os.unlink(d + f)
    else:
        sys.exit('Unknown target')

