#!/usr/bin/env python

import cst.tests

cst.tests.hello_mpi.build()
cst.sord.build()
cst.util.launch(
    stagein = ['test_suite.py'],
    launch = "python ./test_suite.py",
    name = 'test_suite',
    nproc = 6,
    minutes = 30,
)

