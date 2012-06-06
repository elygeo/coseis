#!/usr/bin/env python
"""
Run all tests using Nose for test discovery.
"""

import os
import cst

path = os.path.join(cst.__path__[0], 'tests')
cst.sord.build()
cst.util.launch(
    launch_command = "nosetests -v --where=" + path
    name = 'nose',
    nproc = 6,
    minutes = 20,
    force = True
)

