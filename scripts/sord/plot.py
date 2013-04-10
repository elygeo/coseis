#!/usr/bin/env python
import json
import numpy as np
import matplotlib.pyplot as plt
path = 'run/'
meta = json.load(open(path + 'meta.json'))
n  = meta['shape'][1], meta['shape'][0]
vx = np.fromfile(path + 'vx.bin', meta.dtype).reshape(n)
vy = np.fromfile(path + 'vy.bin', meta.dtype).reshape(n)
vm = np.sqrt(vx * vx + vy * vy)
fig = plt.figure(figsize=(3,3))
ax = plt.gca()
ax.imshow(vm, extent=(-3,3,-3,3), interpolation='nearest', vmax=1)
ax.axis('image')
fig.savefig(path + 'example.png', dpi=80)
