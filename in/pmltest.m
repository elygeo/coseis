% PML damping test

  nn = [ 81 81 81 ];
  nn = [ 81 41 41 ];
  nn = [ 41 41 41 ];
dt = .007;
  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 1 ];
  ihypo = [ 21 21 21 ];
  ihypo = [ 0 0 0 ];
  nt = 100;
  faultnormal = 0;
  rsource = 150.;
  out = { 'x' 1   1 1 0    -1 -1 0 };
  out = { 'v' 1   1 1 0    -1 -1 0 };
  out = { 'x' 1   1 1 31   -1 -1 31 };
  out = { 'v' 1   1 1 31   -1 -1 31 };

