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
  viscosity = [ .1 .7 ];
  viscosity = [ 0 .5 ];
  viscosity = [ 0 1. ];
  bc1 = [  1  1  1 ];
  bc2 = [ -3  3 -2 ];
  ihypo = [ -1 -1 -1 ];
  np = [ 3 2 2 ];
  np = [ 1 1 1 ];
% th = -.5818
% td = -.5818 

% 100 shear
  ihypo = [ 0 -1 0 ];
  bc1 = [ 0 0 1 ];
  dx  = 100;
  dt  = .008;
  nt  = 100;
  mus = .677;
  th  = { -81.6e6 'zone' 21 21 0   51 51 0 };

  gridtrans = [   1. 1. 0.; 0.  1. 0.; 0. 0.  1. ] /  1.; % shear 3

  nn  = [ 36 36 21 ];
  bc2 = [ -3 3 -2 ];
  gridtrans = [   1. 0. 0.; 0.  1. 0.; 0. 0.  1. ] /  1.; % no strain

  nn  = [ 71 36 41 ];
  bc2 = [ 0 3 1 ];
  gridtrans = [   1. 0. 1.; 0.  1. 0.; 0. 0.  1. ] /  1.; % shear 1

  nn  = [ 36 71 41 ];
  bc2 = [ -3 0 1 ];
  gridtrans = [   1. 0. 0.; 0.  1. 1.; 0. 0.  1. ] /  1.; % shear 2
return

% 100 meter
  dx  = 100;
  dt  = .008;
  nt  = 1626;
  nt  = 900;
  mus = { .677    'zone' -151 -76 0   -1 -1 0 };
  th  = { -81.6e6 'zone'  -16 -16 0   -1 -1 0 };
  nn  = [ 176 101 61 ];
return

% 50 meter
  dx  = 50;
  dt  = .005;
  nt  = 2600;
  dt  = .004;
  nt  = 3250;
  nt  = 1800;
  mus = { .677    'zone' -301 -151 0   -1 -1 0 };
  th  = { -81.6e6 'zone'  -31  -31 0   -1 -1 0 };
  nn  = [ 701 401 101 ];
return

