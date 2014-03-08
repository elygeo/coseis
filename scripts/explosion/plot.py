#!/usr/bin/env python
"""
Explosion test plot
"""
import os, math, json
import numpy as np
import matplotlib.pyplot as plt
import cst

path = os.path.join('run') + os.sep

# parameters
meta = open(path + 'parameters.json')
meta = json.load(meta)
nx, ny, nz, nt = meta['shape']
dx, dy, dz, dt = meta['delta']
tau = meta['pxx'][-1]
rho = meta['rho']
vp = meta['vp']
vs = meta['vs']

# metadata
meta = open(path + 'meta.json')
meta = json.load(meta)
dtype = meta['dtype']
reg = meta['indices']['p1-vx.bin'][0]

# loop over stations
for sta in 'p1', 'p2', 'p3', 'p4', 'p5', 'p6':

    # read time histories
    p = os.path.join('run', sta)
    vx = np.fromfile(p + '-vx.bin', dtype)
    vy = np.fromfile(p + '-vy.bin', dtype)
    vz = np.fromfile(p + '-vz.bin', dtype)
    v = np.array([vx, vy, vz])

    # source receiver radius
    xi, yi, zi = meta['indices'][sta + '-vx.bin']
    x = (xi - reg) * dx
    y = (yi - reg) * dy
    z = (zi - reg) * dz
    r = math.sqrt(x * x + y * y + z * z)

    # rotation to radial coordinates
    v = cst.coord.dotmv(cst.coord.rotmat([x, y, z]), v)

    # analytical solution
    m0 = 3.0 * rho * vp * vp - 4.0 * rho * vs * vs
    t = np.arange(0.5, nt) * dt
    ta = t + r / vp
    va = (m0 * np.exp(-t / tau) * (t * vp / r - t / tau + 1.0)
            / (4.0 * np.pi * rho * vp * vp * vp * tau * tau * r))

    # lowpass filter
    cutoff = 0.0
    cutoff = vp / (20.0 * dx)
    if cutoff:
        v  = cst.signal.filter(v,  dt, cutoff, 'lowpass', 2, 1)
        va = cst.signal.filter(va, dt, cutoff, 'lowpass', 2, 1)

    # plot figure
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(t - dt, v.T, '-')
    ax.plot(ta - dt, va, 'k--')
    ax.set_xlim(0.5, dt * nt)
    ax.legend(['v_r', 'v_t1', 'v_t2', 'v_a'])
    ax.set_title(x)
    if sta == 'p2':
        name = 'Explosion point source'
        ax.set_title(name + ' ' + str([x, y, z]))
        f = os.path.join('run', 'Explosion.png')
        fig.savefig(f)
    fig.show()

