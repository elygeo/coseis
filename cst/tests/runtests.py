#!/usr/bin/env python
import os
import cst

rundir = os.path.join(cst.__path__[0], 'tests')
command = "nosetests --where=%s" % rundir
job = cst.util.prepare(nproc=6, seconds=600)
cst.util.launch(job, command=command, rundir=rundir, mode='s')

