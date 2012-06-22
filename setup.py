#!/usr/bin/env python
if __name__ != '__main__':
    raise Exception('not a module')

import os, sys, pprint, subprocess
import cst.tests

target = sys.argv[1:]
if target == []:
    cfg = cst.util.configure()
    doc = cfg.doc
    del(cfg['doc'])
    pprint.pprint(cfg)
    print(doc)
elif target == ['sord']:
    cst.sord.build()
elif target == ['test']:
    cst.tests.test_suite.test()
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
elif target == ['realclean']:
    subprocess.check_call(['git', 'clean', '-xdf'])
else:
    raise Exception(target)

