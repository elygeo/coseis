% 2D
  np  = [  1   1  1 ];

  rho = 1000.;
  vp  = 1732.;
  vs  = 1000.;
  gam = 0.0;
  hourglass = [ 1. 1. ];
  dx  = 100.;
  nt  = 200;
  dt  = 0.02;

  nn  = [ 101 101 2 ];
  fixhypo = -2;
  rsource = -1.;
  faultnormal = 0;
  tfunc = 'brune';
  tsource = 0.2;
  ihypo = [ 0 0 0 ];
  i1source = [  1 1  1 ];
  i2source = [  0 1 -1 ];
% i1source = [  1 1  1 ];
% i2source = [ -1 1 -1 ];
  moment1 = [ 0. 0. 1. ];
  moment2 = [ 0. 0. 0. ];
  bc1 = [ 0 0 -1 ];
  bc2 = [ 0 0 -1 ];

  datadir = 'canyon/wedge';
  x1  = { 'read' 'zone' 1 1 1   -1 -1 1 };
  x2  = { 'read' 'zone' 1 1 1   -1 -1 1 };
  out = { 'x'   1   1  1  1  0   -1 -1  1  0 };
  out = { 'u'   1   1  1  1  0   -1 -1  1 -1 };

