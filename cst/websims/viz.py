"""
Visualization utilities
"""
import numpy as np
from matplotlib.colors import LinearSegmentedColormap

def colormap( cmap, colorexp=1.0, nmod=0, modlim=0.5 ):
    """
    Matplotlib colormap.

    cmap: either a named colormap from viz.colormap_library or a 5 x N array,
        with rows specifying: (value, red, green, blue, alpha) components.
    colorexp: exponent applied to the values to shift the colormap.
    nmod: number of brightness modulations applied to the colormap.
    modlim: magnitude of brightness modulations.
    """
    if type( cmap ) is str:
        cmap = colormap_library[cmap]
    cmap = np.array( cmap, 'f' )
    cmap[1:] /= max( 1.0, cmap[1:].max() )
    v, r, g, b, a = cmap
    v /= v[-1]
    if colorexp != 1.0:
        n = 16
        x  = np.linspace( 0.0, 1.0, len(v) )
        xi = np.linspace( 0.0, 1.0, (len(v) - 1) * n + 1 )
        r = np.interp( xi, x, r )
        g = np.interp( xi, x, g )
        b = np.interp( xi, x, b )
        a = np.interp( xi, x, a )
        v = np.interp( xi, x, v )
        v = np.sign( v ) * abs( v ) ** colorexp
    v = (v - v[0]) / (v[-1] - v[0])
    if nmod > 0:
        if len( v ) < 6 * nmod:
            vi = np.linspace( v[0], v[-1], 8 * nmod + 1 )
            r = np.interp( vi, v, r )
            g = np.interp( vi, v, g )
            b = np.interp( vi, v, b )
            a = np.interp( vi, v, a )
            v = vi
        w1 = np.cos( np.pi * 2.0 * nmod * v ) * modlim
        w1 = 1.0 - np.maximum( w1, 0.0 )
        w2 = 1.0 + np.minimum( w1, 0.0 )
        r = ( 1.0 - w2 * (1.0 - w1 * r) )
        g = ( 1.0 - w2 * (1.0 - w1 * g) )
        b = ( 1.0 - w2 * (1.0 - w1 * b) )
        a = ( 1.0 - w2 * (1.0 - w1 * a) )
    n = 2001
    cmap = { 'red':np.c_[v, r, r],
           'green':np.c_[v, g, g],
            'blue':np.c_[v, b, b] }
    cmap = LinearSegmentedColormap( 'cmap', cmap, n )
    return cmap

colormap_library = {
    'wwwwbgr': [
        (0, 4, 5, 7, 8, 9, 11, 12),
        (2, 2, 0, 0, 0, 2, 2, 2),
        (2, 2, 1, 2, 2, 2, 1, 0),
        (2, 2, 2, 2, 0, 0, 0, 0),
        (2, 2, 2, 2, 2, 2, 2, 2),
    ],
    'wwwbgr': [
        (0, 2, 3, 5, 6, 7, 9, 10),
        (2, 2, 0, 0, 0, 2, 2, 2),
        (2, 2, 1, 2, 2, 2, 1, 0),
        (2, 2, 2, 2, 0, 0, 0, 0),
        (2, 2, 2, 2, 2, 2, 2, 2),
    ],
    'wwbgr': [
        (0, 1, 2, 4, 5, 6, 8, 9),
        (2, 2, 0, 0, 0, 2, 2, 2),
        (2, 2, 1, 2, 2, 2, 1, 0),
        (2, 2, 2, 2, 0, 0, 0, 0),
        (2, 2, 2, 2, 2, 2, 2, 2),
    ],
    'wbgr': [
        (0, 1, 3, 4, 5, 7, 8),
        (2, 0, 0, 0, 2, 2, 2),
        (2, 1, 2, 2, 2, 1, 0),
        (2, 2, 2, 0, 0, 0, 0),
        (2, 2, 2, 2, 2, 2, 2),
    ],
    'bgr': [
        (-4, -3, -1,  0,  1,  3,  4),
        ( 0,  0,  0,  0,  2,  2,  2),
        ( 0,  1,  2,  2,  2,  1,  0),
        ( 2,  2,  2,  0,  0,  0,  0),
        ( 2,  2,  2,  2,  2,  2,  2),
    ],
    'bwr': [
        (-4, -3, -1,  0,  1,  3,  4),
        ( 0,  0,  0,  2,  2,  2,  1),
        ( 0,  0,  2,  2,  2,  0,  0),
        ( 1,  2,  2,  2,  0,  0,  0),
        ( 2,  2,  2,  2,  2,  2,  2),
    ],
    'cwy': [
        (-2, -1,  0,  1,  2),
        ( 0,  0,  1,  1,  1),
        ( 1,  0,  1,  0,  1),
        ( 1,  1,  1,  0,  0),
        ( 1,  1,  1,  1,  1),
    ],
}

