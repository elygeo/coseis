#!/usr/bin/env python
"""
Tally benchmarks
"""
import os, imp, glob
import numpy as np

machine = 'ACLF BG/Q'
procs = []
times = []

for path in glob.glob('run/[0-9]*'):
    path += os.sep
    meta = imp.load_source('meta', path + 'meta.py')
    t = np.fromfile(path + 'prof-8step.bin', meta.dtype)
    x, y, z = meta.nproc3
    n = x * y * z
    procs.append(n)
    times.append(t[1:-1].mean())

print 'cores time'
for nt in zip(procs, times):
    print('%5d %4.2f' % nt)

if 0:
    import matplotlib.pyplot as plt
    n = len(times)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(times, 'ko-')
    ax.plot([0, n], [times[0], times[0]], 'k--')[0].set_dashes((4,2))
    ax.set_xticks(range(n))
    ax.set_xticklabels(procs)
    ax.set_title('SORD weak scaling benchmark - ' + machine)
    ax.set_xlabel('Cores')
    ax.set_ylabel('Time/step (s)')
    h = 2 * int(np.mean(times) + 0.5)
    ax.axis([0, n-1, 0, h])
    fig.savefig('run/sord-benchmark.pdf', format='pdf')

