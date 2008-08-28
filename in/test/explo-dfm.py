# Explosion test problem for comparison with DFM
np = [ 1, 2, 1 ]
nn = [ 101, 101, 61 ]
dx = 100.
dt = 0.008
nt = 200
vp  = 6000.
vs  = 3464.
rho = 2700.
gam = 0.3
hourglass = [ 1., 0.3 ]
faultnormal = 0
rexpand = 1.06
n1expand = [ 20, 20, 20 ]
n2expand = [ 20, 20, 20 ]
moment1 = [ 1e18, 1e18, 1e18 ]
moment2 = [ 0, 0, 0 ]
tfunc = 'brune'
tsource = 0.1
xhypo = [ 0., 0., 0. ]
bc1 = [ 0, 0, 0 ]
bc2 = [ 0, 0, 0 ]
ihypo = [ 31, 31, 31 ]

timeseries = [ 'x',    0., 3999., 0. ]
timeseries = [ 'v',    0., 3999., 0. ]
timeseries = [ 'x', 2999., 3999., 0. ]
timeseries = [ 'v', 2999., 3999., 0. ]
timeseries = [ 'x', 3999., 3999., 0. ]
timeseries = [ 'v', 3999., 3999., 0. ]

fixhypo = -1; rsource = 100.
fixhypo = -2; rsource = 50.

