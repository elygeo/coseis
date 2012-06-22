#!/usr/bin/env python
"""
Tally benchmarks
"""
import os, imp, glob
import numpy as np

label = 'ACLF BG/Q'
procs = []
times = []

for path in glob.glob('run/bench[0-9]*'):
    meta = os.path.join(path, 'meta.py')
    meta = imp.load_source('meta', meta)
    f = os.path.join(path, 'prof-8step.bin')
    if os.path.exists(f):
        t = np.fromfile(f, meta.dtype)
        x, y, z = meta.nproc3
        n = x * y * z
        procs.append(n)
        times.append(t[1:-1].mean())

print 'time cores'
for i in np.argsort(procs):
    print('%4.2f %d' % (times[i], procs[i]))

if 0:
    import matplotlib.pyplot as plt
    n = len(times)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(times, 'ko-')
    ax.plot([0, n], [times[0], times[0]], 'k--')[0].set_dashes((4,2))
    ax.set_xticks(range(n))
    ax.set_xticklabels(procs)
    ax.set_title('SORD weak scaling benchmark - ' + label)
    ax.set_xlabel('Cores')
    ax.set_ylabel('Time/step (s)')
    h = 2 * int(np.mean(times) + 0.5)
    ax.axis([0, n-1, 0, h])
    fig.savefig('run/sord-benchmark.pdf', format='pdf')

