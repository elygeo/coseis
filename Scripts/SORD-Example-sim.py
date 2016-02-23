#!/usr/bin/env python3
import cst.sord
prm = {
    'shape': [61, 61, 61, 60],
    'delta': [100.0, 100.0, 100.0, 0.0075],
    'rho': [2670.0],
    'vp':  [6000.0],
    'vs':  [3464.0],
    'gam':    [0.3],
    'pxx': [([30, 30, 30, []], '=', 1.0, 'integral_brune', 0.05)],
    'pyy': [([30, 30, 30, []], '=', 1.0, 'integral_brune', 0.05)],
    'pzz': [([30, 30, 30, []], '=', 1.0, 'integral_brune', 0.05)],
    'vx':  [([[], [], 30, -1], '=>', 'vx.bin')],
    'vy':  [([[], [], 30, -1], '=>', 'vy.bin')],
}
d = cst.sord.repo + 'Example'
os.mkdir(d)
os.chdir(d)
sord.run(prm)
