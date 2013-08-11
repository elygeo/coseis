#!/usr/bin/env python

import os, shutil
import cst.tests

cst.tests.hello.make()
cst.sord.make()

path = os.path.dirname(__file__) + os.sep
cwd = os.getcwd()
d = os.path.join('run', 'test_suite')
os.makedirs(d)
shutil.copy2(path + 'test_suite.py', d)
os.chdir(d)
cst.util.launch(
    launch = "{python} ./test_suite.py",
    nproc = 6,
    minutes = 30,
)
os.chdir(cwd)

