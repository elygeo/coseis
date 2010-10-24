"""
1D velocity models
"""
import numpy as np
from . import coord

def vs30gtl( vs30, vt, z, zt=350.0, a=0.5, b=2.0/3.0, c=1.5 ):
    """
    Vs30 derived GTL
    """
    z = z / zt
    f = z + b * (z - z * z)
    g = a - (a + 3.0 * c) * z + c * z * z + 2.0 * c * np.sqrt( z )
    v = f * vt + g * vs30
    return v

def dreger( prop, depth ):
    """
    SoCal model of Dreger and Helmberger (1991)

    Parameters
    ----------
        prop: 'rho', 'vp', or 'vs'
        depth: Array of depth values in meters

    Returns
    -------
        f: Array of properties (kg/m^3 for rho, m/s for Vp and Vs)
    """
    depth = np.asarray( depth )
    f = np.empty_like( depth )
    f.fill( np.nan )
    z, rho, vp, vs = 1000.0 * np.array( [
        (  5.5, 2.4,  5.5, 3.18 ),
        (  5.5, 2.67, 6.3, 3.64 ),
        ( 16.0, 2.67, 6.3, 3.64 ),
        ( 16.0, 2.8,  6.7, 3.87 ),
        ( 35.0, 2.8,  6.7, 3.87 ),
        ( 35.0, 3.0,  7.8, 4.5  ),
    ] )
    f = {'rho': rho, 'vp': vp, 'vs': vs}[prop]
    f = np.interp( depth, z, f )
    return f

def boore_rock( depth ):
    """
    Boore and Joyner (1997) generic rock site Vs

    Parameters
    ----------
        depth: Array of depth values in meters

    Returns
    -------
        vs: Array of S-wave velocities in m/s
    """
    depth = np.asarray( depth )
    vs = np.empty_like( depth )
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
        i = (z0 < depth) & (depth <= z1)
        vs[i] = (v * 0.001 ** e) * depth[i] ** e
        z0 = z1
    return vs

def boore_hard_rock( depth ):
    """
    Boore and Joyner (1997) generic very hard rock site Vs

    Parameters
    ----------
        depth: Array of depth values in meters

    Returns
    -------
        vs: Array of S-wave velocities in m/s
    """
    depth = np.asarray( depth )
    v = [ 
        2768.0, 2808.0, 2847.0, 2885.0, 2922.0, 2958.0, 2993.0, 3026.0,
        3059.0, 3091.0, 3122.0, 3151.0, 3180.0, 3208.0, 3234.0, 3260.0,
    ]
    vs = coord.interp( [0.0, 750.0], v, depth )
    z0 = 750.0
    zve = [
        ( 2200.0, 3324.0, 0.0670 ),
        ( 8000.0, 3447.0, 0.0209 ),
    ]
    for z1, v, e in zve:
        i = (z0 < depth) & (depth <= z1)
        vs[i] = (v * 0.001 ** e) * depth[i] ** e
        z0 = z1
    return vs

