#!/usr/bin/env python3
import cst.sord

cst.sord.run({

    # model dimentions [x, y, z, t]
    'shape': [61, 61, 61, 60],
    'delta': [100.0, 100.0, 100.0, 0.0075],

    # material properties
    'rho': [2670.0],  # density
    'vp':  [6000.0],  # P-wave velocity
    'vs':  [3464.0],  # S-wave velocity
    'gam':    [0.3],  # viscosity

    # potency tensor source time function
    'pxx': ['[30,30,30,:]', '=', 1.0, 'integral_brune', 0.05],
    'pyy': ['[30,30,30,:]', '=', 1.0, 'integral_brune', 0.05],
    'pzz': ['[30,30,30,:]', '=', 1.0, 'integral_brune', 0.05],

    # write 2d velocity slice, last time step
    'vx': ['[:,:,30,-1]', '=>', 'vx.bin'],
    'vy': ['[:,:,30,-1]', '=>', 'vy.bin'],

})
