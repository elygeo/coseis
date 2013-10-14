#!/usr/bin/env python

import os, shutil
import cst.tests

cst.tests.hello.make()
cst.sord.make()

p = os.path.dirname(__file__) + os.sep
d = os.path.join('run', 'test_suite')
os.makedirs(d)
shutil.copy2(p + 'test_suite.py', d)
cst.util.launch(
    path = d,
    launch = "{python} ./test_suite.py",
    nproc = 6,
    minutes = 30,
)

