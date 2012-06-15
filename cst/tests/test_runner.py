#!/usr/bin/env python

import os
import cst, hello_mpi

path = os.path.join(cst.__path__[0], 'tests')
hello_mpi.build()
cst.sord.build()
cst.util.launch(
    stagein = ['test_suite.py'],
    launch_command = "python ./test_suite.py",
    name = 'test_suite',
    nproc = 6,
    minutes = 30,
)

