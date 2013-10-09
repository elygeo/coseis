#!/usr/bin/env python
"""
Map plot
"""
import os, json
import numpy as np
import pyproj
from obspy.imaging import beachball
import cst

# parameters
eventid = 14383980
bounds = (-80000.0, 48000.0), (-58000.0, 54000.0)
mts = os.path.join('run', 'data', '%s.mts.json' % eventid)
mts = json.load(open(mts))
origin = mts['longitude'], mts['latitude'], mts['depth']
proj = pyproj.Proj(proj='tmerc', lon_0=origin[0], lat_0=origin[1])

# extent
x, y = bounds
x = x[0], x[1], x[1], x[0]
y = y[0], y[0], y[1], y[1]
x, y = np.array(proj(x, y, inverse=True))
extent = (x.min(), x.max()), (y.min(), y.max())

# source
m = mts['double_couple_clvd']
m = m['mzz'], m['mxx'], m['myy'], m['mxz'], -m['myz'], -m['mxy']
b = beachball.Beach(m, width=200)
p = []
for c in b.get_paths():
    p += c.to_polygons() + [[[float('nan'), float('nan')]]]
del p[-1]
b = np.concatenate(p) * 0.005
f = os.path.join('run', 'data', 'Beachball.npy')
np.save(f, b.astype('f').T)

# coastlines and boarders
x, y = cst.data.mapdata('coastlines', 'high', extent, 10.0)
x -= 360.0
f = os.path.join('run', 'data', 'Coastlines.npy')
np.save(f, np.array([x, y], 'f'))

# topography
xx, yy, zz = cst.data.dem(extent, mesh=True)
x, y = cst.plt.contour(xx, yy, zz, [1000])[0]
f = os.path.join('run', 'data', 'Mountains.npy')
np.save(f, np.array([x, y], 'f'))

# surface
zz.fill(0.0)
for cvm, vv in [
    ('cvmg', cst.cvmh.extract(xx, yy, zz, 'vs')),
    ('cvmh', cst.cvmh.extract(xx, yy, zz, 'vs', vs30=None)),
    ('cvms', cst.cvms.extract(xx, yy, zz, 'vs')),
]:
    f = os.path.join('run', 'data', 'Surface-Vs-%s.npy' % cvm)
    np.save(f, vv[0].astype('f'))

# cvm basins
zz.fill(1000.0)
for cvm, vv in [
    ('cvmh', cst.cvmh.extract(xx, yy, zz, 'vs', vs30=None)),
    ('cvms', cst.cvms.extract(xx, yy, zz, 'vs')),
]:
    v = 2500,
    x, y = cst.plt.contour(xx, yy, vv[0], v)[0]
    f = os.path.join('run', 'data', 'Basins-%s.npy' % cvm.upper())
    np.save(f, np.array([x, y], 'f'))

