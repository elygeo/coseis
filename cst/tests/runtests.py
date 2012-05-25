#!/usr/bin/env python
import cst
import pprint

script = "nosetests --where=%s/tests" % cst.__path__[0]
job = cst.util.prepare(script=script, seconds=600, nproc=6)
job.mode = 's'
pprint.pprint(job.__dict__)
#cst.util.launch(job)

