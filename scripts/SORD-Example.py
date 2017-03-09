#!/usr/bin/env python
import os
import numpy as np
import matplotlib.pyplot as plt
import cst.sord
import cst.bin2npy

prm = {
    'shape': [61, 61, 61, 60],
    'delta': [100.0, 100.0, 100.0, 0.0075],
    'rho': [2670.0],
    'vp':  [6000.0],
    'vs':  [3464.0],
    'gam': [0.3],
    'pxx': [([30, 30, 30, []], '=', 1.0, 'integral_brune', 0.05)],
    'pyy': [([30, 30, 30, []], '=', 1.0, 'integral_brune', 0.05)],
    'pzz': [([30, 30, 30, []], '=', 1.0, 'integral_brune', 0.05)],
    'vx': [([[], [], 30, -1], '=>', 'vx.bin')],
    'vy': [([[], [], 30, -1], '=>', 'vy.bin')],
}

d = '../repo/SORD-Example'
if os.path.exists(d):
    os.chdir(d)
    meta = json.load(open('meta.json'))
else:
    os.mkdir(d)
    os.chdir(d)
    meta = cst.sord.run(prm)

if os.path.exists('vy.bin'):
    vx, vy = cst.bin2npy.load('vx.bin', 'vy.bin', **meta)
    vm = np.sqrt(vx * vx + vy * vy)
    fig = plt.figure(figsize=(3, 3))
    ax = plt.gca()
    ax.imshow(vm, extent=(-3, 3, -3, 3), interpolation='nearest')
    ax.axis('image')
    fig.savefig('SORD-Example.svg', dpi=80)
