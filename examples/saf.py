#!/usr/bin/env python
"""
San Andreas Fault, northward dynamic rupture, topography, SCEC-CVM4
"""
import sord

rundir = '~/run/saf'				# simulation directory 
np3 = 1, 80, 24					# 1920 total processors on DataStar
nn = 3001, 1502, 401				# number of mesh nodes nx ny nz
dx = 200.0, 200.0, -200.0			# spatial step length
nt = 15001					# number of time steps
dt = 0.012					# time step length

# Read mesh coordinates from disk
d = 'saf/cvm4/0200/'				# data directory location
fieldio = [
    ( '=R', 'x1', [(),(),1,()], d + 'x1' ),	# read 2D x coordinate file
    ( '=R', 'x2', [(),(),1,()], d + 'x2' ),	# read 2D y coordinate file
    ( '=r', 'x3', [],           d + 'x3' ),	# read 3D z coordinate file
]

# Boundary conditions, PML on all side except for free surface
bc1 = 10, 10, 10
bc2 = 10, 10,  0

# Material properties
fieldio += [
    ( '=r', 'rho', [], d + 'rho' ),		# Read 3D density file
    ( '=r', 'vp',  [], d + 'vp'  ),		# Read 3D V_p file
    ( '=r', 'vs',  [], d + 'vs'  ),		# Read 3D V_s file
]
vdamp = 400.0					# viscosity = vdamp / vs
vp1  = 1500.0					# minimum V_p
vs1  = 500.0					# minimum V_s
gam2 = 0.8					# maximum viscosity
hourglass = 1.0, 1.0				# hourglass stiffness and viscosity

# Fault parameters
slipvector = 1.0, 0.0, 0.0			# vector for resolving pre-traction
faultnormal = 2					# fault plane normal direction
ihypo = 2266, 997, -26				# hypocenter indices
j =  1317, 2312				# temporary variable
k = ihypo[1]					# temporary variable
l = -81, -1					# temporary variable
fieldio += [
    ( '=r', 'ts',  [(),k,(),()],  d + 'ts1' ), # read initial shear traction file
    ( '=',  'tn',  [(),k,(),()], -20e6      ), # initial normal traction
    ( '=',  'dc',  [(),k,(),()],   0.5      ), # slip weakening distance
    ( '=',  'mud', [(),k,(),()],   0.5      ), # coeff of dynamic friction
    ( '=',  'mus', [(),k,(),()],   1e4      ), # coeff of static fr., non-slip section
    ( '=',  'mus', [j, k,l, ()],   1.1      ), # coeff of static fr., slipping section
]

# Nucleation
vrup = 2300.0					# nucleation rupture velocity
trelax = 0.12					# time 
rcrit = 3000.0					# radius of nucleation patch

# Write fault plane output
fieldio += [
    ( '=w', 'sl',   [(),k,(),-1], 'sl'   ),	# slip path length
    ( '=w', 'psv',  [(),k,(),-1], 'psv'  ),	# peak slip velocity
    ( '=w', 'trup', [(),k,(),-1], 'trup' ),	# rupture time
]

# Write velocity time histories
for j, k, f in [
    ( 2641,  812, 'Mexicali' ),
    ( 2027,  978, 'Coachella' ),
    ( 2014,  323, 'San_Diego' ),
    ( 1841,  939, 'Palm_Springs' ),
    ( 1456,  959, 'San_Bernardino' ),
    ( 1475,  851, 'Riverside' ),
    ( 1306, 1140, 'Victorville' ),
    ( 1344,  839, 'Ontario' ),
    ( 1277, 1340, 'Barstow' ),
    ( 1383,  619, 'Santa_Ana' ),
    ( 1204,  667, 'Montebello' ),
    ( 1141,  641, 'Los_Angeles' ),
    ( 1261,  531, 'Long_Beach' ),
    ( 1078,  588, 'Westwood' ),
    (  950,  960, 'Lancaster' ),
]:
    fieldio += [
        ( '=w', 'v1', [j,k,-1,()], f + '_v1' ),
        ( '=w', 'v2', [j,k,-1,()], f + '_v2' ),
        ( '=w', 'v3', [j,k,-1,()], f + '_v3' ),
    ]

sord.run( locals() )

