#!/usr/bin/env python3
import os
import json
import cst.kostrov
import numpy as np
import matplotlib.pyplot as plt

os.chdir(cst.repo + 'Kostrov')

# parameters
meta = json.load(open('parameters.json'))
dx, dy, dz, dt = meta['delta']
vrup = meta['vrup']
nt = meta['shape'][-1]
rho = 2670.0
vp = 6000.0
vs = 3464.0
dtau = 10e6

# setup figure
fig = plt.figure()
ax = fig.add_subplot(111)

# plot slip velocity
for n in 20, 40:
    r = n * dx
    t = np.arange(0.5, nt) * dt
    vf = cst.kostrov.slip_rate(rho, vp, vs, vrup, dtau, r, t[-1] - r / vrup)
    v = cst.kostrov.slip_rate(rho, vp, vs, vrup, dtau, r, t)
    ax.plot(t + r / vrup, v, 'k--')
    print('radius %s' % r)
    for a, color in zip('abcd', 'mrgb'):
        s = 'p%s%s.npy' % (n, a)
        v = np.load(s)
        ax.plot(t - dt, v, color)
        err = (v[-1] - vf) / vf * 100.0
        print('point %s, %.1f%% error' % (a, err))

# finish figure
ax.set_xlim(0.0, t[-1])
ax.set_xlabel('Time (s)')
ax.set_ylabel('Slip velocity (m/s)')
fig.savefig('Kostrov.pdf')
