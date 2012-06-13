#!/usr/bin/env python
if __name__ != '__main__':
    raise Exception('not a module')

import os, sys, shutil, pprint
import cst

target = sys.argv[1:]
if target == []:
    cfg = cst.util.configure()
    doc = cfg.doc
    del(cfg['doc'])
    pprint.pprint(cfg)
    print(doc)
elif target == ['sord']:
    cst.sord.build(mode='m')
elif target == ['build_all']:
    cst.sord.build()
    cst.cvms.build()
    cst.cvmh.cvmh_voxet()
    cst.cfm.catalog()
    cst.data.mapdata()
    cst.data.etopo1()
    cst.data.globe30()
    cst.data.lsh_cat()
    cst.data.engdahl_cat()
    import cst.rspectra
    import cst.trinterp
elif target == ['clean']:
    path = os.path.dirname(cst.__file__)
    d = os.path.join(path, 'build')
    if os.path.exists(d):
        shutil.rmtree(d)
    for d in '', 'sord', 'sord/src', 'cvms', 'tests':
        d = os.path.join(path, d) 
        for f in os.listdir(d):
            e = os.path.splitext(f)[-1]
            if e in ('.pyc', '.so', '.o', '.x', '.mod', '.ipo', '.il', '.stb', '.sha1'):
                f = os.path.join(d, f)
                os.unlink(f)
else:
    raise Exception(target)

