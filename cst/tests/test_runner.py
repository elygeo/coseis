#!/usr/bin/env python

import os, shutil
import cst.tests

cst.tests.hello.make()
cst.sord.make()

cwd = os.getcwd()
d = os.path.join('run', 'test_suite')
os.makedirs(d)
shutil.copy2('test_suite.py', d)
os.chdir(d)
job = cst.util.launch(
    mode = 'script',
    execute = 'python test_suite.py',
    nproc = 6,
    minutes = 30,
)
os.chdir(cwd)

