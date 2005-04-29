%------------------------------------------------------------------------------%
% INPUTS

model = 'agu';
model = 'agu';
model = 'normal';
model = 'test';
model = 'pointsrc';
model = 'kostrov';
model = 'the3';
model = 'strikeslip';
n = [ 21 21 21 ];
nt = 20;
dt = .5;
h = 1;
material = [ 1 sqrt(3) 1   1 1 1  -1 -1 -1 ];
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
plotstyle = 'slice';
grid = 'constant';
locknodes = [
  1 1 1   1  1  1   1 -1 -1   % top
  1 1 1   1  1  1  -1  1 -1   % front
  1 1 1   1  1  1  -1 -1  1   % left
  1 1 1  -1  1  1  -1 -1 -1   % bottom
  1 1 1   1 -1  1  -1 -1 -1   % back
  1 1 1   1  1 -1  -1 -1 -1   % right
];
locknodes = [];
out = {};
out = {
  'v' 1   1  1  1   -1 -1  1
  'v' 1   1  0  1   -1  0  1
  'w' 1   1  1  1   -1 -1  1
  'w' 1   1  0  1   -1  0  1
};
switch model
case { '', 'none' }
case { 'test' }
  viscosity = [ 0 0 ];
case 'pointsrc'
  viscosity = [ 0 0 ];
  h = 100;
  dt = 0.007;
  material = [ 2670 6000 3464   1 1 1  -1 -1 -1 ];
  moment = -1e14 * [ 0 0 0  0 0 1 ];
  moment = -1e14 * [ 1 1 1  0 0 0 ];
  mSrcTimeFcn = 'delta';
  msrctimefcn = 'brune';
  msrctimefcn = 'sine';
  msrctimefcn = 'sbrune';
  msrcradius = 2.5 * h;
  msrcnodealign = 1;
  n = [ 6  6  6  ] + msrcnodealign; nt = 20;
  n = [ 50 50 10 ] + msrcnodealign; nt = 20;
  n = [ 20 20 20 ] + msrcnodealign; nt = 20;
  grid = 'slant';
  grid = 'constant';
case 'strikeslip'
  n = 20 * [ 2 2 1 ] + 1;
  nt = 20;
  grid = 'normal';
  grid = 'hill';
  grid = 'curve';
  grid = 'spherical';
  grid = 'constant';
  nclramp = 10;
  nrmdim = 2;
  rcrit = 5;
  vrup = 1;
  traction = [ -1 -1 0       1 1 1  -1 -1 -1 ];
  friction = [ 1.5 .5   5 0  1 1 1  -1 -1 -1 ];
case 'kostrov'
  nu = .25;
  vp = 6000;
  vs = 3464.1;
  vs = sqrt( vp ^ 2 * ( nu - .5 ) / ( nu - 1 ) );
  nrmdim = 2;
  nclramp = 10;
  viscosity = [ .3 .3 ];
  vrup = .9 * vs;
  material = [ 2670  vp  vs    1 1 1  -1 -1 -1 ];
  friction = [ 1.2 .5 1 0      1 1 1  -1 -1 -1 ]; rcrit = 500;
  friction = [ 1e10 1 1e10 0   1 1 1  -1 -1 -1 ]; rcrit = 1e10;
  traction = [ -100e6 -90e6 0  1 1 1  -1 -1 -1 ];
  h = 100;
  dt = 0.007;
  grid = 'slant';
  grid = 'constant';
  n = [ 201 201 201 ]; nt = 400; plotstyle = '';
  n = [  41  41  41 ]; nt =  90; plotstyle = 'slice';
  n = [  5  5  5 ]; nt =  10; plotstyle = 'slice';
  n = [  21  21  21 ]; nt =  90; plotstyle = 'slice';
  out = {
    'v'     1   1  1  1   -1 -1  1
    'v'     1   1  0  1   -1  0 -1
    'w'     1   1  1  1   -1 -1  1
    'w'     1   1  0  1   -1  0 -1
    'uslip' 1   0  0  0   -1  0  0
    'vslip' 1   0  0  0   -1  0  0
  };
