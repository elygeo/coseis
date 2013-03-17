#!/usr/bin/env python

if __name__ != '__main__':
    raise Exception('not a module')

import sys, pprint, subprocess
import cst.tests

target = sys.argv[1:]
if target == []:
    cfg = cst.util.configure()
    doc = cfg.doc
    del(cfg['doc'])
    pprint.pprint(cfg)
    print(doc)
elif target == ['sord']:
    cst.sord.make()
elif target == ['build']:
    cst.tests.hello.make()
    cst.sord.make()
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
    cst
elif target[0] == 'clean':
    subprocess.call(['git', 'clean', '-x'] + target[1:])
else:
    raise Exception(target)

