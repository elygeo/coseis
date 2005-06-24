%------------------------------------------------------------------------------%
% DEFAULTS

plotstyle = 'outline';
n = [ 21 21 21 ];
nt = 20;
h = 100;
dt = .007;
nu = .25;
vp = 6000;
vs = sqrt( vp ^ 2 * ( nu - .5 ) / ( nu - 1 ) );  % 3464.1
grid = 'constant';
nrmdim = 2;
vrup = .9 * vs;
rcrit = 1000;
nclramp = 10;
material = [ 2670   vp vs     1 1 1   -1 -1 -1 ];
friction = [ .6 .5   .25 0    1 1 1   -1 -1 -1 ];
traction = [ -70e6 -120e6 0   1 1 1   -1 -1 -1 ];
stress   = [];
viscosity = [ 0 .3 ];
noise = 0;
hypocenter = 0;
msrcradius = 0;
planewavedim = 0;
truptol = .001;
checkpoint = -1;
symmetries = [];
npml = 0;
bc = [ 1 1 0   1 1 1 ];
locknodes = [
  1 1 1    1  1  1    1 -1 -1   % top
  1 1 1    1  1  1   -1  1 -1   % front
  1 1 1    1  1  1   -1 -1  1   % left
  1 1 1   -1  1  1   -1 -1 -1   % bottom
  1 1 1    1 -1  1   -1 -1 -1   % back
  1 1 1    1  1 -1   -1 -1 -1   % right
];
locknodes = [];
out = {
  'u' 1    1  1  1   -1 -1  1
  'v' 1    1  1  1   -1 -1  1
  'w' 1    1  1  1   -1 -1  1
  'u' 1    1  1  0   -1 -1  0
  'v' 1    1  1  0   -1 -1  0
  'w' 1    1  1  0   -1 -1  0
  'u' 1    1  0  1   -1  0 -1
  'v' 1    1  0  1   -1  0 -1
  'w' 1    1  0  1   -1  0 -1
  'u' 1    0  1  1    0 -1 -1
  'v' 1    0  1  1    0 -1 -1
  'w' 1    0  1  1    0 -1 -1
};
out = {
  'u' 1    1  1  1    0  0  0
  'v' 1    1  1  1    0  0  0
  'w' 1    1  1  1    0  0  0
};

