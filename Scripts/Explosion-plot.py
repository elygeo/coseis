#!/usr/bin/env python
import os
import math
import json
import numpy as np
import matplotlib.pyplot as plt
import cst.dsp
import cst.coord

os.chdir('repo/Explosion')

d = json.load(open('parameters.json'))
dx, dy, dz, dt = d['delta']
tau = d['pxx'][-1]
rho = d['rho']
vp = d['vp']
vs = d['vs']

meta = json.load(open('meta.json'))
reg = meta['indices']['p1-vx.bin'][0]

for sta in 'p1', 'p2', 'p3', 'p4', 'p5', 'p6':

    # read time histories
    vx = np.load(sta + '-vx.npy')
    vy = np.load(sta + '-vy.npy')
    vz = np.load(sta + '-vz.npy')
    nt = vz.shape[0]
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
    va = (
        m0 * np.exp(-t / tau) * (t * vp / r - t / tau + 1.0) /
        (4.0 * np.pi * rho * vp * vp * vp * tau * tau * r)
    )

    # lowpass filter
    cutoff = 0.0
    cutoff = vp / (20.0 * dx)
    if cutoff:
        v = cst.dsp.filter(v,  dt, cutoff, 'lowpass', 2, 1)
        va = cst.dsp.filter(va, dt, cutoff, 'lowpass', 2, 1)

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
        fig.savefig('Explosion.svg')
    fig.show()
