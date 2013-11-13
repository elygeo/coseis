#!/usr/bin/env python

import os, shutil
import cst.tests

cst.tests.hello.make()
cst.sord.make()

cwd = os.getcwd()
p = os.path.dirname(__file__)
f = os.path.join(p, 'test_suite.py')
d = os.path.join('run', 'test_suite')
os.makedirs(d)
os.chdir(d)
shutil.copy2(f, '.')
job = cst.util.stage(
    execute = '{python} ./test_suite.py',
    nproc = 6,
    minutes = 30,
)
os.chdir(cwd)

