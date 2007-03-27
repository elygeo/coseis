% Explosion test problem
  np = [ 1 2 1 ];
  nn = [ 71 71 61 ];
  dx = 100.;
  dt = .008;
  nt = 200;
  vp  = 6000.;
  vs  = 3464.;
  rho = 2700.;
  gam = .2;
  hourglass = [ 1. 7. ];
  n1expand = [  0  0  0 ];
  n2expand = [ 20 20 20 ];
  faultnormal = 0;
  moment1 = [ 1e18 1e18 1e18 ];
  moment2 = [ 0 0 0 ];
  tfunc = 'brune';
  tsource = .1;
  bc2 = [ 0 0 0 ];
  xhypo = [ 0. 0. 0. ];

  bc1 = [ 3 3 3 ];
  fixhypo = -1;
  rsource = 100.;
  ihypo = [ 1 1 1 ];
  timeseries = { 'v'    0. 4000. 0. };
  timeseries = { 'x'    0. 4000. 0. };
  timeseries = { 'v' 3000. 4000. 0. };
  timeseries = { 'x' 3000. 4000. 0. };
  timeseries = { 'v' 4000. 4000. 0. };
  timeseries = { 'x' 4000. 4000. 0. };
  return

  bc1 = [ 2 2 2 ];
  fixhypo = -2;
  rsource = 50.;
  ihypo = [ -72 -72 -62 ];
  timeseries = { 'v'    0. 3950. 0. };
  timeseries = { 'x'    0. 3950. 0. };
  timeseries = { 'v' 2950. 3950. 0. };
  timeseries = { 'x' 2950. 3950. 0. };
  timeseries = { 'v' 3950. 3950. 0. };
  timeseries = { 'x' 3950. 3950. 0. };
  return

