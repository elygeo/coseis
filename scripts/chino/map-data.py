#!/usr/bin/env python
"""
Map plot
"""
import os, imp
import numpy as np
import matplotlib.pyplot as plt
import pyproj
from obspy.imaging import beachball
import cst

# parameters
eventid = 14383980
bounds = (-80000.0, 48000.0), (-58000.0, 54000.0)
mts = os.path.join('run', 'data', '%s.mts.py' % eventid)
mts = imp.load_source('mts', mts)
origin = mts.longitude, mts.latitude, mts.depth
proj = pyproj.Proj(proj='tmerc', lon_0=origin[0], lat_0=origin[1])

# extent
x, y = bounds
x = x[0], x[1], x[1], x[0]
y = y[0], y[0], y[1], y[1]
x, y = np.array(proj(x, y, inverse=True))
extent = (x.min(), x.max()), (y.min(), y.max())

# setup plot
fig = plt.figure()
fig.clf()
ax = fig.add_axes()

# source
m = mts.double_couple_clvd
m = m['mzz'], m['mxx'], m['myy'], m['mxz'], -m['myz'], -m['mxy']
b = beachball.Beach(m, width=200)
p = []
for c in b.get_paths():
    p += c.to_polygons() + [[[float('nan'), float('nan')]]]
del p[-1]
b = np.concatenate(p) * 0.005
f = os.path.join('run', 'data', 'beachball.txt')
np.savetxt(f, b)

# topography
ddeg = 0.5 / 60.0
z, extent = cst.data.topo(extent)
x, y = extent
n = z.shape
x = x[0] + ddeg * np.arange(n[0])
y = y[0] + ddeg * np.arange(n[1])
y, x = np.meshgrid(y, x)
v = 1000,
x, y = cst.plt.contour(x, y, z, v)[0]
f = os.path.join('run', 'data', 'mountains.txt')
np.savetxt(f, np.array([x, y]).T)

# coastlines and boarders
x, y = cst.data.mapdata('coastlines', 'high', extent, 10.0)
x -= 360.0
f = os.path.join('run', 'data', 'coastlines.txt')
np.savetxt(f, np.array([x, y]).T)

# mesh
ddeg = 0.5 / 60.0
x, y = extent
x = x[0] + ddeg * np.arange(n[0])
y = y[0] + ddeg * np.arange(n[1])
yy, xx = np.meshgrid(y, x)
zz = np.empty_like(xx)

# surface
zz.fill(0.0)
for cvm, vv in [
    ('cvmg', cst.cvmh.extract(xx, yy, zz, 'vs')),
    ('cvmh', cst.cvmh.extract(xx, yy, zz, 'vs', vs30=None)),
    ('cvms', cst.cvms.extract(xx, yy, zz, 'vs')),
]:
    f = os.path.join('run', 'data', 'surface-vs-%s.npy' % cvm)
    np.save(f, vv[0].astype('f'))

# cvm basins
zz.fill(1000.0)
for cvm, vv in [
    ('cvmh', cst.cvmh.extract(xx, yy, zz, 'vs', vs30=None)),
    ('cvms', cst.cvms.extract(xx, yy, zz, 'vs')),
]:
    v = 2500,
    x, y = cst.plt.contour(xx, yy, vv[0], v)[0]
    f = os.path.join('run', 'data', 'basins-%s.txt' % cvm)
    np.savetxt(f, np.array([x, y]).T)

