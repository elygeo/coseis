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
prm['bc1'] = ['free', '-node', '-cell']
prm['bc2'] = ['pml', 'pml', 'pml']

# nucleation
x = 1.4 / dx
j = int(x)
prm['vrup'] = 15.0
prm['rcrit'] = 0.4
prm['trelax'] = 10.0 * dt

# rupture
prm['faultnormal'] = '+z'
prm['hypocenter'] = [x, 0.0, 0.5]
prm['slipvector'] = [0.0, 1.0, 0.0]
prm['ts'] = [-730.0]
prm['tn'] = [-330.0]
prm['dc'] = 0.001
prm['mus'] = [1e5, (s_[:j+1,:], '=', 2.4)]
prm['mud'] = [1e5, (s_[:j+1,:], '=', 1.85)]

# weak zone
weakzone = 0.2
weakzone = 0.0
j = int(weakzone / dx)
if weakzone:
    prm['ts']  += [(s_[:j+1,:], '=', -66.0)]
    prm['mus'] += [(s_[:j+1,:], '=', 0.6)]
    prm['mud'] += [(s_[:j+1,:], '=', 0.6)]

# accelerometers
z = 0.03 / dx
z = 0.04 / dx
for s, x, g in [
    [1, 0.92, 0.020074],
    [2, 0.72, 0.019926],
    [3, 0.42, 0.020350],
    [4, 0.22, 0.020166],
    [15, 0.02, 0.020773],
]:
    x /= dx
    if 'ay' not in prm:
        prm['ay'] = []
    prm['ay'] += [
        (s_[x,0.0,z,:], '.>', 'sensor%02d.bin' % s),
    ]

# displacement sensor
prm['uy'] = [
    (s_[0,0,0,:], '=>', 'sensor16.bin'),
]

# surface output
k = int(prm['hypocenter'][1])
l = int(0.8 / dx)
prm['uy'] += [(s_[0,k,1:l+1,:], '=>', 'off-fault.bin')]
#prm['vy'] = [(s_[:,k,1:l+1,::10], '=>', 'xsec.bin')]

# run SORD
w = weakzone * 100
prm['path'] = d = os.path.join('run', '%02.0f' % w)
os.makedirs(d)
cst.sord.run(prm)

