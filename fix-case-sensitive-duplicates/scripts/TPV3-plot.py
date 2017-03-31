#!/usr/bin/env python
import os
import json
import glob
import numpy as np
import matplotlib.pyplot as plt

# parameters
stations = 'P1a', 'P2a'
stations = 'P1b', 'P2b'
stations = 'P1', 'P2'
path_bi = '../data/TVP3-BI-'
runs = '../Repository/TPV3-*'

# loop over runs
cwd = os.getcwd()
for path in glob.glob(runs):

    # metadata
    meta = json.load(open('meta.json'))
    shape = meta['shape']
    delta = meta['delta']
    hypo = meta['hypocenter']

    # time histories
    t1 = np.arange(shape[-1]) * delta[-1]
    t2 = np.load(path_bi + 'Time.npy')

    # loop over stations
    for i, sta in enumerate(stations):
        fig = plt.figure(i+1)
        fig.clf()

        # shear stress
        ax = fig.add_subplot(2, 1, 1)
        f1 = np.load(sta + '-ts1.npy') * 1e-6
        f2 = np.load(path_bi + sta[:2] + '-Traction.npy')
        ax.plot(t1, f1, 'k-', t2, f2, 'k--')
        ax.axis([1, 11, 60, 85])
        ax.set_title(sta, position=(0.05, 0.83), ha='left', va='center')
        ax.set_xticklabels([])
        ax.set_ylabel('Shear stress (MPa)')
        # leg = fig.legend(('SOM', 'BI'), loc=(0.78, 0.6))

        # slip rate
        ax = fig.add_subplot(2, 1, 2)
        f1 = np.load(sta + '-sv1.npy')
        f2 = np.load(path_bi + sta[:2] + '-Slip-Rate.npy')
        ax.plot(t1, f1, 'k-', t2, f2, 'k--')
        ax.set_yticks([0, 1, 2, 3])
        ax.set_ylabel('Slip rate (m/s)')

        # slip
        ax.twinx()
        f1 = np.load(sta + '-su1.npy')
        f2 = np.load(path_bi + sta[:2] + '-Slip.npy')
        ax.plot(t1, f1, 'k-', t2, f2, 'k--')
        ax.axis([1, 11, -0.5, 3.5])
        ax.set_yticks([0, 1, 2, 3])
        ax.set_ylabel('Slip (m)')
        ax.set_xlabel('Time (s)')

        # finish up
        ax.set_title(sta, position=(0.05, 0.83), ha='left', va='center')
        f = 'TPV3-%03d-%s' % (delta[0], sta)
        fig.savefig(f + '.svg')

    # Rupture time contour
    fig = plt.figure(3)
    fig.clf()
    ax = fig.add_subplot(111)
    v = np.arange(-20, 20) * 0.5

    # SOM
    x = np.load('x1.npy')
    y = np.load('x2.npy')
    t = np.load('trup.npy')
    if 'fixhypo' not in meta:
        x = x - delta[0] * (hypo[0] - 1)
        y = y - delta[1] * (hypo[1] - 1)
    x *= 0.001
    y *= 0.001
    ax.contour(x, y, t, v, colors='k')

    # BI
    dx = 0.1
    t = np.load(path_bi + 'Rupture-Time.npy')
    nx, ny = t.shape
    x = np.arange(nx) * dx
    y = np.arange(ny) * dx
    x -= 0.5 * x[-1]
    y -= 0.5 * y[-1]
    y, x = np.meshgrid(y, x)
    ax.contour(x, y, -t, v, colors='k')

    # finish up
    ax.axis('image')
    ax.axis([-15, 0, -7.5, 0])
    f = 'TPV3-%03d-trup' % delta
    fig.savefig(f + '.svg')
