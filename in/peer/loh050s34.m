% PEER LOH.1

np = [ 1 32 1 ];
nn = [ 601 751 161 ];
nt = 2250;
dx = 50.
dt = 0.004;

affine = [ 1. 0. 1.   1. 1. 0.   0. 0. 1.   1. ];
n1expand = [ 60 60  0 ];
n2expand = [ 60 60  0 ];
bc1 = [ 0 0  0 ];
bc2 = [ 0 0 10 ];

rho = 2700.; rho = { 2600. 'zone'   1 1 1   -1 -1 21 };
vp  = 6000.; vp  = { 4000. 'zone'   1 1 1   -1 -1 21 };
vs  = 3464.; vs  = { 2000. 'zone'   1 1 1   -1 -1 21 };
gam = 0.;
hourglass = [ 1. 2. ];

faultnormal = 0;
ihypo = [ 320 421 41 ];
xhypo = [ 0. 0. 2000. ];
fixhypo = -2;	
tfunc = 'brune';
tsource = 0.1;
rfunc = 'point';
rsource = 1.;
moment1 = [ 0. 0. 0. ];
moment2 = [ 0. 0. 1e18 ];

timeseries = { 'v'  5999.  7999. -1. };
timeseries = { 'v'  5999. -7999. -1. };
timeseries = { 'v' -5999. -7999. -1. };
timeseries = { 'v' -5999.  7999. -1. };

