#!/usr/bin/env python
import os, json
import numpy as np
import matplotlib.pyplot as plt

# simulation directory
path = 'run' + os.sep

# read metadata
meta = open(path + 'meta.json')
meta = json.load(meta)
dtype = meta['dtype']
shape = meta['shapes']['vx.bin']

# read slices
vx = np.fromfile(path + 'vx.bin', dtype).reshape(shape[::-1])
vy = np.fromfile(path + 'vy.bin', dtype).reshape(shape[::-1])
vm = np.sqrt(vx * vx + vy * vy)

# plot figure
fig = plt.figure(figsize=(3,3))
ax = plt.gca()
#ax.imshow(vm, extent=(-3,3,-3,3), interpolation='nearest', vmax=1)
ax.imshow(vm, extent=(-3,3,-3,3), interpolation='nearest')
ax.axis('image')
fig.savefig(path + 'SORD-Example.png', dpi=80)
