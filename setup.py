#!/usr/bin/env python
if __name__ != '__main__':
    raise Exception('not a module')

import os, sys, shutil, pprint
import cst

target = sys.argv[1:]
if target == []:
    cfg = cst.util.configure()[0]
    doc = cfg.doc
    del(cfg['doc'])
    pprint.pprint(cfg)
    print(doc)
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
    raise Exception(target)

