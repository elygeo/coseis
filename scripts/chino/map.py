#!/usr/bin/env python
"""
Map plot
"""
import os, json
import numpy as np
import matplotlib.pyplot as plt
import pyproj
import cst

# parameters
eventid = 14383980
bounds = (-80000.0, 48000.0), (-58000.0, 54000.0)
mts = os.path.join('run', 'data', '%s.mts.json' % eventid)
mts = json.load(open(mts))
origin = mts['longitude'], mts['latitude'], mts['depth']
proj = pyproj.Proj(proj='tmerc', lon_0=origin[0], lat_0=origin[1])

# plot defaults
inches = 6.4, 5.6
plt.rc('font', size=8)
plt.rc('axes', linewidth=0.5)
plt.rc('lines', lw=0.5, solid_joinstyle='round', solid_capstyle='round')
plt.rc('patch', lw=0.5)

# loop over models
for surface in [
    '',
    '-cvms',
    '-cvmh',
    '-cvmg',
]:

    # setup plot
    fig = plt.figure(None, inches, 100)
    fig.clf()
    ax = fig.add_axes([0.01, 0.01, 0.98, 0.98])
    axis = bounds[0] + bounds[1]

    if surface:

        # Surface Vs image
        vlim = 75, 3200
        cmap = cst.plt.colormap('rgb', colorexp=2.0)
        f = os.path.join('run', 'data', 'surface-vs%s.npy' % surface)
        f = np.load(f)
        print(f.min(), f.max())
        im = ax.imshow(f.T, extent=axis, cmap=cmap, vmin=75, vmax=3200,
            origin='lower', interpolation='nearest')

    else:

        # basins
        for f, color in ('basins-cvms', 'r'), ('basins-cvmh', 'b'):
            f = os.path.join('run', 'data', f + '.npy')
            x, y = np.load(f)
            i = np.isnan(x)
            x, y = proj(x, y)
            x[i] = y[i] = float('nan')
            h = ax.plot(x, y, '-' + color)
            h[0].set_dashes((2,1))

    # topography
    for f, lw in ('mountains', 0.5), ('coastlines', 1.0):
        f = os.path.join('run', 'data', f + '.npy')
        x, y = np.load(f)
        i = np.isnan(x)
        x, y = proj(x, y)
        x[i] = y[i] = float('nan')
        ax.plot(x, y, '-k', lw=lw)

    # source
    x0, y0 = proj(mts['longitude'], mts['latitude'])
    f = os.path.join('run', 'data', 'beachball.npy')
    x, y = np.load(f) * 5000.0
    i, j = np.isnan(x).nonzero()[0]
    x = x[:i-1], x[i+1:j-1], x[j+1:]
    y = y[:i-1], y[i+1:j-1], y[j+1:]
    ax.fill(x0 + x[0], y0 + y[0], 'w')
    ax.fill(x0 + x[1], y0 + y[1], 'k')
    ax.fill(x0 + x[2], y0 + y[2], 'k')

    # stations
    sta = os.path.join('run', 'data', 'station-list.txt')
    sta = np.loadtxt(sta, 'S8, f, f, f')
    x, y = proj(sta['f2'], sta['f1'])
    ax.plot(x, y, 'k^', markersize=5)
    for s, y, x, z in sta:
        x, y = proj(x, y)
        ax.text(x, y-1300, s.split('.')[-1], ha='center', va='top')

    # axes
    ax.axis('image')
    ax.axis(axis)
    ax.set_xticks([])
    ax.set_yticks([])

    # legend
    x, y = bounds
    x = x[1] - 50000.0, x[1] - 30000.0
    y = y[1] - 3000.0, y[1] - 3000.0
    cst.plt.lengthscale(ax, x, y, label='20 km', backgroundcolor='w')
    x, y = bounds
    x = x[1] - 20000.0
    y = y[1] - 6000.0
    cst.plt.compass_rose(ax, x, y, 2000.0)

    # save figure
    f = os.path.join('run', 'plot', 'map%s.pdf' % surface)
    g = os.path.join('run', 'www', 'map%s.png' % surface)
    fig.savefig(f, transparent=True)
    fig.savefig(g)
    fig.show()

