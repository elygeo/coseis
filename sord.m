%------------------------------------------------------------------------------%
% SORD - Support-Operator Rupture Dynamics
% Geoffrey Ely, gely@ucsd.edu

%profile report
%profile plot
%function sord
%profile clear
%profile on
clear all
%dbstop if error
format short e
format compact

%------------------------------------------------------------------------------%
% Input

model      = 'normal';
model      = 'pointsource';
model      = 'agu';
model      = 'the3';
model      = 'agu';
model      = 'fault';
model      = 'kostrov';
n          = [ 21 21 21 ];
nt         = 20;
dt         = .5;
h          = 1;
viscosity  = [ 0 .3 ];
material   = [ 1 sqrt(3) 1   1 -1   1 -1   1 -1 ];
downdim    = 1;
noise      = 0;
nrmdim     = 0;
hypocenter = 0;
srcgeom    = 0;
operator   = [];
stress     = [];
friction   = [];
traction   = [];
truptol    = .001;
checkpoint = -1;
plotstyle  = 'slice';
slicedim   = 3;
field      = 0;
symmetries = [];
locknodes  = [
  1 1 1   1  1   1 -1   1 -1   % top
  1 1 1   1 -1   1  1   1 -1   % front
  1 1 1   1 -1   1 -1   1  1   % left
  1 1 1  -1 -1   1 -1   1 -1   % bottom
  1 1 1   1 -1  -1 -1   1 -1   % back
  1 1 1   1 -1   1 -1  -1 -1   % right
];
locknodes  = [];
out = {
  'v' 1   1 -1   0  0   1  0   % x-sec
  'u' 1   1 -1   0  0   1  0   % x-sec
  'v' 1   1  1   0 -1   1  0   % surf
  'u' 1   1  1   0 -1   1  0   % surf
  'v' 1   1  1   1 -1   0 -1   % surf
  'u' 1   1  1   1 -1   0 -1   % surf
  'v' 1   1 -1   1  0   0  0   % fault
  'u' 1   1 -1   1  0   0  0   % fault
  'v' 1   1 -1   0 -1   0  0   % fault
  'u' 1   1 -1   0 -1   0  0   % fault
};
out = {};
switch model
case { '', 'none' }
case 'fault'
  n = 20 * [ 1 2 2 ] + 1;
  nt = 20;
  grid = 'map';
  grid = 'slant';
  grid = 'normal';
  grid = 'hill';
  grid = 'spherical';
  grid = 'curve';
  grid = 'constant';
  nrmdim   = 3;
  rcrit    = 5;
  vrup     = 1;
  traction = [ -1 0 -1        1 -1   1 -1   1 -1 ];
  friction = [ 1.5 .5   5 0   1 -1   1 -1   1 -1 ];
case 'luis'
  friction = [ 0.677 0.525 .4 0   1 3   2 4   0 0 ];
  traction = [ 0 -81.6e6 -120e6   2 2   3 3   0 0 ];
case 'agu'
  nrmdim   = 3;
  nclramp  = 10;
  friction = [ 0.6 0.5  .25 0   1 -1   1 -1   1 -1 ];
  traction = [ 0 -70e6 -120e6   1 -1   1 -1   1 -1 ];
  material = [ 2670 6000 3464   1 -1   1 -1   1 -1 ];
  h = 100;
  switch h
  case 50
  case 100
    dt = 0.007;
    vrup  = 3000;
    rcrit = 1000;
    n  = [ 81 81 41 ]; nt = 120;
    n  = [ 41 41 21 ]; nt = 60;
  end
  grid = 'stretch';  out = { 'v' 1 16 16 42 42 22 22; 'v' 1 42 42 27 27 22 22 };
  grid = 'slant';    out = { 'v' 1 18 18 30 30 22 22; 'v' 1 42 42 18 18 22 22 };
  grid = 'rand';     out = { 'v' 1 16 16 42 42 22 22; 'v' 1 42 42 12 12 22 22 };
  grid = 'constant'; out = { 'v' 1 16 16 42 42 22 22; 'v' 1 42 42 12 12 22 22 };
