#!/usr/bin/env python
import os, json
import numpy as np
import matplotlib.pyplot as plt

# simulation directory
p = os.path.join('run', 'SORD-Example')
os.chdir(p)

# read metadata
meta = json.load(open('meta.json'))
dtype = meta['dtype']
shape = meta['shapes']['vx.bin']

# read slices
vx = np.fromfile('vx.bin', dtype).reshape(shape[::-1])
vy = np.fromfile('vy.bin', dtype).reshape(shape[::-1])
vm = np.sqrt(vx * vx + vy * vy)

# plot figure
fig = plt.figure(figsize=(3,3))
ax = plt.gca()
#ax.imshow(vm, extent=(-3,3,-3,3), interpolation='nearest', vmax=1)
ax.imshow(vm, extent=(-3,3,-3,3), interpolation='nearest')
ax.axis('image')
fig.savefig('SORD-Example.png', dpi=80)

