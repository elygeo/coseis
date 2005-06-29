%------------------------------------------------------------------------------%
% sord

defaults
model = 'normal';
model = 'the3';
model = '';
model = 'strikeslip';
switch model
case ''
  nrmdim = 0;
  n = [ 3 3 3 ]; nt = 1;
case 'unit'
  material = [ 1   1 1     1 1 1   -1 -1 -1 ];
  viscosity = [ 0 .3 ];
  npml = 2;
  bc = [ 1 1 1   1 1 1 ];
case 'strikeslip'
  n = [ 41 41 41 ]; nt = 60;
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

