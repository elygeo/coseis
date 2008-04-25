% Semi-cylindrical canyon with vertically incident P-wave.
np  = [ 1, 1, 2 ];		% number of processors
nn  = [ 301, 321, 2 ];		% number of nodes
nt  = 6000;			% number of time steps
dt  = 0.002;			% time step length
dx  = 0.0075;			% spatial step length
rho = 1.;			% density
vp  = 2.;			% P-wave speed
vs  = 1.;			% S-wave speed
gam = 0.0;			% viscosity
hourglass = [ 1., 2. ];	% hourglass stiffness and viscosity

% Read mesh from disk
datadir = 'canyon/data';
x1  = { 'read', 'zone', 1, 1, 1   -1, -1, 1 };
x2  = { 'read', 'zone', 1, 1, 1   -1, -1, 1 };

bc1 = [ 0,  0, 1 ];		% free surface and mirror boundary conditions
bc2 = [ 1, -1, 1 ];		

% Source paramters
faultnormal = 0;		% disable rupture dynamics
tfunc    = 'ricker1';		% Ricker wavelet (Gaussian 1st derivative)
tsource  = 2.;			% 2 second source period
moment1  = [  0., 1., 0. ];	% Specify y displacement (moment is a misleadingly name here)
moment2  = [  0., 0., 0. ];
i1source = [ -1,  0,  1  ];	% location of finites source
i2source = [ -1, -1, -1  ];

% Output
out = { 'x',   1,  1,  1, 1, 0,  -1, -1, 1,  0 };
out = { 'u', 500,  1,  1, 1, 0,  -1, -1, 1, -1 }; % snaps
out = { 'u',   1,  1,  1, 1, 0,   1, -1, 1, -1 }; % canyon
out = { 'u',   1,  2,  1, 1, 0, 158,  1, 1, -1 }; % flank
out = { 'u',   1, -1, -1, 1, 0,  -1, -1, 1, -1 }; % source

