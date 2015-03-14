#!/usr/bin/env python
import os, json
import numpy as np
import matplotlib.pyplot as plt

# metadata
id_ = '00'
id_ = '20'
p = os.path.join('run', 'Foam-' + id_)
os.chdir(d)
meta = json.load(open('meta.json'))

# off-fault displacement plot
f = 'off-fault'
dx, dy = meta['deltas'][f + '.bin']
s = np.load(f + '.npy')
nx, ny = s.shape
e = np.diff(s[:,-1]) / dx
i = int(0.05 / dy)
s = -1000.0 * s[:,i:]
extent = 0, (nx - 1) * dx * 100.0, i * dy * 1000.0, (ny - 1) * dy * 1000.0
fig = plt.figure(figsize=(4.8, 6.4))
ax = fig.add_subplot(111)
im = ax.imshow(s.T, interpolation='nearest', origin='lower', aspect='auto', extent=extent)
ax.set_title('Surface displacement (mm)')
ax.set_xlabel('Distance from fault (cm)')
ax.set_ylabel('Time (ms)')
fig.colorbar(im)
fig.savefig('Foam-%s-Off-Fault.png' % id_)

# approximate static strain
x = np.arange(nx - 1) * dx * 100.0 + dx * 50.0
fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(x, e, 'k-')
ax.set_xlabel('Distance from fault (cm)')
ax.set_ylabel('Strain')
fig.savefig('Foam-%s-Strain.pdf' % id_)

# acceleration plots
fig = plt.figure(figsize=(4.8, 6.4))
ax = fig.add_subplot(111)
for s, x, g in [
   (1, 92, 0.020074),
   (2, 72, 0.019926),
   (3, 42, 0.020350),
   (4, 22, 0.020166),
  (15,  2, 0.020773),
]:
    f = 'sensor%02d' % s
    dt = meta['deltas'][f + '.bin'][-1] * 1000.0
    a = np.load(f + '.npy') / 9.81
    t = np.arange(a.size) * dt
    ax.plot(t, x + a * 0.5, 'k-')
    ax.text(22, x - 1, '%.0f' % abs(a).max())
    axis = 20, 80, 109, -19
    ax.axis(axis)
    ax.set_title('Acceleration')
    ax.set_xlabel('Time (ms)')
    ax.set_ylabel('Depth along fault (cm)')
fig.savefig('Foam-%s-Acceleration.pdf' % id_)

