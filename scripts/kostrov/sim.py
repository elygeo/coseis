#!/usr/bin/env python
"""
Kostrov circular crack test.
"""
import cst
prm = cst.sord.parameters()

# parameters
prm.nproc3 = 1, 1, 2
prm.delta = 100.0, 100.0, 100.0, 0.0075
prm.shape = 101, 101, 32, 300

# boundary conditions
prm.bc1 = 10, 10, 10
prm.bc2 = -1, 1, -2

# material model
prm.hourglass = 1.0, 1.0
prm.fieldio = [
    ('=', 'rho', [], 2670.0),
    ('=', 'vp',  [], 6000.0),
    ('=', 'vs',  [], 3464.0),
    ('=', 'gam', [], 1.0),
]

# rupture parameters
prm.ihypo = -1, -1, -1.5
prm.faultnormal = 3
prm.vrup = 0.9 * 3464.0
prm.rcrit = 1e9
prm.trelax = 0.0
prm.fieldio += [
    ('=', 'rho', [], 2670.0),
    ('=', 'vp',  [], 6000.0),
    ('=', 'vs',  [], 3464.0),
    ('=', 'gam', [], 1.0),
    ('=', 'mud', [], 1.0),
    ('=', 'mus', [], 1e9),
    ('=', 'dc',  [], 1e9),
    ('=', 'tn',  [],  -90e6),
    ('=', 'ts',  [], -100e6),
]

# receivers
prm.fieldio += [
    ('=w', 'svm', [ -1,-21,-1,()], 'p20a.bin'),
    ('=w', 'svm', [-13,-17,-1,()], 'p20b.bin'),
    ('=w', 'svm', [-17,-13,-1,()], 'p20c.bin'),
    ('=w', 'svm', [-21, -1,-1,()], 'p20d.bin'),
    ('=w', 'svm', [ -1,-41,-1,()], 'p40a.bin'),
    ('=w', 'svm', [-25,-33,-1,()], 'p40b.bin'),
    ('=w', 'svm', [-33,-25,-1,()], 'p40c.bin'),
    ('=w', 'svm', [-41, -1,-1,()], 'p40d.bin'),
]

# launch SORD
cst.sord.run(prm)

