#!/usr/bin/env python3
"""
PEER Lifelines program task 1A02, Problem SC2.1
"""
import os
import json
import numpy as np
import matplotlib.pyplot as plt
import cst.signal

# sim dir
p = os.path.join('..', 'Repository', 'PEER-SC2.1-0200')
p = os.path.join('..', 'Repository', 'PEER-SC2.1-2000')
p = os.path.join('..', 'Repository', 'PEER-SC2.1-0500')
p = os.path.join('..', 'Repository', 'PEER-SC2.1-0100')
os.chdir(p)

# parameters
meta = json.load(open('meta.json'))
dt = meta['delta'][-1]
nt = meta['shape'][-1]
tau = meta['tau']
dtype = meta['dtype']
sigma = 0.5

# read time history
x = np.fromfile('p4-v1.bin', dtype)
y = np.fromfile('p4-v2.bin', dtype)
z = np.fromfile('p4-v3.bin', dtype)
v = np.array([x, y, z])
t = dt * np.arange(nt)

# rotate to radial coordinates
m = (-3, 4, 0), (-4, -3, 0), (0, 0, 5)
m = np.array(m) * 0.2
v = np.dot(m, v)

# deconvolve Brune pulse and replace with Gaussian
v = cst.signal.brune2gauss(v, dt, tau, sigma)
print(np.sqrt(np.sum(v * v, 0).max()))

# setup figure
if 0:
    plt.rc('font', size=7)
    plt.rc('axes', linewidth=0.5, titlesize=7)
    plt.rc('lines', linewidth=0.5)
    plt.rc('ytick.major', size=2)
    plt.rc('xtick.major', size=2)
    plt.rc('legend', fontsize='medium', handletextpad=0.2)
fig = plt.figure(None, figsize=(6.4, 6.4), dpi=100)
fig = plt.figure()
ax = [fig.add_subplot(3, 1, i) for i in (1, 2, 3)]
ax[2].set_xlabel('Time (/s)')
ax[1].set_ylabel('Velocity (m/s)')
ax[0].set_title('Radial',     position=(0.98, 0.83), ha='right', va='center')
ax[1].set_title('Transverse', position=(0.98, 0.83), ha='right', va='center')
ax[2].set_title('Vertical',   position=(0.98, 0.83), ha='right', va='center')
ax[0].set_xticklabels([])
ax[1].set_xticklabels([])

# plot waveforms
ax[0].plot(t[:v[0].size], v[0], 'k')
ax[1].plot(t[:v[1].size], v[1], 'k')
ax[2].plot(t[:v[2].size], v[2], 'k')

# axes limits
if 0:
    axis = 0, 50, -0.1, 0.1
    ax[0].axis(axis)
    ax[1].axis(axis)
    ax[2].axis(axis)

# finish up
fig.canvas.draw()
fig.savefig('PEER-SC2.1.pdf', format='pdf')
fig.show()
