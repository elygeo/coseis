#!/usr/bin/env python
import os, json
import numpy as np
import matplotlib.pyplot as plt
path = 'run' + os.sep
meta = json.load(open(path + 'meta.json'))
dtype = meta['dtype']
shape = meta['shape']
n  = shape[1], shape[0]
vx = np.fromfile(path + 'vx.bin', dtype).reshape(n)
vy = np.fromfile(path + 'vy.bin', dtype).reshape(n)
vm = np.sqrt(vx * vx + vy * vy)
fig = plt.figure(figsize=(3,3))
ax = plt.gca()
ax.imshow(vm, extent=(-3,3,-3,3), interpolation='nearest', vmax=1)
ax.axis('image')
fig.savefig(path + 'example.png', dpi=80)
