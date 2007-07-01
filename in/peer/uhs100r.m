% PEER UHS.1

  dx  = 100;
  dt  = .008;
  nt  = 625;
  vp  = 6000.;
  vs  = 3464.;
  rho = 2700.;
  gam = .1;
  hourglass = [ 1. 1. ];
  bc1 = [ -2 -2  0 ];
  bc2 = [ 10 10 10 ];

  nn    = [ 91 111 61 ];
  ihypo = [  1   1 21 ];
  xhypo = [ 0. 0. 2000. ];
  fixhypo = -2;
  rsource = 50.;
  tsource = .1;
  tfunc = 'brune';
  moment1 = [ 0. 0. 0. ];
  moment2 = [ 0. 0. 1e18 ];
  faultnormal = 0;

  np = [ 1 2 4 ];

  timeseries = { 'v' 5999.  7999. -1. };
  timeseries = { 'v' 6001.  8001. -1. };

% out = { 'x'  0   1 1 1 0  -1  1 -1  0 };
% out = { 'v' 40   1 1 1 0  -1  1 -1 -1 };
% out = { 'x'  0   1 1 0 0  -1 -1  0  0 };
% out = { 'v' 40   1 1 0 0  -1 -1  0 -1 };

