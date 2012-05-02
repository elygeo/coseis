#!/usr/bin/env python
import cst
import pprint

command = "nosetests --where=%s/tests" % cst.path
job = cst.util.prepare(command=command, seconds=600, nproc=6, rundir='.')
job.mode = 's'
pprint.pprint(job.__dict__)

#cst.util.launch(job)

