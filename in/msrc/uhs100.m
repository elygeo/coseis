% PEER UHS.1, UHS.2, LOH.1, 

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
  bc1      = [  -2  -2   0 ];
  bc2      = [   1   1   1 ];
  n1expand = [   0   0   0 ];
  n2expand = [   0   0   0 ];
  rexpand = 1.06;
  npml = 10;
  dx  = 100;
  dt  = .008;
  nt  = 700;
  rsource = 50.;
  nn       = [  91  111 61 ];
  ihypo    = [ -92 -112 21 ];
  timeseries = { 'v' 5950. 7950. -2050. };
  timeseries = { 'v' 6050. 8050. -2050. };

% vp  = { 4000. 'zone'   1 1 1   -1 -1 11 };
% vs  = { 2000. 'zone'   1 1 1   -1 -1 11 };
% rho = { 2600. 'zone'   1 1 1   -1 -1 11 };

out = { 'x'  0   1 1 1  0   1 -1 -1  0 };
out = { 'v' 20   1 1 1  0   1 -1 -1 -1 };
out = { 'x'  0   1 1 1  0  -1  1 -1  0 };
out = { 'v' 20   1 1 1  0  -1  1 -1 -1 };
out = { 'x'  0   1 1 1  0  -1 -1  1  0 };
out = { 'v' 20   1 1 1  0  -1 -1  1 -1 };
out = { 'x'  0   1 1 0  0  -1 -1  0  0 };
out = { 'v' 20   1 1 0  0  -1 -1  0 -1 };

