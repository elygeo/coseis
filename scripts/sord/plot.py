#!/usr/bin/env python
import imp
import numpy as np
import matplotlib.pyplot as plt
meta = imp.load_source('meta', 'run/meta.py')
n  = meta.shape[1], meta.shape[0]
vx = np.fromfile('run/vx.bin', 'f').reshape(n)
vy = np.fromfile('run/vy.bin', 'f').reshape(n)
vm = np.sqrt(vx * vx + vy * vy)
fig = plt.figure(figsize=(3,3))
ax = plt.gca()
ax.imshow(vm, extent=(-3,3,-3,3), interpolation='nearest', vmax=1)
ax.axis('image')
fig.savefig('run/example.png', dpi=80)
