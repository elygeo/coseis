% TPV3
  faultnormal = 3;
  vrup = -1.;
  vp  = 6000.;
  vs  = 3464.;
  rho = 2670.;
  dc  = 0.4;
  mud = .525;
  mus = 10000.;
  mus = { .677    'cube' -15001. -7501. -1.  15001. 7501. 1. };
  tn  = -120e6;
  ts1 = -70e6;
  ts1 = { -81.6e6 'cube'  -1501. -1501. -1.   1501. 1501. 1. };
  gam = .1;
  hourglass = [ 1. .7 ];
  fixhypo = -1;
  dx  = 50;
  dt  = .004;
  nt  = 3000;
  out = { 'x'    1   1 1 0  0   -1 -1  0  0 };
  out = { 'su'   1   1 1 0 -1   -1 -1  0 -1 };
  out = { 'psv'  1   1 1 0 -1   -1 -1  0 -1 };
  out = { 'trup' 1   1 1 0 -1   -1 -1  0 -1 };
  timeseries = { 'su' -7501.     0. 0. };
  timeseries = { 'sv' -7501.     0. 0. };
  timeseries = { 'ts' -7501.     0. 0. };
  timeseries = { 'su'  7501.     0. 0. };
  timeseries = { 'sv'  7501.     0. 0. };
  timeseries = { 'ts'  7501.     0. 0. };
  timeseries = { 'su'     0. -6001. 0. };
  timeseries = { 'sv'     0. -6001. 0. };
  timeseries = { 'ts'     0. -6001. 0. };
  timeseries = { 'su'     0.  6001. 0. };
  timeseries = { 'sv'     0.  6001. 0. };
  timeseries = { 'ts'     0.  6001. 0. };
  bc1      = [   1   1   1 ];
  n1expand = [  50  50  60 ];

  itcheck = 0;
  np = [ 4 4 2 ];

  affine = [ 2. 0. 0.   0. 2. 0.   0. 0. 1. ];
  nn       = [ 211 136 182 ];
  ihypo    = [  -1  -1  -2 ];
  bc2      = [  -3   3  -2 ];
  n2expand = [   0   0   0 ];

