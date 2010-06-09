#!/usr/bin/env python
import numpy as np
import coord

def rock_vs( z ):
    """
    Boore and Joyner generic rock site
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

def hard_rock_vs( z ):
    """
    Boore and Joyner generic very hard rock site
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

