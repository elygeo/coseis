% PEER LOH.1

  dx  = 50.;
  dt  = .004;
  nt  = 2250;
  vp  = 6000.;
  vs  = 3464.;
  rho = 2700.;
  gam = .0;
  vp  = { 4000. 'zone'   1 1 1   -1 -1 21 };
  vs  = { 2000. 'zone'   1 1 1   -1 -1 21 };
  rho = { 2600. 'zone'   1 1 1   -1 -1 21 };
  hourglass = [ 1. 1. ];
  bc1 = [  1  1  1 ]; n1expand = [ 60 60 0 ];
  bc2 = [  1  1  1 ]; n2expand = [ 60 60 60 ];
  bc2 = [  1  1 11 ]; n2expand = [ 60 60 0 ];

  nn    = [ 601 751 161 ];
  ihypo = [ 320 421  41 ];
  xhypo = [ 0. 0. 2000. ];
  fixhypo = -2;
  rsource = 25.;
  tsource = .1;
  tfunc = 'brune';
  moment1 = [ 0. 0. 0. ];
  moment2 = [ 0. 0. 1e18 ];
  faultnormal = 0;
  affine = [ 1. 0. 1.   1. 1. 0.   0. 0. 1.   1. ];

  itcheck = 0;
  np = [ 1 8 4 ];

  timeseries = { 'v'  5999.  7999. -1. };
  timeseries = { 'v'  5999. -7999. -1. };
  timeseries = { 'v' -5999. -7999. -1. };
  timeseries = { 'v' -5999.  7999. -1. };

% out = { 'x'  0   0 1 1 0    0 -1 -1  0 };
% out = { 'v' 20   0 1 1 0    0 -1 -1 -1 };
% out = { 'x'  0   1 0 1 0   -1  0 -1  0 };
% out = { 'v' 20   1 0 1 0   -1  0 -1 -1 };
% out = { 'x'  0   1 1 0 0   -1 -1  0  0 };
% out = { 'v' 20   1 1 0 0   -1 -1  0 -1 };
% out = { 'x'  0   1 1 1 0   -1 -1  1  0 };
% out = { 'v' 20   1 1 1 0   -1 -1  1 -1 };

