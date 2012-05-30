#!/usr/bin/env python
"""
Run all tests using Nose for test discovery.
"""

import os
import cst

# find tests directory
rundir = os.path.join(cst.__path__[0], 'tests')

# nose command line
command = "nosetests -v --where=%s" % rundir

# configure MPI launch command for host machine
# some machines require running from script,
# but we do not want to [mpiexec|cobalt-mpirun] nosetests
job = cst.util.prepare(name='runtests', nproc=6, seconds=600)

# serial nosetest job, MPI sub-jobs.
# mode does not affect submit command. 
cst.util.launch(job, command=command, rundir=rundir, mode='s')

