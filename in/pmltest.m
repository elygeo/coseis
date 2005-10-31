% PML damping test

  nn = [ 41 41 41 ];
  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 1 ];
  ihypo = [ 21 21 21 ];
  nt = 200;
  faultnormal = 0;
  rsource = 150.;
  out = { 'x' 1   1 1 0    -1 -1 0 };
  out = { 'v' 1   1 1 0    -1 -1 0 };
  out = { 'x' 1   1 0 1    -1 0 -1 };
  out = { 'v' 1   1 0 1    -1 0 -1 };
  out = { 'x' 1   0 1 1    0 -1 -1 };
  out = { 'v' 1   0 1 1    0 -1 -1 };

