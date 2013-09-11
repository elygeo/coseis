#!/usr/bin/env python
import json
import numpy as np
import matplotlib.pyplot as plt
meta = json.load(open('meta.json'))
dtype = meta['dtype']
shape = meta['shape']
n  = shape[1], shape[0]
vx = np.fromfile('vx.bin', dtype).reshape(n)
vy = np.fromfile('vy.bin', dtype).reshape(n)
vm = np.sqrt(vx * vx + vy * vy)
fig = plt.figure(figsize=(3,3))
ax = plt.gca()
ax.imshow(vm, extent=(-3,3,-3,3), interpolation='nearest', vmax=1)
ax.axis('image')
fig.savefig('example.png', dpi=80)
