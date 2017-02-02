#!/usr/bin/env python
import os
import cst.bin2npy
import numpy as np
import matplotlib.pyplot as plt

# simulation directory
d = cst.repo + 'SORD-Exampls'
os.chdir(d)
cst.bin2npy()

# read slices
vx = np.load('vx.npy')
vy = np.load('vy.npy')
vm = np.sqrt(vx * vx + vy * vy)

# plot figure
fig = plt.figure(figsize=(3, 3))
ax = plt.gca()
ax.imshow(vm, extent=(-3, 3, -3, 3), interpolation='nearest')
ax.axis('image')
fig.savefig('SORD-Example.png', dpi=80)
fig.savefig('SORD-Example.svg', dpi=80)
