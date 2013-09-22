#!/usr/bin/env python
"""
PEER Lifelines program task 1A01, Problem LOH.1

Layer over a halfspace model with buried double-couple source.
http://peer.berkeley.edu/lifelines/lifelines_pre_2006/lifelines_princ_invest_y-7.html#day
http://peer.berkeley.edu/lifelines/lifelines_pre_2006/final_reports/1A01-FR.pdf
http://www-rohan.sdsu.edu/~steveday/BASINS/Final_Report_1A01.pdf
"""
import os
import cst
prm = cst.sord.parameters()
fld = cst.sord.fieldnames()

# number of processors in each dimension
prm['nthread'] = 1; prm['nproc3'] = [1, 16, 1]
prm['nthread'] = 4; prm['nproc3'] = [1, 1, 1]

# dimensions
x, y, z, t = 8000.0, 10000.0, 6000.0, 9.0
dx, dy, dz, dt = 50.0, 50.0, 50.0, 0.004
dx, dy, dz, dt = 100.0, 100.0, 100.0, 0.008
prm['delta'] = [dx, dy, dz, dt]
prm['shape'] = [
    int(x / dx + 20.5),
    int(y / dy + 20.5),
    int(z / dz + 20.5),
    int(t / dt + 1.5),
]

# material properties
prm['hourglass'] = [1.0, 2.0]
prm['fieldio'] = [
    fld['rho'] == 2700.0,
    fld['vp'] == 6000.0,
    fld['vs'] == 3464.0,
    fld['gam'] == 0.0,
]

# material properties of the layer
l = 1000.0 / dz + 0.5
prm['fieldio'] += [
    fld['rho'][:,:,:l,:] == 2600.0,
    fld['vp'][:,:,:l,:] == 4000.0,
    fld['vs'][:,:,:l,:] == 2000.0,
]

# near side boundary conditions:
# anti-mirror symmetry at the near x and y boundaries
# free surface at the near z boundary
prm['bc1'] = [-2, -2, 0]

# far side boundary conditions:
# PML absorbing boundaries at x, y and z boundaries
prm['bc2'] = [10, 10, 10]

# source
prm['ihypo'] = [1.5, 1.5, 41.5]		# hypocenter indices
prm['source'] = 'moment'		# specify moment source
prm['pulse'] = 'integral_brune'		# Brune pulse source time function
prm['tau'] = 0.1			# source characteristic time
prm['source1'] = [0.0, 0.0, 0.0]	# moment tensor M_xx, M_yy, M_zz
prm['source2'] = [0.0, 0.0, 1e18]	# moment tensor M_yz, M_zx, M_yz

# receivers
for i in range(10):
    j = prm['ihypo'][0] + 600.0 * (i + 1) / dx
    k = prm['ihypo'][1] + 800.0 * (i + 1) / dy
    for f in 'v1', 'v2', 'v3':
        prm['fieldio'] += [fld['v1'][j,k,1,:] >> 'p%s-%s.bin' % (i, f)]

# run job
os.mkdir('run')
cst.sord.run(prm)

