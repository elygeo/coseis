#!/usr/bin/env python
"""
Explosion test plot
"""
import os, json, glob
import numpy as np
import matplotlib.pyplot as plt
import cst

# parameters
runs = 'run/*'
stations = 'p1', 'p2', 'p3', 'p4', 'p5', 'p6'
save_plot = 'p2',
rho, vp, vs = 2670.0, 6000.0, 3464.0

# loop over runs
for path in glob.glob(runs):

    # metadata
    meta = os.path.join(path, 'meta.json')
    meta = json.load(open(meta))
    dtype = meta['dtype']
    shape = meta['shape']
    delta = meta['delta']
    ihypo = meta['ihypo']
    tau = meta['tau']
    source = meta['source']
    source1 = meta['source1']

    # loop over stations
    for sta in stations:

        # read time histories
        p = os.path.join(path, sta)
        v1 = np.fromfile(p + '-v1.bin', dtype)
        v2 = np.fromfile(p + '-v2.bin', dtype)
        v3 = np.fromfile(p + '-v3.bin', dtype)
        e1 = np.fromfile(p + '-e11.bin', dtype)
        e2 = np.fromfile(p + '-e22.bin', dtype)
        e3 = np.fromfile(p + '-e33.bin', dtype)
        v = np.array([v1, v2, v3]).squeeze()
        e = np.array([e1, e2, e3]).squeeze()

        # source receiver radius
        xi = meta.xis[sta + '-v1.bin']
        x = (
            (xi[0] - ihypo[0]) * delta[0],
            (xi[1] - ihypo[1]) * delta[1],
            (xi[2] - ihypo[2]) * delta[2],
        )
        r = np.sqrt(x[0] * x[0] + x[1] * x[1] + x[2] * x[2])

        # rotation to radial coordinates
        v = cst.coord.dotmv(cst.coord.rotmat(x), v)

        # analytical solution
        n = shape[-1]
        dt = delta[-1]
        if source == 'moment':
            m0 = source1[0]
        else:
            m0 = source1[0] * (3.0 * rho * vp * vp - 4.0 * rho * vs * vs)
        t = np.arange(0.5, n) * dt
        ta = t + r / vp
        va = (m0 * np.exp(-t / tau) * (t * vp / r - t / tau + 1.0)
             / (4.0 * np.pi * rho * vp * vp * vp * tau * tau * r))

        # lowpass filter
        cutoff = 0.0
        cutoff = vp / (20.0 * delta[0])
        if cutoff:
            v  = cst.signal.filter(v,  dt, cutoff, 'lowpass', 2, 1)
            va = cst.signal.filter(va, dt, cutoff, 'lowpass', 2, 1)

        # plot figure
        fig = plt.figure()
        ax = fig.add_subplot(111)
        ax.plot(t - dt, v.T, '-', ta - dt, va, 'k--')
        ax.set_xlim(0.5, dt * n)
        ax.legend(['v_r', 'v_t1', 'v_t2', 'v_a'])
        name = os.path.split(path)[-1]
        ax.set_title(name + ' ' + str(tuple(x)))
        if sta in save_plot:
            name = 'Explosion point source'
            ax.set_title(name + ' ' + str(tuple(x)))
            f = os.path.join(path, 'explosion.png')
            fig.savefig(f)
        fig.show()

