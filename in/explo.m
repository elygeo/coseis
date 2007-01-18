% Explosion test problem
  debug = 1;
  np = [ 1 2 1 ];
  nn = [ 101 101 41 ];
  dx = 100.;
  dt = .008;
  nt = 4;
  vp  = 6000.;
  vs  = 3464.;
  rho = 2700.;
  gam = .0;
  hourglass = [ 1. .0 ];
  rexpand = 1.06;
  n1expand = [ 10 10 0 ];
  n2expand = [ 10 10 10 ];
  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];
  faultnormal = 0;
  ihypo = [ 21 21 21 ];
  origin = 0;
  fixhypo = 2; % 0=none, 1=node, 2=cell
  moment1 = [ 1e18 1e18 1e18 ];
  moment2 = [ 0 0 0 ];
  tfunc = 'brune';
  rsource = 10.;
  timeseries = { 'v'  4000.     0.     0. };
  timeseries = { 'x'  4000.     0.     0. };
  timeseries = { 'v'  4000.  3000.     0. };
  timeseries = { 'x'  4000.  3000.     0. };
  timeseries = { 'v'  4000.  4000.     0. };
  timeseries = { 'x'  4000.  4000.     0. };
  out = { 'x' 1   1 1 0 1   -1 -1 0 -1 };
  out = { 'v' 1   1 1 0 1   -1 -1 0 -1 };

