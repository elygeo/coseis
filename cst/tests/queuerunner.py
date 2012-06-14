#!/usr/bin/env python
"""
Submit test runner to batch queue
"""

import os
import cst

path = os.path.join(cst.__path__[0], 'tests')
cst.sord.build()
cst.util.launch(
    stagein = ['testrunner.py'],
    launch_command = "python ./testrunner.py",
    run = 'submit',
    name = 'tests',
    force = True,
    nproc = 6,
    minutes = 10,
)

