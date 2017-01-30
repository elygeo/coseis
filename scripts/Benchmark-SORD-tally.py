#!/usr/bin/env python
import os
import json
import numpy as np

out = []
for p in os.listdir('.'):
    meta = p + '/meta.json'
    if os.path.exists(meta):
        meta = json.load(open(meta))
        x, y, z = meta['nproc3']
        n = x * y * z
        f = p + '/prof-8step.bin'
        t = np.fromfile(f, meta['dtype'])
        t = float(t[1:-1].mean())
        out.append('[%s, %s]' % (n, t))
out = '[\n' + ',\n'.join(out) + '\n]\n'

x, y, z = meta['shape'][:3]
m = x * y * z
f = 546 * m / t / 10 ** 12
print('Elements per core: %s' % (m / n))
print('TFlops: %s' % f)
print('[Cores, Time/Step]')
print(out)
