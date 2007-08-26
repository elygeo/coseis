% Canyon
  np       = [    1   1   2 ];
  nn       = [  227  641  2 ];
  bc1      = [    0   0   4 ];
  bc2      = [    4   0   4 ];
  ihypo    = [   -2   0   0 ];
  fixhypo  =  1;
  wavenormal = 2;
  moment1 = [ 0. 1. 0. ];
  moment2 = [ 0. 0. 0. ];
  tsource = 4.6188022;
  tsource = 2.3094011;

  nt  = 3200;
nt = 0;
  dt  = .005;
  dx  = 100.;
  rho = 1000.;
  vp  = 1732.;
  vs  = 1000.;
  gam = 0.;
  hourglass = [ 1. 2. ];

  datadir = 'canyon/data';
  x1  = { 'read' 'zone' 1 1 1   -1 -1 1 };
  x2  = { 'read' 'zone' 1 1 1   -1 -1 1 };

  out = { 'x' 1   1  1  1  0   -1 -1  1  0 };
  out = { 'u' 1   1  1  1  0    1 -1  1 -1 };
  out = { 'u' 1   1  1  1  0   -1  1  1 -1 };
  out = { 'u' 1   1 -1  1  0   -1 -1  1 -1 };

