#!/usr/bin/env python
"""
Setup Coseis
"""

# guard against importing since this directory is in the path.
if __name__ != '__main__':
    raise Exception('Error, not a module: %s' % __file__)

import os, sys, shutil, pprint
import cst

target = sys.argv[1:]
if target == []:
    cfg = cst.util.configure(cst.conf.default)[0]
    pprint.pprint(cfg)
    print(cst.conf.default.__doc__)
elif target == ['build_all']:
    cst.util.build_ext()
    cst.util.build_fext()
    cst.sord.build()
    cst.cvms.build()
    cst.cvmh.cvmh_voxet()
    cst.cvms.catalog()
    cst.data.mapdata()
    cst.data.etopo1()
    cst.data.globe30()
    cst.data.lsh_cat()
    cst.data.engdahl_cat()
elif target == ['clean']:
    path = os.path.dirname(cst.__file__)
    d = os.path.join(path, 'build')
    if os.path.exists(d):
        shutil.rmtree(d)
    for d in '', 'sord', 'cvms', 'tests':
        d = os.path.join(path, d) 
        for f in os.listdir(d):
            f = os.path.join(d, f)
            if f.endswith('.pyc') or f.endswith('.so'):
                os.unlink(f)
else:
    raise Exception('Unknown target %s' % target)

