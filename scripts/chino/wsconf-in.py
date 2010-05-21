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
    ( 'pgv', 'Peak ground velocity (m/s)',   'wwbgr', %(vticks)s, 1, 1.2 ),
    ( 'pgd', 'Peak ground displacement (m)', 'wwbgr', %(uticks)s, 1, 1.2 ),
    ( 'vs0', 'Surface S-wave velocity (km/s)', 'bgr', (250, 1000, 2000, 3000, 4000) ),
    ( 'topo', 'Topographic elevation (km)',    'bgr', (-1, 0, 1, 2, 3), 0.001 ),
]
x_title = 'Ground velocity snapshot'
x_panes = [
    ( 'out/snap-v1', 'X velocity (m/s)', 'cwy', (-1, 0, 1), 1, 2 ),
    ( 'out/snap-v2', 'Y velocity (m/s)', 'cwy', (-1, 0, 1), 1, 2 ),
    ( 'out/snap-v3', 'Z velocity (m/s)', 'cwy', (-1, 0, 1), 1, 2 ),
]
x_plot  = [
    ( 'mapdata-xyz.txt', 'k-' ),
    ( 'source-xyz.txt', 'k+' ),
]

# time histories
t_shape = %(nhist)r
t_delta = %(dhist)r
t_unit = 's', 'km', 'km'
t_axes = 'Time', 'X', 'Y'
t_title = 'Velocity time history'
t_panes = [
    ( ('out/hist-v1',), 'X Velocity (m/s)' ),
    ( ('out/hist-v2',), 'Y Velocity (m/s)', None, (' ') ),
    ( ('out/hist-v3',), 'Z Velocity (m/s)' ),
    #( ('out/hist-v1',), 'X Displacement (m)', 'int' ),
    #( ('out/hist-v2',), 'Y Displacement (m)', 'int' ),
    #( ('out/hist-v3',), 'Z Displacement (m)', 'int' ),
]

