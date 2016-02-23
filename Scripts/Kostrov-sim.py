#!/usr/bin/env python3
import cst.sord

prm = {
    'delta': [100.0, 100.0, 100.0, 0.0075],
    'shape': [101, 101, 32, 300],
    'nproc3': [1, 1, 1],
    'bc1': ['-node', '+node', '-cell'],
    'bc2': ['pml', 'pml', 'pml'],
    'rho': [2670.0],
    'vp': [6000.0],
    'vs': [3464.0],
    'gam': [1.0],
    'hourglass': [1.0, 1.0],
    'faultnormal': '+z',
    'mud': [1.0],
    'mus': [1.0e+9],
    'dc':  [1.0e+9],
    'tn':  [-90.0e+6],
    'ts': [-100.0e+6],
    'hypocenter': [0.0, 0.0, 0.5],
    'vrup': 3117.6,
    'trelax': 0.0,
    'rcrit': 1.0e+9,
    'svm': [
        ([0,  20, []], '=>', 'p20a.bin'),
        ([12, 16, []], '=>', 'p20b.bin'),
        ([16, 12, []], '=>', 'p20c.bin'),
        ([20,  0, []], '=>', 'p20d.bin'),
        ([0,  40, []], '=>', 'p40a.bin'),
        ([24, 32, []], '=>', 'p40b.bin'),
        ([32, 24, []], '=>', 'p40c.bin'),
        ([40,  0, []], '=>', 'p40d.bin'),
    ]
}

d = os.path.join(sord.repo, 'Kostrov')
os.makedirs(d)
os.chdir(d)
sord.run(prm)
