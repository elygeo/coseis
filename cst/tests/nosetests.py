#!/usr/bin/env python
"""
Run all tests using Nose for discovery.

Interactive: python nosetests.py -i 
Batch queue: python nosetests.py -q 
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

