#!/usr/bin/env python
"""
Run all tests using Nose for test discovery.
"""

import os
import cst

path = os.path.join(cst.__path__[0], 'tests')
cmd = "nosetests -v --where=" + path
job = cst.util.launch(launch_command=cmd, nproc=6, seconds=600, force=True)

