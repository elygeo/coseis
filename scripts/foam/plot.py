#!/usr/bin/env python
import os, json
import numpy as np
import matplotlib.pyplot as plt

# metadata
id_ = '00'
id_ = '20'
path = os.path.join('run', id_) + os.sep
meta = json.load(path + 'meta.json')
dtype = meta.dtype

# off-fault displacement plot
f = 'off-fault.bin'
n = meta['shapes'][f]
d = meta['deltas'][f]
s = np.fromfile(path + f, dtype).reshape(n[::-1]).T
e = np.diff(s[:,-1]) / d[0]
i = int(0.05 / d[1])
s = -1000.0 * s[:,i:]
extent = 0, (n[0] - 1) * d[0] * 100.0, i * d[1] * 1000.0, (n[1] - 1) * d[1] * 1000.0
fig = plt.figure(figsize=(4.8, 6.4))
ax = fig.add_subplot(111)
im = ax.imshow(s.T, interpolation='nearest', origin='lower', aspect='auto', extent=extent)
ax.set_title('Surface displacement (mm)')
ax.set_xlabel('Distance from fault (cm)')
ax.set_ylabel('Time (ms)')
fig.colorbar(im)
fig.savefig(path + 'foam-%s-off-fault.png' % id_)
fig.show()

# approximate static strain
x = np.arange(n[0] - 1) * d[0] * 100.0 + d[0] * 50.0
fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(x, e, 'k-')
ax.set_xlabel('Distance from fault (cm)')
ax.set_ylabel('Strain')
fig.savefig(path + 'foam-%s-strain.pdf' % id_)
fig.show()

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
    f = 'sensor%02d.bin' % s
    dt = meta['deltas'][f][-1] * 1000.0
    a = np.fromfile(path + f, dtype) / 9.81
    t = np.arange(a.size) * dt
    ax.plot(t, x + a * 0.5, 'k-')
    ax.text(22, x - 1, '%.0f' % abs(a).max())
    axis = 20, 80, 109, -19
    ax.axis(axis)
    ax.set_title('Acceleration')
    ax.set_xlabel('Time (ms)')
    ax.set_ylabel('Depth along fault (cm)')
fig.savefig(path + 'foam-%s-acceleration.pdf' % id_)
fig.show()

