% PEER LOH.1

  np = [ 1 32 1 ];
  nn = [ 402 502 301 ];
  nt = 5625;
  dx = 20.;
  dt = 0.0016;

  bc1 = [ -2 -2  0 ];
  bc2 = [ 10 10 10 ];




  rho = 2700.; rho = { 2600. 'zone'   1 1 1   -1 -1 51 };
  vp  = 6000.; vp  = { 4000. 'zone'   1 1 1   -1 -1 51 };
  vs  = 3464.; vs  = { 2000. 'zone'   1 1 1   -1 -1 51 };
  gam = 0.;
  hourglass = [ 1. 2. ];

  faultnormal = 0;
  ihypo = [ 1 1 101 ];
  xhypo = [ 0. 0. 2000. ];
  fixhypo = -2;
  tfunc = 'brune';
  tsource = 0.1;
  moment1 = [ 0. 0. 0. ];
  moment2 = [ 0. 0. 1e18 ];

  timeseries = { 'v'  5999.  7999. -1. };
  timeseries = { 'v'  6001.  8001. -1. };

