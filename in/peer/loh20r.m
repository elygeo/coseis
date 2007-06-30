% PEER LOH.1

  dx  = 20.;
  dt  = .0016;
  nt  = 5625;
  vp  = 6000.;
  vs  = 3464.;
  rho = 2700.;
  gam = .0;
  vp  = { 4000. 'zone'   1 1 1   -1 -1 51 };
  vs  = { 2000. 'zone'   1 1 1   -1 -1 51 };
  rho = { 2600. 'zone'   1 1 1   -1 -1 51 };
  hourglass = [ 1. 1. ];
  bc1 = [ -2 -2  1 ]; n1expand = [ 0 0 0 ];
  bc2 = [  1  1  1 ]; n2expand = [ 50 50 50 ];
  bc2 = [ 11 11 11 ]; n2expand = [ 0 0 0 ];

  nn    = [ 402 502 301 ];
  ihypo = [   1   1 101 ];
  xhypo = [ 0. 0. 2000. ];
  fixhypo = -2;
  rsource = 12.5;
  tsource = .1;
  tfunc = 'brune';
  moment1 = [ 0. 0. 0. ];
  moment2 = [ 0. 0. 1e18 ];
  faultnormal = 0;

  itcheck = 0;
  np = [ 2 4 4 ];

  timeseries = { 'v' 5999.  7999. -1. };
  timeseries = { 'v' 6001.  8001. -1. };

% out = { 'x'  0   1 1 1 0    1 -1 -1  0 };
% out = { 'v' 40   1 1 1 0    1 -1 -1 -1 };
% out = { 'x'  0   1 1 1 0   -1  1 -1  0 };
% out = { 'v' 40   1 1 1 0   -1  1 -1 -1 };
% out = { 'x'  0   1 1 0 0   -1 -1  0  0 };
% out = { 'v' 40   1 1 0 0   -1 -1  0 -1 };
% out = { 'x'  0   1 1 1 0   -1 -1  1  0 };
% out = { 'v' 40   1 1 1 0   -1 -1  1 -1 };

