#!/usr/bin/env python
import cst
import pprint

script = "nosetests --where=%s/tests" % cst.path
job = cst.util.prepare(script=script, seconds=600, nproc=6)
job.mode = 's'
pprint.pprint(job.__dict__)
#cst.util.launch(job)

