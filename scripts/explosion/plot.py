#!/usr/bin/env python
"""
Explosion test plot
"""
import os, math, yaml
import numpy as np
import matplotlib.pyplot as plt
import cst

# material properties
meta = os.path.join('run', 'material.json')
meta = yaml.load(open(meta))
rho = meta['rho'][0]
vp = meta['vp'][0]
vs = meta['vs'][0]

# metadata
meta = os.path.join('run', 'meta.yaml')
meta = yaml.load(open(meta))
nx, ny, nz, nt = meta['args']['shape']
dx, dy, dz, dt = meta['args']['delta']
dtype = meta['dtype']
ihypo = meta['p11'][0]
tau = meta['p11'][-1]

print 111111, ihypo, tau
asdf

# loop over stations
for sta in 'p1', 'p2', 'p3', 'p4', 'p5', 'p6':

    # read time histories
    p = os.path.join('run', sta)
    v1 = np.fromfile(p + '-v1.bin', dtype)
    v2 = np.fromfile(p + '-v2.bin', dtype)
    v3 = np.fromfile(p + '-v3.bin', dtype)
    v = np.array([v1, v2, v3])

    # source receiver radius
    xi, yi, zi = meta['xis'][sta + '-v1.bin']
    x = (xi - ihypo[0]) * dx,
    y = (yi - ihypo[1]) * dy,
    z = (zi - ihypo[2]) * dz,
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
    #ax.plot(ta - dt, va, 'k--')
    ax.set_xlim(0.5, dt * nt)
    ax.legend(['v_r', 'v_t1', 'v_t2', 'v_a'])
    ax.set_title(str(tuple(x)))
    if sta == 'p2':
        name = 'Explosion point source'
        ax.set_title(name + ' ' + str(x, y, z))
        f = os.path.join('run', 'Explosion.png')
        fig.savefig(f)
    fig.show()

