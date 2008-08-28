# San Andreas Fault, northward dynamic rupture, topography, SCEC-CVM4

np = [ 1, 80, 24 ]			# 1920 total processors on DataStar
nn = [ 3001, 1502, 401 ]		# number of mesh nodes nx ny nz
nt = 15000				# number of time steps
dt = 0.012				# time step length

# Read mesh coordinates from disk
datadir = 'saf/scecvm4/0200'		# directory location
x1 = [ 'read', 'zone', 1,1,1,-1,-1,1 ]	# read 2D x coordinate file
x2 = [ 'read', 'zone', 1,1,1,-1,-1,1 ]	# read 2D y coordinate file
x3 = 'read'				# read 3D z coordinate file

# Boundary conditions, PML on all side except for free surface
bc1 = [ 10, 10, 10 ]
bc2 = [ 10, 10,  0 ]

# Material model
rho = 'read'				# read 3D density file
vp  = 'read'				# read 3D V_p file
vs  = 'read'				# read 3D V_s file
vdamp = 400.				# set viscosity = vdamp / vs
vp1  = 1500.				# set minimum V_p
vs1  = 500.				# set minimum V_s
gam2 = 0.8				# set maximum viscosity
hourglass = [ 1., 1. ]			# hourglass stiffness and viscosity


# Fault parameters
ihypo = [ 2266, 997, -26 ]		# hypocenter indices
faultnormal = 2			# fault plane at k = ihypo(2) = 997
slipvector = [ 1., 0., 0. ]		# vector for resolving pre-traction
tn  = -20e6				# initial normal traction
ts1 = 'read'				# read initial shear traction file
dc  = 0.5				# slip weakening distance
mud = 0.5				# coefficient of dynamic friction
mus = 1000.				# coefficient of static friction
mus = [ 1.10, 'zone',  1317, 0, -81,  2311, 0, -1 ]

# Nucleation
fixhypo = 1				# node registered hypocenter
vrup = 2300.				# nucleation rupture velocity
trelax = 0.12				# time 
rcrit = 3000.				# radius of nucleation patch

# Fault plane output
out = [ 'su',  1,  1317,   0,-81,-1,  2311,   0,-1,-1 ] # final slip
out = [ 'psv', 1,  1317,   0,-81,-1,  2311,   0,-1,-1 ] # peak slip velocity
out = [ 'trup',1,  1317,   0,-81,-1,  2311,   0,-1,-1 ] # rupture time

# Velocity time series output
out = [ 'v',   1,  2642, 813, -1, 0,  2642, 813,-1,-1 ] # Mexicali
out = [ 'v',   1,  2028, 979, -1, 0,  2028, 979,-1,-1 ] # Coachella
out = [ 'v',   1,  2015, 324, -1, 0,  2015, 324,-1,-1 ] # San Diego
out = [ 'v',   1,  1842, 940, -1, 0,  1842, 940,-1,-1 ] # Palm Springs
out = [ 'v',   1,  1457, 960, -1, 0,  1457, 960,-1,-1 ] # San Bernardino
out = [ 'v',   1,  1476, 852, -1, 0,  1476, 852,-1,-1 ] # Riverside
out = [ 'v',   1,  1307,1141, -1, 0,  1307,1141,-1,-1 ] # Victorville
out = [ 'v',   1,  1345, 840, -1, 0,  1345, 840,-1,-1 ] # Ontario
out = [ 'v',   1,  1278,1341, -1, 0,  1278,1341,-1,-1 ] # Barstow
out = [ 'v',   1,  1384, 620, -1, 0,  1384, 620,-1,-1 ] # Santa Ana
out = [ 'v',   1,  1205, 668, -1, 0,  1205, 668,-1,-1 ] # Montebello
out = [ 'v',   1,  1142, 642, -1, 0,  1142, 642,-1,-1 ] # Los Angeles
out = [ 'v',   1,  1262, 532, -1, 0,  1262, 532,-1,-1 ] # Long Beach
out = [ 'v',   1,  1079, 589, -1, 0,  1079, 589,-1,-1 ] # Westwood
out = [ 'v',   1,   951, 961, -1, 0,   951, 961,-1,-1 ] # Lancaster

