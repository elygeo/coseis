#!/usr/bin/env python
import cst

command = "nosetests --where=%s/tests" % cst.path
job = cst.util.prepare(command=command, seconds=600, nproc=6, rundir='.')
job.mode = 's'
cst.util.launch(job)

