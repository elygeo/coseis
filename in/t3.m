% TPV3
  datadir = 'tpv3';
  debug = 1;
  faultnormal = 3;
  vrup = -1.;
  out = { 'x'    1      1 1 1   -1 -1 -1 };
  out = { 'v'    10     1 1 1   -1 -1 -1 };
  out = { 'sv'   1      1 1 1   -1 -1 -1 };
  out = { 'sl'   1      1 1 1   -1 -1 -1 };
  out = { 'trup' 100    1 1 1   -1 -1 -1 };
  vp  = 6000.;
  vs  = 3464.;
  rho = 2670.;
  dc  = 0.4;
  mud = .525;
  tn  = -120e6;
  td  = 0.;
  mus = 10000;
  th  = -70e6;
  viscosity = [ 0 .5 ];
  viscosity = [ .1 .7 ];
  bc1 = [  0  0  0 ];
  bc2 = [ -3  3 -2 ];
  ihypo = [ -1 -1 -1 ];
  np = [ 1 1 1 ];
  np = [ 3 2 2 ];

% 100 meter
  dx  = 100;
  dt  = .008;
  nt  = 1626;
  nt  = 900;
  mus = [ .677       26 26 0   -1 -1 0 ];
  th  = [ -81.6e6   161 86 0   -1 -1 0 ];
  nn  = [ 176 101 41 ];
return

% 50 meter
  dx  = 50;
  dt  = .005;
  nt  = 2600;
  dt  = .004;
  nt  = 3250;
  nt  = 1800;
  mus = [ .677       51  51 0   -1 -1 0 ];
  th  = [ -81.6e6   321 171 0   -1 -1 0 ];
  nn  = [ 701 401 101 ];
return

