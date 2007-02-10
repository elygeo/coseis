% PEER UHS.1

  np  = [ 1 1 2 ];
  vp  = 6000.;
  vs  = 3464.;
  rho = 2700.;
  gam = .1;
  hourglass = [ 1. 4. ];
  upvector = [ 0 0 -1 ];
  itcheck = 0;
  faultnormal = 0;
  fixhypo = 2;
  tfunc = 'brune';
  tsource = .1;
  moment1 = [ 0. 0. 0. ];
  moment2 = [ 0. 0. 1e18 ];
  bc1 = [ -2 -2  0 ];
  bc2 = [  1  1  1 ];
  dx  = 50.;
  dt  = .004;
  nt  = 1250;
  rsource = 25.;
  nn    = [  161  201 101 ];
  ihypo = [ -162 -202  41 ];
  timeseries = { 'v' 5999. 7999. -2001. };
  timeseries = { 'v' 6001. 8001. -2001. };

return

  vp  = { 4000. 'zone'   1 1 1   -1 -1 21 };
  vs  = { 2000. 'zone'   1 1 1   -1 -1 21 };
  rho = { 2600. 'zone'   1 1 1   -1 -1 21 };

  out = { 'x'  0   1 1 1 0  -1  1 -1  0 };
  out = { 'v' 40   1 1 1 0  -1  1 -1 -1 };
  out = { 'x'  0   1 1 0 0  -1 -1  0  0 };
  out = { 'v' 40   1 1 0 0  -1 -1  0 -1 };

