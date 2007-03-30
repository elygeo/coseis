% Test

  oplevel = 5;
  oplevel = 6;
% affine = [ 1 0 0   1 1 0   0 0 1   1 ];

  nn = [ 2 2 2 ];
  nt = 2;
  dx = 100;
  dt = .0075;
  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];

  faultnormal = 0;
  moment1 = [ 1e16 1e16 1e16 ];
  moment2 = [ 0. 0. 0. ];
  ihypo = [ 0 0 0 ];
  fixhypo = 2;
  rsource = 50.;

  itstats = 1;
  debug = 1;

