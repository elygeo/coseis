#!/usr/bin/env python
"""
Sumbit nosetest to batch queue
"""

import os
import cst

path = os.path.join(cst.__path__[0], 'tests')
cst.sord.build()
cst.util.launch(
    launch_command = "nosetests -v --where=" + path,
    run = 'submit',
    name = 'nose',
    force = True,
    nproc = 6,
    minutes = 10,
)