case 'kostrov'
  nu        = .25;
  vp        = 6000;
  vs        = 3464.1;
  vs        = sqrt( vp ^ 2 * ( nu - .5 ) / ( nu - 1 ) );
  nrmdim    = 3;
  nclramp   = 10;
  viscosity = [ .3 .3 ];
  vrup      = .9 * vs;
  material  = [ 2670  vp  vs     1 -1  1 -1   1 -1 ];
  friction  = [ 1.2 .5 1 0       1 -1  1 -1   1 -1 ]; rcrit = 500;
  friction  = [ 1e10 1 1e10 0    1 -1  1 -1   1 -1 ]; rcrit = 1e10;
  traction  = [ 0 -100e6 -90e6   1 -1  1 -1   1 -1 ];
  h  = 100;
  dt = 0.007;
  grid      = 'slant';
  grid      = 'constant';
  n  = [ 201 201 201 ]; nt = 400; plotstyle = '';
  n  = [  41  41  41 ]; nt =  90; plotstyle = 'slice';
  out = {
    'slipv' 1   0  0   0 -1   0  0
    'slipv' 1   1 -1   1 -1   1 -1
  };
case 'the2'
  grid      = 'constant';
  nrmdim    = 3;
  rcrit     = 0;
  nclramp   = 10;
  vrup      = 0;
  truptol   = .001
  material  = [ 2670 6000 3464     1 -1   1 -1   1 -1 ];
  friction  = [ 1e4 1e4 .4 0       1 -1   1 -1   1 -1 ];
  traction  = [ 0 -70e6 -120e6     1 -1   1 -1   1 -1 ];
  h = 100;
  switch h
  case 100
    dt = 0.007;
    nt = 50;
    n  = [ 5 5 3 ];
    friction = [ friction; 0.677 0.525 .4 0   1 3   2 4   0 0 ];
    traction = [ traction; 0 -81.6e6 -120e6   2 2   3 3   0 0 ];
  case 300;
    dt = 0.025;
    nt = 400;
    n  = [ 81 161 81 ];
    friction = [ friction; 0.677 0.525 .4 0    1 50  31 -31  0 0 ]; % CHECK!
    traction = [ traction; 0 -81.6e6 -120e6   21 30  76 -76  0 0 ]; % CHECK!
    hypocenter = [ 24 ceil( n(2:3) / 2 ) ]; % CHECK!
  case 600
    dt = 0.05;
    nt = 200;
    nt = 60;
    n  = [ 41 81 41 ];
    friction = [ friction; 0.677 0.525 .4 0    1 25  16 -16  0 0 ];% CHECK!
    traction = [ traction; 0 -81.6e6 -120e6   11 15  39 -39  0 0 ];% CHECK!
    hypocenter = [ 12 ceil( n(2:3) / 2 ) ];% CHECK!
  end
case 'the3'
  grid      = 'constant';
  nrmdim    = 3;
  rcrit     = 0;
  nclramp   = 10;
  vrup      = 0;
  truptol   = .001
  material  = [ 2670 6000 3464   1 -1   1 -1   1 -1 ];
  friction  = [ 1e4 1e4 0 0      1 -1   1 -1   1 -1 ];
  traction  = [ 0 -70e6 -120e6   1 -1   1 -1   1 -1 ];
  h = 600;
  switch h
  case 100
    dt = 0.007;
    nt = 1858;
    nt = 50;
    n  = [ 5 5 3 ];
    friction = [ friction; 0.677 0.525 .4 0   1 3  2 4  0 0 ];
    traction = [ traction; 0 -81.6e6 -120e6   2 2  3 3  0 0 ];
  case 300
    dt = 0.025;
    nt = 520;
    n  = [ 111 161 81 ];
    friction = [ friction; 0.677 0.525 .4 0   31 -31  31 -31  0 0 ];% CHECK!
    traction = [ traction; 0 -81.6e6 -120e6   51 -51  76 -76  0 0 ];% CHECK!
    hypocenter = [ 24 ceil( n(2:3) / 2 ) ];% CHECK!
  case 600
    dt = 0.05;
    nt = 150;
    n  = [ 56 81 41 ] + 2;
    friction = [ 0.677 0.525 .4 0   16 40  16 -16  0 0 ];% CHECK!
    traction = [ 0 -81.6e6 -120e6   26 30  39 -39  0 0 ];% CHECK!
    hypocenter = [ 12 ceil( n(2:3) / 2 ) ];  % CHECK!
  end
  symmetries = { 'xmirror' 1 1; 'x180' 2 0 };
