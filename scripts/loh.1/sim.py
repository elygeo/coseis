#!/usr/bin/env python
"""
PEER Lifelines program task 1A01, Problem LOH.1

Layer over a halfspace model with buried double-couple source.
http://peer.berkeley.edu/lifelines/lifelines_pre_2006/lifelines_princ_invest_y-7.html#day
http://peer.berkeley.edu/lifelines/lifelines_pre_2006/final_reports/1A01-FR.pdf
http://www-rohan.sdsu.edu/~steveday/BASINS/Final_Report_1A01.pdf
"""
import cst
prm = cst.sord.parameters()
s_ = cst.sord.s_

# number of processors in each dimension
prm.nproc3 = 1, 16, 1

# dimensions
x, y, z, t = 8000.0, 10000.0, 6000.0, 9.0
prm.delta = 50.0, 50.0, 50.0, 0.004
prm.shape = (
    int(x / prm.delta[0] + 20.5),
    int(y / prm.delta[1] + 20.5),
    int(z / prm.delta[2] + 20.5),
    int(t / prm.delta[3] + 1.5),
)

# material properties
prm.hourglass = 1.0, 2.0       	# hourglass stiffness and viscosity
prm.fieldio = [
    ('=', 'rho', [], 2700.0),	# density
    ('=', 'vp',  [], 6000.0),	# P-wave speed
    ('=', 'vs',  [], 3464.0),	# S-wave speed
    ('=', 'gam', [],    0.0),	# viscosity
]

# material properties of the layer
prm.fieldio += [
    ('=', 'rho', s_[:,:,:20.5,:], 2600.0),
    ('=', 'vp',  s_[:,:,:20.5,:], 4000.0),
    ('=', 'vs',  s_[:,:,:20.5,:], 2000.0),
]

# near side boundary conditions:
# anti-mirror symmetry at the near x and y boundaries
# free surface at the near z boundary
prm.bc1 = -2, -2, 0

# far side boundary conditions:
# PML absorbing boundaries at x, y and z boundaries
prm.bc2 = 10, 10, 10

# source
prm.ihypo = 1.5, 1.5, 41.5     	# hypocenter indices
prm.source = 'moment'		# specify moment source
prm.pulse = 'integral_brune'	# Brune pulse source time function
prm.tau = 0.1			# source characteristic time
prm.source1 = 0.0, 0.0, 0.0    	# moment tensor M_xx, M_yy, M_zz
prm.source2 = 0.0, 0.0, 1e18	# moment tensor M_yz, M_zx, M_yz

# receivers
for i in range(10):
    j = prm.ihypo[0] + 600.0 * (i + 1) / prm.delta[0]
    k = prm.ihypo[1] + 800.0 * (i + 1) / prm.delta[1]
    prm.fieldio += [
        ('=w', 'v1', [j,k,1,()], 'p%s-v1.bin' % i),
        ('=w', 'v2', [j,k,1,()], 'p%s-v2.bin' % i),
        ('=w', 'v3', [j,k,1,()], 'p%s-v3.bin' % i),
    ]

# run job
cst.sord.run(prm)

