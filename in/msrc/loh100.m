% PEER LOH.1

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
  origin = 0;
  tfunc = 'brune';
  tsource = .1;
  moment1 = [ 0. 0. 0. ];
  moment2 = [ 0. 0. 1e18 ];
  bc1 = [ -2 -2  0 ];
  bc2 = [  1  1  1 ];
  dx  = 100;
  dt  = .008;
  nt  = 1125;
  rsource = 50.;
  nn    = [  91  111 61 ];
  ihypo = [ -92 -112 21 ];
  timeseries = { 'v' 5999. 7999. -2001. };
  timeseries = { 'v' 6001. 8001. -2001. };

  vp  = { 4000. 'zone'   1 1 1   -1 -1 11 };
  vs  = { 2000. 'zone'   1 1 1   -1 -1 11 };
  rho = { 2600. 'zone'   1 1 1   -1 -1 11 };

  out = { 'x'   0   1 1 1 0  -1  1 -1  0 };
  out = { 'v'  40   1 1 1 0  -1  1 -1 -1 };
  out = { 'x'   0   1 1 0 0  -1 -1  0  0 };
  out = { 'v'  40   1 1 0 0  -1 -1  0 -1 };

  out = { 'rho' 0   1 1 1 0  -1  2 -1  0 };
  out = { 'vs'  0   1 1 1 0  -1  2 -1  0 };
  out = { 'vp'  0   1 1 1 0  -1  2 -1  0 };

return

