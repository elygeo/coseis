%------------------------------------------------------------------------------%
% DEFAULTS

plotstyle = 'outline';
gui = 1;
n = [ 21 21 21 20 ];
dx = 100.;
dt = .007;
nu = .25;
rho0 = 2670.;
vp = 6000.;
vs = sqrt( vp ^ 2 * ( nu - .5 ) / ( nu - 1 ) );  % 3464.1
grid = 'constant';
nrmdim = 2;
vrup = .9 * vs;
rcrit = 1000.;
nclramp = 10;
material = [ rho0 vp vs        1 1 1   -1 -1 -1 ];
friction = [ .6 .5   .25 .0    1 1 1   -1 -1 -1 ];
traction = [ -70e6 -120e6 0.   1 1 1   -1 -1 -1 ];
stress   = [];
viscosity = [ .0 .3 ];
hypocenter = 0;
msrcradius = 0.;
planewavedim = 0;
truptol = .001;
checkpoint = 0;
symmetries = [];
npml = 0;
bc = [ 1 1 0   1 1 1 ];
locknodes = [];
out = {
  'u'   1    1  1  1   -1 -1  1   % surface
  'v'   1    1  1  1   -1 -1  1   % surface
  'w'   1    1  1  1   -1 -1  1   % surface
  'u'   1    1  1  0   -1 -1  0   % depth plane
  'v'   1    1  1  0   -1 -1  0   % depth plane
  'w'   1    1  1  0   -1 -1  0   % depth plane
  'u'   1    1  0  1   -1  0 -1   % fault plane
  'v'   1    1  0  1   -1  0 -1   % fault plane
  'w'   1    1  0  1   -1  0 -1   % fault plane
  'u'   1    0  1  1    0 -1 -1   % cross section
  'v'   1    0  1  1    0 -1 -1   % cross section
  'w'   1    0  1  1    0 -1 -1   % cross section
};
out = {};

