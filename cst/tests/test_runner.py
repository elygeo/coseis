#!/usr/bin/env python
"""
Submit test runner to batch queue
"""

import os
import cst

path = os.path.join(cst.__path__[0], 'tests')
cst.sord.build()
cst.util.launch(
    stagein = ['test_suite.py'],
    launch_command = "python ./test_suite.py",
    name = 'test_suite',
    force = True,
    nproc = 6,
    minutes = 30,
)

