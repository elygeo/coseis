#!/usr/bin/env python
"""
WebSims configuration template
"""

# info
title = '%(title)s'
label = '%(title)s: '
author = '%(author)s'
rundate = '%(rundate)s'
dtype = '%(dtype)s'
downloadable = True
notes = ''

# shapshots
x_shape = %(nsnap)r
x_delta = %(dsnap)r
x_unit = 'km', 'km', 's'
x_axes = 'X', 'Y', 'Time'
x_decimate = 1
x_static_title = 'Surface maps'
x_static_panes = [
    ('pgv.bin', 'Peak ground velocity (m/s)',   'wwbgr', %(vticks)s, 1, 2),
    ('pgd.bin', 'Peak ground displacement (m)', 'wwbgr', %(uticks)s, 1, 2),
    ('vs0.bin', 'Surface S-wave velocity (km/s)', 'bgr', (250, 1000, 2000, 3000, 4000)),
    ('topo.bin', 'Topographic elevation (km)',    'bgr', (-1, 0, 1, 2, 3), 0.001),
]
x_title = 'Ground velocity snapshot'
x_panes = [
    ('hold/snap-v1.bin', 'X velocity (m/s)', 'cwy', (-1, 0, 1), 1, 2),
    ('hold/snap-v2.bin', 'Y velocity (m/s)', 'cwy', (-1, 0, 1), 1, 2),
    ('hold/snap-v3.bin', 'Z velocity (m/s)', 'cwy', (-1, 0, 1), 1, 2),
]
x_plot  = [
    ('mapdata-xyz.txt', 'k-'),
    ('mountains-xyz.txt', 'k-'),
    ('basins-xyz.txt', 'k--'),
    ('receivers-xyz.txt', 'k^'),
    ('hypocenter-xyz.txt', 'k*'),
]

# time histories
t_shape = %(nhist)r
t_delta = %(dhist)r
t_unit = 's', 'km', 'km'
t_axes = 'Time', 'X', 'Y'
t_title = 'Velocity time history'
t_panes = [
    (('hold/hist-v1.bin',), 'X Velocity (m/s)'),
    (('hold/hist-v2.bin',), 'Y Velocity (m/s)', None, (' ')),
    (('hold/hist-v3.bin',), 'Z Velocity (m/s)'),
]

