#!/usr/bin/env python
"""
Decimate surface output and compute PGV, PGD
"""
import os, json
import numpy as np

# metatdata
path = 'hold/'
meta = json.load(open('meta.json'))
dt = meta.deltas[path + 'full-v1.bin'][-1]
nfull = meta.shapes[path + 'full-v1.bin']
nhist = meta.shapes[path + 'hist-v1.bin']
ifull = meta.indices[path + 'full-v1.bin']
ihist = meta.indices[path + 'hist-v1.bin']
isnap = meta.indices[path + 'snap-v1.bin']
dtype = meta.dtype

# decimation intervals
xdec = ihist[0][2] / ifull[0][2]
tdec = isnap[2][2] / ifull[2][2]

# initialize displacement, pgv, pgd arrays
nn = nfull[:2]
u1 = np.zeros(nn)
u2 = np.zeros(nn)
u3 = np.zeros(nn)
pgv = np.zeros(nn)
pgd = np.zeros(nn)
pgvh = np.zeros(nn)
pgdh = np.zeros(nn)

# open full resolution files for reading
f1 = open(path + 'full-v1.bin', 'rb')
f2 = open(path + 'full-v2.bin', 'rb')
f3 = open(path + 'full-v3.bin', 'rb')

# open snapshot files for writing
s1 = open(path + 'snap-v1.bin', 'wb')
s2 = open(path + 'snap-v2.bin', 'wb')
s3 = open(path + 'snap-v3.bin', 'wb')

# open time history files for writing
h1 = open(path + 'hist-v1.bin', 'wb')
h2 = open(path + 'hist-v2.bin', 'wb')
h3 = open(path + 'hist-v3.bin', 'wb')

# loop over time steps
with f1, f2, f3, s1, s2, s3, h1, h2, h3:
    for it in range(nfull[-1]):

        # read velocity
        n = nfull[0] * nfull[1]
        v1 = np.fromfile(f1, dtype, n).reshape(nn[::-1]).T
        v2 = np.fromfile(f2, dtype, n).reshape(nn[::-1]).T
        v3 = np.fromfile(f3, dtype, n).reshape(nn[::-1]).T

        # integrate to displacement
        u1 = u1 + dt * v1
        u2 = u2 + dt * v2
        u3 = u3 + dt * v3

        # peak ground motions
        pgv = np.maximum(pgv, v1*v1 + v2*v2 + v3*v3)
        pgd = np.maximum(pgd, u1*u1 + u2*u2 + u3*u3)

        # peak horizontal ground motions
        pgvh = np.maximum(pgvh, v1*v1 + v2*v2)
        pgdh = np.maximum(pgdh, u1*u1 + u2*u2)

        # time histories decimates in space
        v1[::xdec,::xdec].T.tofile(h1)
        v2[::xdec,::xdec].T.tofile(h2)
        v3[::xdec,::xdec].T.tofile(h3)

        # snapshots decimated in time
        if np.mod(it, tdec) == 0:
            v1.T.tofile(s1)
            v2.T.tofile(s2)
            v3.T.tofile(s3)

# save pgv, pgd
np.sqrt(pgv).astype(dtype).T.tofile('pgv.bin')
np.sqrt(pgd).astype(dtype).T.tofile('pgd.bin')
np.sqrt(pgvh).astype(dtype).T.tofile('pgvh.bin')
np.sqrt(pgdh).astype(dtype).T.tofile('pgdh.bin')

# free memory
del(v1, v2, v3, u1, u2, u3, pgv, pgd, pgvh, pgdh)

# transpose time history arrays
x, y, t = nhist
n = t, x * y
p = path + 'hist-v%s.bin'
np.fromfile(p % 1, dtype).reshape(n).T.tofile(p % 1)
np.fromfile(p % 2, dtype).reshape(n).T.tofile(p % 2)
np.fromfile(p % 3, dtype).reshape(n).T.tofile(p % 3)

# remove full resolution files and lock file
p = path + 'full-v%s.bin'
os.unlink(p % 1)
os.unlink(p % 2)
os.unlink(p % 3)

