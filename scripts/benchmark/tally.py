#!/usr/bin/env python
"""
Tally benchmarks
"""
import os, imp, glob
import numpy as np
import matplotlib.pyplot as plt

normalize = 0
procs = []
times = []

for path in glob.glob('run/[0-9]*'):
    path += os.sep
    meta = imp.load_source('meta', path + 'meta.py')
    n = np.array(meta.nproc3)
    t = np.fromfile(path + 'prof/8step', 'f')
    procs.append(n.prod())
    times.append(t[1:-1].mean())

times = np.array(times)
if normalize:
    times /= times[0]

print 'cores time ideal'
for n, t in zip(procs, times):
    print('%5d %4.2f %4.2f' % (n, t, times[0]))

if 1:
    n = times.size
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(times, 'ko-')
    ax.plot([0, n], [times[0], times[0]], 'k--')[0].set_dashes((4,2))
    ax.set_xticks(range(n))
    ax.set_xticklabels(procs)
    ax.set_title('SORD weak scaling benchmark - TACC Ranger')
    ax.set_xlabel('Cores')
    if normalize:
        ax.set_ylabel('Normalized run time')
        ax.axis([0, n-1, 0, 2])
    else:
        ax.set_ylabel('Time/step (s)')
        h = 2 * int(times.mean() + 0.5)
        ax.axis([0, n-1, 0, h])
    ax.legend(('Time to solution', 'Ideal'))
    fig.savefig('sord-benchmark.pdf', format='pdf')

