#!/usr/bin/env python
import os
import json
import numpy as np

out = []
for p in os.listdir('.'):
    p += os.sep
    f = p + 'prof-8step.bin'
    if os.path.exists(f):
        meta = json.load(open(p + 'meta.json'))
        t = np.fromfile(f, meta['dtype'])
        t = float(t[1:-1].mean())
        x, y, z = meta['nproc3']
        n = x * y * z
        out.append('[%s, %s]' % (n, t))
out = '[\n' + ',\n'.join(out) + '\n]\n'

x, y, z = meta['shape'][:3]
m = x * y * z
f = 546 * m / t / 10 ** 12
print('Elements per core: %s' % (m / n))
print('TFlops estimate: %s' % f)
print('[Cores, Time/Step]')
print(out)
