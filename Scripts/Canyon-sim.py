#!/usr/bin/env python
import os
import cst.sord

nx, ny, nz, nt = 301, 321, 2, 6000
t = [None, None, 10]

prm = {
    'delta': [0.0075, 0.0075, 0.0075, 0.002],
    'shape': [nx, ny, nz, nt],
    'nproc3': [2, 1, 1],
    'rho': [1.0],
    'vp': [2.0],
    'vs': [1.0],
    'gam': [0.0],
    'hourglass': [1.0, 2.0],
    'bc1': ['free',  'free',  '+node'],
    'bc2': ['+node', '-node', '+node'],
    'x': [([[], [], 0], '=<', 'x.bin')],
    'y': [([[], [], 0], '=<', 'y.bin')],
    'vy': [
        ([-1, [161, None], [], []], '=', 'ricker1', 1.0, 2.0),
        ([[], [], 0, t], '=>', 'snap-vy.bin'),
    ],
    'vx': [
        ([[], [], 0, t], '=>', 'snap-vx.bin')
    ],
    'ux': [
        ([-1, -1, 0, []], '=>', 'source-ux.bin'),
        ([0, [], 0, []], '=>', 'canyon-ux.bin'),
        ([[1, 158], 0, 0, []], '=>', 'flank-ux.bin'),
        ([[], [], 0, t], '=>', 'snap-ux.bin'),
    ],
    'uy': [
        ([-1, -1, 0, []], '=>', 'source-uy.bin'),
        ([0, [], 0, []], '=>', 'canyon-uy.bin'),
        ([[1, 158], 0, 0, []], '=>', 'flank-uy.bin'),
        ([[], [], 0, t], '=>', 'snap-uy.bin'),
    ],
}

os.chdir('repo/Canyon')
os.chdir('repo/Canyon')
cst.sord.run(prm))
