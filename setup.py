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
elif target == ['build']:
    cst.interp.build()
    cst.signal.build()
    cst.tests.hello.make()
    cst.sord.make()
elif target == ['data']:
    cst.cvms.make()
    cst.cvmh.cvmh_voxet()
    cst.cfm.catalog()
    cst.data.mapdata()
    cst.data.etopo1()
    cst.data.globe30()
    cst.data.lsh_cat()
    cst.data.engdahl_cat()
elif target[0] == 'clean':
    subprocess.call(['git', 'clean', '-x'] + target[1:])
else:
    raise Exception(target)

