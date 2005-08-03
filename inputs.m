%------------------------------------------------------------------------------%
% INPUTS

defaults
model = 'normal';
model = 'the3';
model = '';
model = 'strikeslip';
model = 'explosion';
model = 'kostrov';
model = 'boris';
switch model
case ''
  nrmdim = 0;
  n = [ 3 3 3 1 ];
case 'kostrov'
  npml = 10;
  nclramp = 0;
  viscosity = [ 0 .3 ];
  bc = [ 0 1 0   0 1 0 ];
  rcrit = 1e9;
  friction = [ 1e9 1   1e9 0   1 1 1  -1 -1 -1 ];
  traction = [ -100e6 -90e6 0    1 1 1  -1 -1 -1 ];
  grid = 'slant';
  grid = 'constant';
  n = [ 101  41 101 200 ]; plotstyle = 'fault';
  n = [ 201  41 201 400 ]; plotstyle = '';
  n = [  61  41  61 120 ]; plotstyle = 'fault';
  n = [  41  41  41  90 ]; plotstyle = 'fault';
  out = {
    'uslip' 1    0  0  0   -1 -0 -0
    'vslip' 1    0  0  0   -1 -0 -0
    'v'     1    1  1  1   -1 -0 -0
  };
case 'explosion'
  bc = [ 0 1 0   0 1 0 ]; grid = 'slant';
  bc = [ 1 1 1   1 1 1 ]; grid = 'constant';
  n = [ 40 40 40 120 ]; msrcnodealign = 0;
  n = [ 11 11 11 120 ]; msrcnodealign = 1;
  n = [ 61 41 61 120 ]; msrcnodealign = 1;
  n = [ 41 41 41 120 ]; msrcnodealign = 1;
  msrcradius = 1.5 * dx;
  viscosity = [ .3 .3 ];
  viscosity = [ 0 .3 ];
  srctimefcn = 'brune';
  srctimefcn = 'sbrune';
  moment = 1e16 * [ 1 1 1   0 0 0 ];
  npml = 0;
  npml = 10;
  plotstyle = 'slice';
  nrmdim = 0;
  out = { 'v' 1    1  1  1    -1  0  0 };
case 'unit'
  material = [ 1   1 1     1 1 1   -1 -1 -1 ];
  viscosity = [ 0 .3 ];
  npml = 2;
  bc = [ 1 1 1   1 1 1 ];
case 'strikeslip'
  n = [ 41 41 41 60 ];
  grid = 'curve';
  grid = 'constant';
  plotstyle = 'slice';
case 'normal'
  grid = 'normal';
  traction = [ 0 -120e6 -70e6   1 0 1   -1  0 -1 ];
case 'luis'
  friction = [ .677 .525   .4 0   2 0 1   4 0 3 ];
  traction = [ -81.6e6 -120e6 0   3 0 2   3 0 2 ];
case 'the2'
  rcrit = 0;
  vrup = 0;
  friction = [ 1e4 1e4   .4 0   1 1 1   -1 -1 -1 ];
  traction = [ -70e6 -120e6 0   1 1 1   -1 -1 -1 ];
  dx = 100;
  switch dx
  case 100
    dt = .007;
    n = [ 5 5 3 50 ];
    friction = [ friction; .677 .525   .4 0   2 0 1   4 0 3 ];
    traction = [ traction; -81.6e6 -120e6 0   3 0 2   3 0 2 ];
  case 300;
    dt = .025;
    n = [ 81 161 81 400 ];
    friction = [ friction; .677 .525   .4 0   31 0  1   -31 0 50 ]; % CHECK!
    traction = [ traction; -81.6e6 -120e6 0   76 0 21   -76 0 30 ]; % CHECK!
    hypocenter = [ 24 ceil( n(2:3) / 2 ) ]; % CHECK!
  case 600
    dt = .05;
    n = [ 41 81 41 60 ];
    friction = [ friction; .677 .525   .4 0   16 0  1   -16 0 25 ]; % CHECK!
    traction = [ traction; -81.6e6 -120e6 0   39 0 11   -39 0 15 ]; % CHECK!
    hypocenter = [ 12 ceil( n(2:3) / 2 ) ]; % CHECK!
  end
case 'the3'
  rcrit = 0;
  vrup = 0;
  friction = [ 1e4 1e4   0 0     1 1 1   -1 -1 -1 ];
  traction = [ -70e6 -120e6 0    1 1 1   -1 -1 -1 ];
  dx = 600;
  switch dx
  case 100
    dt = .007;
    n = [ 5 5 3 50 ];
    friction = [ friction; .677 .525   .4 0   2 0 1   4 0 3 ];
    traction = [ traction; -81.6e6 -120e6 0   3 0 2   3 0 2 ];
  case 300
    dt = .025;
    n = [ 161 81 111 520 ];
    friction = [ friction; .677 .525   .4 0   31 0 31   -31 0 -31 ]; % CHECK!
    traction = [ traction; -81.6e6 -120e6 0   76 0 51   -76 0 -51 ]; % CHECK!
    hypocenter = [ 24 ceil( n(2:3) / 2 ) ]; % CHECK!
  case 600
    dt = .05;
    n = [ 81 41 56 150 ];
    friction = [ friction; .677 .525   .4 0   16 0 16   -16 0 40 ]; % CHECK!
    traction = [ traction; -81.6e6 -120e6 0   39 0 26   -39 0 30 ]; % CHECK!
    hypocenter = [ 12 ceil( n(2:3) / 2 ) ]; % CHECK!
  end
case 'boris'
  nrmdim = 3;
  npml = 10;
  bc = [ 0 0 0   0 0 0 ];
  n = [ 220 220 220 400 ];
  dx = .02;
  dt = .00005;
  vrup = 15;
  rcrit = .4;
  viscosity = [ .5 .5 ];
  hypocenter = [ 110 110 110 ];
  material = [ 16 56 30            1 1 1  -1 -1 -1 ];
  fiction  = [ 1.85 2.4   .001 0   1 1 1  -1 -1 -1 ];
  traction = [ 0 730 -330          1 1 1  -1 -1 -1 ];
  out      = { 'v' 1               11 1 1  11 -0 -0
               'v' 1               1 11 1  -0 11 -0
               'v' 1               1 1 11  -0 -0 11 };
  plotstyle = '';
case 'foam_ms'
  nw = 1;  % no weak zone
  nw = 11; % 20cm weak zone
  bc = [ 0 0 0   0 0 0 ];
  n = [ 111 221 141 999 ];
  dx = .02;
  dt = .00015;
  vrup = 15;
  rcrit = .4;
  viscosity = [ .5 .5 ];
  hypocenter = [ 111 111 71 ];
  material = [ 16 56 30            1 1 1   -1 -1 -1 ];
  fiction  = [ 0.6  0.6   .001 0   1 1 1   -1 -1 -1
               1.85 2.3   .001 0   1 1 nw  -1 -1 -1 ];
  traction = [  66 -330 0          1 1 1   -1 -1 -1
               730 -330 0          1 1 nw  -1 -1 -1 ];
otherwise error model
end

