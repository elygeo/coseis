% Test

% affine = [ 1 0 0   1 1 0   0 0 1   1 ];

  debug = 1;
  itswap = 2;
  np = [ 1 3 1 ];
  nn = [ 6 6 6 ];

  nt = 5;
  dx = 100;
  dt = .0075;
  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];

  faultnormal = 0;
  moment1 = [ 1e16 1e16 1e16 ];
  moment2 = [ 0. 0. 0. ];
  ihypo = [ 2 2 2 ];
  fixhypo = 2;
  rsource = 50.;
  out = { 'vm2' 1  1 1 1 0  -1 -1 -1 -1 };
  out = { 'am2' 1  1 1 1 0  -1 -1 -1 -1 };