case 'normal'
  h = 100;
  dt = 0.007;
  nt = 40;
  n = [ 21 41 41 ];
  n = [ 11 21 21 ];
  grid     = 'constant';
  grid     = 'slant';
  grid     = 'normal';
  rcrit    = 2000;
  rcrit    = 1000;
  vrup     = 3000;
  nclramp  = 10;
  nrmdim   = 0;
  nrmdim   = 3;
  %srcgeom = 32; moment = -1e4 * [ 0 0 0  0 0 1 ];
  material = [ 2670 6000 3464   1 -1   1 -1   1 -1 ];
  friction = [ 1 0.5 .4 0       1 -1   1 -1   0  0 ];
  traction = [ -9e7 0 -1e8      1 -1   1 -1   0  0 ];
case 'pointsource'
  if 0
    moment = [ 1 1 1  0 0 0 ];
  else
    h = 100;
    dt = 0.007;
    material = [ 2670 6000 3464   1 -1   1 -1   1 -1 ];
    moment = -1e14 * [ 0 0 0  0 0 1 ];
    moment = -1e14 * [ 1 1 1  0 0 0 ];
  end
  srcgeom = 32; a = 0;
  srcgeom = 8;  a = 0;
  srcgeom = 1;  a = 1;
  n = a + [ 3 3 3 ];    nt = 60;
  n = a + [ 2 2 2 ];    nt = 2;
  n = a + [ 61 61 2 ];  nt = 60;
  n = a + [ 21 21 21 ]; nt = 22;
  grid = 'staggered';
  grid = 'normal';
  grid = 'slant';
  grid = 'constant';
  grid = 'stretch';
  grid = 'rand';
otherwise, error( 'unknown model type' )
end

if ~hypocenter, hypocenter = ceil( n / 2 ); end
if nrmdim, n(nrmdim) = n(nrmdim) + 1; end
halo = [ 1 -1    1 -1    1 -1 ];
core = [ 1 n(1)  1 n(1)  1 n(3) ] + halo;
h1 = halo(1:2:5);
h2 = halo(2:2:6);
n = n + h1 + h2;
hypocenter = hypocenter + h1;

if length( locknodes )
  locknodes(downdim,1:3) = 0;
  if n(1) < 5, locknodes([1 4],1:3) = 0; end
  if n(2) < 5, locknodes([2 5],1:3) = 0; end
  if n(3) < 5, locknodes([3 6],1:3) = 0; end
end
for i = 1:size( locknodes, 1 )
  [ i1, i2 ] = zoneselect( locknodes(i,:), 3, core, hypocenter, nrmdim );
  locknodes(i,[1:2:5 2:2:6]+3) = [ i1 i2 ];
end

%------------------------------------------------------------------------------%
% Initialization

readcheckpoint = 0;
disp( 'SORD - Support-Operator Rupture Dynamics' )
one = 1;
if str2double( version( '-release' ) ) >= 14, one = single( 1 ); end
zero = 0 * one;
mem = whos( 'one' );
mem = round( mem.bytes / 1024 ^ 2 * 18 * prod( n ) );
fprintf( 1, 'Base memory usage: %d Mb\n', mem )

initialize = 1;
if plotstyle, viz, end
gridgen
matmodel
output
if nrmdim, fault, end
if srcgeom, momentsrc, end
initialize = 0;

u  = repmat( zero, [ n 3 ] );  umax = 0;
v  = repmat( zero, [ n 3 ] );  vmax = 0;
vv = repmat( zero, [ n 3 ] );
S  = repmat( zero, [ n 6 ] );  Smax = 0;
it = 0;
itstep = nt;
if plotstyle, newplot='initial'; viz, end
if readcheckpoint, load checkpoint, end

disp( ' step   fault    v        S        viz/io  total' )

step

% end %function

