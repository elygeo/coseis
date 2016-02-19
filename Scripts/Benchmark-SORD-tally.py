#!/usr/bin/env python3
import os
import json
import glob
import numpy as np

label = 'ACLF BG/Q'
procs = []
times = []
path = os.path.join('..', 'Repository', 'Benchmark-SORD')

for p in glob.glob(path + '-[0-9]*'):
    p += os.sep
    meta = json.load(open(p + 'meta.json'))
    p = p + 'prof-8step.bin'
    if os.path.exists(p):
        t = np.fromfile(p, meta.dtype)
        x, y, z = meta.nproc3
        n = x * y * z
        procs.append(n)
        times.append(t[1:-1].mean())

json.dumps(zip(times, procs), indent=0)
