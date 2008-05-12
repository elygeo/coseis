% PEER LOH.1

np = [ 1, 1, 2 ];
nn = [ 91, 111, 61 ];
nt = 1125;
dx = 100;
dt = 0.008;
dt = 0.017;
dt = 0.015;
dt = 0.012;

bc1 = [ -2, -2,  0 ];
bc2 = [ 10, 10, 10 ];




rho = 2700.; rho = { 2600., 'zone',   1, 1, 1,   -1, -1, 11 };
vp  = 6000.; vp  = { 4000., 'zone',   1, 1, 1,   -1, -1, 11 };
vs  = 3464.; vs  = { 2000., 'zone',   1, 1, 1,   -1, -1, 11 };
gam = 0.;
hourglass = [ 1., 2. ];

faultnormal = 0;
ihypo = [ 1, 1, 21 ];
xhypo = [ 0., 0., 2000. ];
fixhypo = -2;
tfunc = 'brune';
rfunc = 'point';
tsource = 0.1;
rsource = 1.;
moment1 = [ 0., 0., 0. ];
moment2 = [ 0., 0., 1e18 ];

timeseries = { 'v',  5999.,  7999., -1. };
timeseries = { 'v',  6001.,  8001., -1. };

