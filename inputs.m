%------------------------------------------------------------------------------%
% INPUTS

model = 'normal';
model = 'pointsrc';
model = 'kostrov';
model = 'strikeslip';
model = '';
grid = 'constant';
plotstyle = 'slice';
n = [ 21 21 21 ];
nt = 20;
h = 100;
dt = .007;
nu = .25;
vp = 6000;
vs = sqrt( vp ^ 2 * ( nu - .5 ) / ( nu - 1 ) );  % 3464.1
nrmdim = 2;
vrup = .9 * vs;
rcrit = 1000;
nclramp = 10;
material = [ 2670  vp  vs    1 1 1  -1 -1 -1 ];
viscosity = [ 0 .3 ];
noise = 0;
nrmdim = 0;
hypocenter = 0;
msrcradius = 0;
stress   = [];
friction = [];
traction = [];
truptol = .001;
checkpoint = -1;
symmetries = [];
npml = 0;
locknodes = [
  1 1 1    1  1  1    1 -1 -1   % top
  1 1 1    1  1  1   -1  1 -1   % front
  1 1 1    1  1  1   -1 -1  1   % left
  1 1 1   -1  1  1   -1 -1 -1   % bottom
  1 1 1    1 -1  1   -1 -1 -1   % back
  1 1 1    1  1 -1   -1 -1 -1   % right
];
out = {
  'v' 1    1  1  1   -1 -1  1   % surface
  'w' 1    1  1  1   -1 -1  1   % surface
  'v' 1    1  0  1   -1  0  1   % fault
  'w' 1    1  0  1   -1  0  1   % fault
};
switch model
case ''
case 'pointsrc'
  moment = -1e14 * [ 0 0 0   0 0 1 ];
  moment = -1e14 * [ 1 1 1   0 0 0 ];
  msrctimefcn = 'delta';
  msrctimefcn = 'sbrune';
  msrcradius = 2.5 * h;
  msrcnodealign = 1;
case 'strikeslip'
  nrmdim = 2;
  friction = [ 1 .5   .4 0   1 0 1   -1  0 -1 ];
  traction = [ 9e7 -1e8 0    1 0 1   -1  0 -1 ];
case 'normal'
  nrmdim = 2;
  grid = 'normal';
  friction = [ 1 .5   .4 0   1 0 1   -1  0 -1 ];
  traction = [ 0 -1e8 9e7    1 0 1   -1  0 -1 ];
case 'kostrov'
  friction = [ 1e10 1   1e10 0   1 1 1  -1 -1 -1 ]; rcrit = 1e10;
  traction = [ -100e6 -90e6 0    1 1 1  -1 -1 -1 ];
  grid = 'slant';
  grid = 'constant';
  n = [ 201 201 201 ]; nt = 400; plotstyle = '';
  n = [  21  21  21 ]; nt =  90; plotstyle = 'slice';
case 'agu'
  nrmdim = 2;
  friction = [ .6 .5   .25 0    1 1 1   -1 -1 -1 ];
  traction = [ -70e6 -120e6 0   1 1 1   -1 -1 -1 ];
  grid = 'stretch';
  grid = 'slant';
  grid = 'constant';
case 'luis'
  friction = [ .677 .525   .4 0   2 0 1   4 0 3 ];
  traction = [ -81.6e6 -120e6 0   3 0 2   3 0 2 ];
case 'the2'
  nrmdim = 2;
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
  nrmdim = 2;
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
    friction = [ .677 .525   .4 0   16 0 16   -16 0 40 ]; % CHECK!
    traction = [ -81.6e6 -120e6 0   39 0 26   -39 0 30 ]; % CHECK!
    hypocenter = [ 12 ceil( n(2:3) / 2 ) ]; % CHECK!
  end
  symmetries = { 'xmirror' 1 1; 'x180' 2 0 };
otherwise error model
end

