#!/usr/bin/env python
"""
1D velocity models
"""
import numpy as np
import coord

def hadley_smoothed( prop, depth ):
    """
    A smoothed version of the Hadley and Kanamori (1977) velocity model for
    southern California used in the SCEC Community Velocity Model, version 4.
    FIXME: this is horribly broken!!!
    """
    depth = np.asarray( depth )
    z, f = 1000.0 * np.array( [
       (  1.0, 5.0  ),
       (  5.0, 5.5  ),
       (  6.0, 6.3  ),
       ( 10.0, 6.3  ),
       ( 15.5, 6.4  ),
       ( 16.5, 6.7  ),
       ( 22.0, 6.75 ),
       ( 31.0, 6.8  ),
       ( 33.0, 7.8  ),
    ] ).T
    if prop == 'rho':
       f = 1865.0 + 0.1579 * f
    v = np.intperp( depth, z, f )
    if prop == 'vs':
        z, f = zip( [
           (  2060.0, 0.40 ),
           (  2500.0, 0.25 ),
        ] )
        nu = np.interp( rho, z, f )
        vs = vp * sqrt( (0.5 - nu) / (1.0 - nu) )
    return out

def boore_rock( z ):
    """
    Boore and Joyner (1997) generic rock site V_s
    """
    vs = np.empty_like( z )
    vs.fill( np.nan )
    z0 = -0.00001
    zve = [
        (    1.0,  245.0, 0.0   ),
        (   30.0, 2206.0, 0.272 ),
        (  190.0, 3542.0, 0.407 ),
        ( 4000.0, 2505.0, 0.199 ),
        ( 8000.0, 2927.0, 0.086 ),
    ]
    for z1, v, e in zve:
        i = (z0 < z) & (z <= z1)
        vs[i] = (v * 0.001 ** e) * z[i] ** e
        z0 = z1
    return vs

def boore_hard_rock( z ):
    """
    Boore and Joyner (1997) generic very hard rock site V_s
    """
    v = [ 
        2768.0, 2808.0, 2847.0, 2885.0, 2922.0, 2958.0, 2993.0, 3026.0,
        3059.0, 3091.0, 3122.0, 3151.0, 3180.0, 3208.0, 3234.0, 3260.0,
    ]
    vs = coord.interp( [0.0, 750.0], v, z )
    z0 = 750.0
    zve = [
        ( 2200.0, 3324.0, 0.0670 ),
        ( 8000.0, 3447.0, 0.0209 ),
    ]
    for z1, v, e in zve:
        i = (z0 < z) & (z <= z1)
        vs[i] = (v * 0.001 ** e) * z[i] ** e
        z0 = z1
    return vs