case 'the2'
  nrmdim = 2;
  rcrit = 0;
  nclramp = 10;
  vrup = 0;
  material = [ 2670 6000 3464     1 1 1  -1 -1 -1 ];
  friction = [ 1e4 1e4 .4 0       1 1 1  -1 -1 -1 ];
  traction = [ -70e6 -120e6 0     1 1 1  -1 -1 -1 ];
  h = 100;
  switch h
  case 100
    dt = 0.007;
    nt = 50;
    n = [ 5 5 3 ];
    friction = [ friction; 0.677 0.525 .4 0   2 0 1   4 0 3 ];
    traction = [ traction; -81.6e6 -120e6 0   3 0 2   3 0 2 ];
  case 300;
    dt = 0.025;
    nt = 400;
    n = [ 81 161 81 ];
    friction = [ friction; 0.677 0.525 .4 0   31 0  1   -31 0 50 ]; % CHECK!
    traction = [ traction; -81.6e6 -120e6 0   76 0 21   -76 0 30 ]; % CHECK!
    hypocenter = [ 24 ceil( n(2:3) / 2 ) ]; % CHECK!
  case 600
    dt = 0.05;
    nt = 200;
    nt = 60;
    n = [ 41 81 41 ];
    friction = [ friction; 0.677 0.525 .4 0   16 0  1   -16 0 25 ];% CHECK!
    traction = [ traction; -81.6e6 -120e6 0   39 0 11   -39 0 15 ];% CHECK!
    hypocenter = [ 12 ceil( n(2:3) / 2 ) ];% CHECK!
  end
case 'the3'
  nrmdim = 2;
  rcrit = 0;
  nclramp = 10;
  vrup = 0;
  truptol = .001
  material = [ 2670 6000 3464  1 1 1  -1 -1 -1 ];
  friction = [ 1e4 1e4 0 0     1 1 1  -1 -1 -1 ];
  traction = [ -70e6 -120e6 0  1 1 1  -1 -1 -1 ];
  h = 600;
  switch h
  case 100
    dt = 0.007;
    nt = 1858;
    nt = 50;
    n = [ 5 5 3 ];
    friction = [ friction; 0.677 0.525 .4 0   2 0 1  4 0 3 ];
    traction = [ traction; -81.6e6 -120e6 0   3 0 2  3 0 2 ];
  case 300
    dt = 0.025;
    nt = 520;
    n = [ 161 81 111 ];
    friction = [ friction; 0.677 0.525 .4 0   31 0 31   -31 0 -31 ];% CHECK!
    traction = [ traction; -81.6e6 -120e6 0   76 0 51   -76 0 -51 ];% CHECK!
    hypocenter = [ 24 ceil( n(2:3) / 2 ) ];% CHECK!
  case 600
    dt = 0.05;
    nt = 150;
    n = [ 81 41 56 ] + 2;
    friction = [ 0.677 0.525 .4 0   16 0 16   -16 0 40 ];% CHECK!
    traction = [ -81.6e6 -120e6 0   39 0 26   -39 0 30 ];% CHECK!
    hypocenter = [ 12 ceil( n(2:3) / 2 ) ];  % CHECK!
  end
  symmetries = { 'xmirror' 1 1; 'x180' 2 0 };
case 'normal'
  h = 100;
  dt = 0.007;
  nt = 40;
  n = [ 41 41 21 ];
  n = [ 21 21 11 ];
  grid = 'constant';
  grid = 'slant';
  grid = 'normal';
  rcrit = 2000;
  rcrit = 1000;
  vrup = 3000;
  nclramp = 10;
  nrmdim = 0;
  nrmdim = 2;
  %msrcradius = 200; moment = -1e4 * [ 0 0 0  0 0 1 ];
  material = [ 2670 6000 3464   1 1 1   -1 -1 -1 ];
  friction = [ 1 0.5 .4 0       1 0 1   -1  0 -1 ];
  traction = [ 0 -1e8 -9e7      1 0 1   -1  0 -1 ];
case 'luis'
  friction = [ 0.677 0.525 .4 0   2 0 1   4 0 3 ];
  traction = [ -81.6e6 -120e6 0   3 0 2   3 0 2 ];
case 'agu'
  nrmdim = 2;
  nclramp = 10;
  friction = [ 0.6 0.5  .25 0   1 1 1   -1 -1 -1 ];
  traction = [ -70e6 -120e6 0   1 1 1   -1 -1 -1 ];
  material = [ 2670 6000 3464   1 1 1   -1 -1 -1 ];
  h = 100;
  switch h
  case 50
  case 100
    dt = 0.007;
    vrup  = 3000;
    rcrit = 1000;
    n  = [ 81 41 81 ]; nt = 120;
    n  = [ 41 21 41 ]; nt = 60;
  end
  grid = 'stretch';
  grid = 'slant';
  grid = 'rand';
  grid = 'constant';
otherwise error model
end

