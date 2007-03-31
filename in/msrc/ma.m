% PEER LOH Shuo Ma

  dx  = 50.;
  dt  = .004;
  nt  = 7500;
  vp  = 6000.;
  vs  = 3464.;
  rho = 2700.;
  gam = .0;
  vp  = { 2800. 'zone'   1 1 1   -1 -1 21 };
  vs  = { 1500. 'zone'   1 1 1   -1 -1 21 };
  rho = { 2600. 'zone'   1 1 1   -1 -1 21 };
  hourglass = [ 1. 4. ];
  bc1 = [ -2 -2  0 ];
  bc2 = [  1  1  1 ];

  nn    = [  161  201 101 ];
  ihypo = [ -162 -202  41 ];
  xhypo = [ 0. 0. 2000. ];
  fixhypo = -2;
  rsource = 25.;
  tsource = .1;
  tfunc = 'brune';
  moment1 = [ 0. 0. 0. ];
  moment2 = [ 0. 0. 1e18 ];
  faultnormal = 0;

  itcheck = 0;
  np = [ 1 1 2 ];

  timeseries = { 'v' 5999.  7999. -1. };
  timeseries = { 'v' 6001.  8001. -1. };

% out = { 'x'  0   1 1 1 0  -1  1 -1  0 };
% out = { 'v' 40   1 1 1 0  -1  1 -1 -1 };
% out = { 'x'  0   1 1 0 0  -1 -1  0  0 };
% out = { 'v' 40   1 1 0 0  -1 -1  0 -1 };

