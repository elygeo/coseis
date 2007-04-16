% PEER LOH.1

  affine = [ 1. 0. 1.   1. 1. 0.   0. 0. 1.   1. ];
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
  hourglass = [ 1. 4. ];
  bc1 = [  0  0  0 ];
  bc2 = [  0  0  1 ];
  n1expand = [ 60 60 0 ];
  n2expand = [ 60 60 0 ];

  nn    = [ 520 720 161 ];
  ihypo = [ 241 389  40 ];
  ihypo = [ 240 390  41 ];
  xhypo = [ 0. 0. 2000. ];
  fixhypo = -2;
  rsource = 25.;
  tsource = .1;
  tfunc = 'brune';
  moment1 = [ 0. 0. 0. ];
  moment2 = [ 0. 0. 1e18 ];
  faultnormal = 0;

  itcheck = 0;
  np = [ 4 4 2 ];

  timeseries = { 'v'  6000.  8000. -1. };
  timeseries = { 'v'  6000. -8000. -1. };
  timeseries = { 'v' -6000.  8000. -1. };
  timeseries = { 'v' -6000. -8000. -1. };
  timeseries = { 'v'  8000.  6000. -1. };
  timeseries = { 'v'  8000. -6000. -1. };
  timeseries = { 'v' -8000.  6000. -1. };
  timeseries = { 'v' -8000. -6000. -1. };

% out = { 'x'  0   1 0 1 0  -1  0 -1  0 };
% out = { 'v' 40   1 0 1 0  -1  0 -1 -1 };
% out = { 'x'  0   1 1 0 0  -1 -1  0  0 };
% out = { 'v' 40   1 1 0 0  -1 -1  0 -1 };

