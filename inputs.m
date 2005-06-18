%------------------------------------------------------------------------------%
% INPUTS

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
  'u' 1    1  1  1   -1 -1 -1
  'v' 1    1  1  1   -1 -1 -1
  'w' 1    1  1  1   -1 -1 -1
};
model = 'normal';
model = 'the3';
model = 'strikeslip';
model = '';
model = 'pointsrc';
model = 'kostrov';
switch model
case ''
  nrmdim = 0;
  n = [ 3 3 3 ]; nt = 1;
case 'unit'
  material = [ 1   1 1     1 1 1   -1 -1 -1 ];
  viscosity = [ 0 .3 ];
  npml = 2;
  bc = [ 1 1 1   1 1 1 ];
case 'pointsrc'
  nt = 100;
  n = [ 40 40 40 ]; msrcnodealign = 0;
  n = [ 11 11 11 ]; msrcnodealign = 1;
  n = [ 81 81 21 ]; msrcnodealign = 1;
  n = [ 41 41 41 ]; msrcnodealign = 1;
  msrcradius = 0;
  msrcradius = 2.5 * h;
  srctimefcn = 'brune';
  srctimefcn = 'sbrune';
  moment = -1e18 * [ 1 1 1   0 0 0 ];
  npml = 0;
  npml = 10;
  plotstyle = 'slice';
  nrmdim = 0;
case 'strikeslip'
  plotstyle = 'slice';
case 'normal'
  grid = 'normal';
  traction = [ 0 -120e6 -70e6   1 0 1   -1  0 -1 ];
case 'kostrov'
  npml = 0;
  npml = 10;
  rcrit = 1e10;
  friction = [ 1e10 1   1e10 0   1 1 1  -1 -1 -1 ];
  traction = [ -100e6 -90e6 0    1 1 1  -1 -1 -1 ];
  grid = 'slant';
  grid = 'constant';
  n = [ 201 201 201 ]; nt = 400; plotstyle = '';
  n = [  31  31  31 ]; nt =  90; plotstyle = 'fault';
case 'luis'
  friction = [ .677 .525   .4 0   2 0 1   4 0 3 ];
  traction = [ -81.6e6 -120e6 0   3 0 2   3 0 2 ];
case 'the2'
  rcrit = 0;
  vrup = 0;
  friction = [ 1e4 1e4   .4 0   1 1 1   -1 -1 -1 ];
  traction = [ -70e6 -120e6 0   1 1 1   -1 -1 -1 ];
  h = 100;
  switch h
  case 100
    dt = .007;
    nt = 50;
    n = [ 5 5 3 ];
    friction = [ friction; .677 .525   .4 0   2 0 1   4 0 3 ];
    traction = [ traction; -81.6e6 -120e6 0   3 0 2   3 0 2 ];
  case 300;
    dt = .025;
    nt = 400;
    n = [ 81 161 81 ];
    friction = [ friction; .677 .525   .4 0   31 0  1   -31 0 50 ]; % CHECK!
    traction = [ traction; -81.6e6 -120e6 0   76 0 21   -76 0 30 ]; % CHECK!
    hypocenter = [ 24 ceil( n(2:3) / 2 ) ]; % CHECK!
  case 600
    dt = .05;
    nt = 200;
    nt = 60;
    n = [ 41 81 41 ];
    friction = [ friction; .677 .525   .4 0   16 0  1   -16 0 25 ]; % CHECK!
    traction = [ traction; -81.6e6 -120e6 0   39 0 11   -39 0 15 ]; % CHECK!
    hypocenter = [ 12 ceil( n(2:3) / 2 ) ]; % CHECK!
  end
case 'the3'
  rcrit = 0;
  vrup = 0;
  friction = [ 1e4 1e4   0 0     1 1 1   -1 -1 -1 ];
  traction = [ -70e6 -120e6 0    1 1 1   -1 -1 -1 ];
  h = 600;
  switch h
  case 100
    dt = .007;
    nt = 1858;
    nt = 50;
    n = [ 5 5 3 ];
    friction = [ friction; .677 .525   .4 0   2 0 1   4 0 3 ];
    traction = [ traction; -81.6e6 -120e6 0   3 0 2   3 0 2 ];
  case 300
    dt = .025;
    nt = 520;
    n = [ 161 81 111 ];
    friction = [ friction; .677 .525   .4 0   31 0 31   -31 0 -31 ]; % CHECK!
    traction = [ traction; -81.6e6 -120e6 0   76 0 51   -76 0 -51 ]; % CHECK!
    hypocenter = [ 24 ceil( n(2:3) / 2 ) ]; % CHECK!
  case 600
    dt = .05;
    nt = 150;
    n = [ 81 41 56 ] + 2;
    friction = [ friction; .677 .525   .4 0   16 0 16   -16 0 40 ]; % CHECK!
    traction = [ traction; -81.6e6 -120e6 0   39 0 26   -39 0 30 ]; % CHECK!
    hypocenter = [ 12 ceil( n(2:3) / 2 ) ]; % CHECK!
  end
otherwise error model
end

