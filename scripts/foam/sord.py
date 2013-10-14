#!/usr/bin/env python
"""
Foam rubber model from:

Day, S. M., and G. P. Ely (2002),
*Effect of a shallow weak zone on fault rupture: Numerical simulation of
scale-model experiments*, Bull. Seism. Soc. Am., `92(8), 3022-3041
<http://www.bssaonline.org/cgi/content/abstract/92/8/3022>`__,
doi:10.1785/0120010273.
"""
import os
import cst
s_ = cst.sord.get_slices()
prm = {}

# dimentions
dx, dt = 0.01, 0.01, 0.01, 0.000075
dx, dt = 0.02, 0.00015
x, y, z, t = 2.8, 2.2, 2.2, 0.15
nx = int(x / dx + 1.5)
ny = int(y / dx + 1.5)
nz = int(z / dx + 1.5)
nt = int(t / dt + 1.5)
prm['nproc3'] = [1, 2, 1]
prm['delta'] = [dx, dx, dx, dt]
prm['shape'] = [nx, ny, nz, nt]

# material model
prm['rho'] = 16.0
prm['vp']  = 56.0
prm['vs']  = 30.0
prm['gam'] = 0.5
prm['hourglass'] = [1.0, 1.0]

# boundary conditions
prm['bc1'] = [0, -1, -2]
prm['bc2'] = [10, 10, 10]

# nucleation
prm['ihypo'] = [1.4 / dx + 1.0, 1, 1.5]
prm['vrup'] = 15.0
prm['rcrit'] = 0.4
prm['trelax'] = 10.0 * dt

# rupture
j = prm['ihypo'][0]
prm['faultnormal'] = 3
prm['slipvector'] = [0.0, 1.0, 0.0]
prm['ts'] = [-730.0]
prm['tn'] = [-330.0]
prm['dc'] = 0.001
prm['mus'] = [1e5, (s_[:j,:,:], '=', 2.4)]
prm['mud'] = [1e5, (s_[:j,:,:], '=', 1.85)]

# weak zone
weakzone = 0.2
weakzone = 0.0
j = weakzone / dx + 1.0
if weakzone:
    prm['ts']  += [(s_[j,:,:], '=', -66.0)]
    prm['mus'] += [(s_[j,:,:], '=', 0.6)]
    prm['mud'] += [(s_[j,:,:], '=', 0.6)]

# accelerometers
z = 0.03
z = 0.04
l = z / dx + 2.0
for s, x, g in [
    [1, 0.92, 0.020074],
    [2, 0.72, 0.019926],
    [3, 0.42, 0.020350],
    [4, 0.22, 0.020166],
    [15, 0.02, 0.020773],
]:
    j = x / dx + 1.0
    if 'a2' not in prm:
        prm['a2'] = []
    prm['a2'] += [
        (s_[j,1,l,:], '.>', 'sensor%02d.bin' % s),
    ]

# displacement sensor
prm['u2'] = [
    (s_[1,1,1,:], '=>', 'sensor16.bin'),
]

# surface output
k = prm['ihypo'][1]
l = 0.8 / dx + 2.0
prm['u2'] += [(s_[1,k,2:l,:], '.>', 'off-fault.bin')]
#prm['v2'] = [(s_[:,k,2:l,::10], '.>', 'xsec.bin')]

# run SORD
w = weakzone * 100
prm['path'] = d = os.path.join('run', '%02.0f' % w)
os.makedirs(d)
cst.sord.run(prm)

