#!/usr/bin/env python
"""
Kostrov circular crack test.
"""
import numpy as np
import cst

# parameters
run = 'exec'
argv = []
force = True
nproc3 = 1, 1, 2
delta = 100.0, 100.0, 100.0, 0.0075
shape = 61, 61, 32, 200

# material properties
rho_ = 2670.0
vp_ = 6000.0
vs_ = 3464.0
hourglass = 1.0, 1.0
fieldio = [
    ('=', 'rho', [], rho_),
    ('=', 'vp',  [], vp_),
    ('=', 'vs',  [], vs_),
    ('=', 'gam', [], 1.0),
]

# boundary conditions
bc1 = 10, 10, 10
bc2 = -1, 1, -2

# rupture parameters
faultnormal = 3
ihypo = -1, -1, -1.5
vrup = 0.9 * 3464.0
rcrit = 1e9
trelax = 0.0
dtau_ = 10e6
fieldio += [
    ('=', 'mud', [], 1.0),
    ('=', 'mus', [], 1e9),
    ('=', 'dc',  [], 1e9),
    ('=', 'tn',  [], -90e6),
    ('=', 'ts',  [], -90e6 - dtau_),
]

# recievers
fieldio += [
    ('=w', 'svm', [ -1, -21, -1, -1], 'p20a.bin'),
    ('=w', 'svm', [-13, -17, -1, -1], 'p20b.bin'),
    ('=w', 'svm', [-17, -13, -1, -1], 'p20c.bin'),
    ('=w', 'svm', [-21,  -1, -1, -1], 'p20d.bin'),
]

# run SORD
cst.sord.run( locals() )

# compare with analytical solution
r = 2000.0
t = (shape[-1] - 1.5) * delta[-1] - r / vrup
v = cst.kostrov.slip_rate(rho_, vp_, vs_, vrup, dtau_, r, t)
for p in 'abcd':
    dv = v - np.fromfile('run/p20%s.bin' % p, 'f')[-1]
    err = dv / v
    assert err < 0.01

