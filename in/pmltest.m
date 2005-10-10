% PML damping test

  model = 'explosion';
  nn = [ 81 81 81 ];
  nn = [ 41 41 41 ];
  ihypo = [ 21 21 21 ];
  bc = [ 1 1 1   1 1 1 ];
  bc = [ 1 1 1   0 0 0 ];
  nt = 200;
  faultnormal = 0;
  rsource = 150.;
  out = { 'x' 1   1 1 0    41 41 0  };
  out = { 'v' 1   1 1 0    41 41 0  };
  out = { 'x' 1   1 1 31   41 41 31 };
  out = { 'v' 1   1 1 31   41 41 31 };

