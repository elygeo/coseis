% PML damping test

  faultnormal = 0;
  rsource = 150.;

  nt = 1;
  nn = [ 3 3 3 ];
  ihypo = [ 0 0 0 ];
  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];

  nt = 200;
  nn = [ 41 41 41 ];
  ihypo = [ 21 21 21 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 1 ];

  out = { 'x' 1   1 1 0    -1 -1 0 };
  out = { 'v' 1   1 1 0    -1 -1 0 };
  out = { 'x' 1   1 0 1    -1 0 -1 };
  out = { 'v' 1   1 0 1    -1 0 -1 };
  out = { 'x' 1   0 1 1    0 -1 -1 };
  out = { 'v' 1   0 1 1    0 -1 -1 };

