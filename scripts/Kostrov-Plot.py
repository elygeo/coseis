#!/usr/bin/env python
import os, json
import numpy as np
import matplotlib.pyplot as plt
import cst

# parameters
path = 'run' + os.sep
d = open(path + 'meta.json')
d = json.load(d)
dtype = d['dtype']
d = open(path + 'parameters.json')
d = json.load(d)
shape = d['shape']
delta = d['delta']
vrup = d['vrup']
rho = 2670.0
vp = 6000.0
vs = 3464.0
dtau = 10e6
nt = shape[-1]
dt = delta[-1]

# setup figure
fig = plt.figure()
ax = fig.add_subplot(111)

# plot slip velocity
for n in 20, 40:
    r = n * delta[0]
    t = np.arange(0.5, nt) * dt
    vf = cst.kostrov.slip_rate(rho, vp, vs, vrup, dtau, r, t[-1] - r / vrup)
    v = cst.kostrov.slip_rate(rho, vp, vs, vrup, dtau, r, t)
    ax.plot(t + r / vrup, v, 'k--')
    print( 'radius %s' % r)
    for a, color in zip('abcd', 'mrgb'):
        s = 'p%s%s.bin' % (n, a)
        f = os.path.join(path, s)
        v = np.fromfile(f, dtype)
        ax.plot(t - dt, v, color)
        err = (v[-1] - vf) / vf * 100.0
        print( 'point %s, %.1f%% error' % (a, err))

# finish figure
ax.set_xlim(0.0, t[-1])
ax.set_xlabel('Time (s)')
ax.set_ylabel('Slip velocity (m/s)')
f = os.path.join(path, 'Kostrov.pdf')
fig.savefig(f)

