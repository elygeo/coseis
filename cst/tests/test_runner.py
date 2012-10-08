#!/usr/bin/env python

import os, shutil
import cst.tests

cst.tests.hello.make()
cst.sord.make()

cwd = os.getcwd()
os.chdir(os.path.dirname(__file__))
d = 'run/test_suite'
os.makedirs(d)
shutil.copy2('test_suite.py', d)

cst.util.launch(
    rundir = d,
    launch = "python ./test_suite.py",
    nproc = 6,
    minutes = 30,
)

os.chdir(cwd)

