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
  td  = 0.;
  th  = -70e6;
  th  = { -81.6e6 'cube'  -1501. -1501. -1.   1501. 1501. 1. };
  viscosity = [ .1 .7 ];
  origin = 0;
  fixhypo = 2;
  dx  = 50;
  dt  = .004;
  nt  = 3000;
  out = { 'x'     1   1 1 0   -1 -1  0 };
  out = { 'su'   -1   1 1 0   -1 -1  0 };
  out = { 'svp'  -1   1 1 0   -1 -1  0 };
  out = { 'trup' -1   1 1 0   -1 -1  0 };
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
  bc1      = [   0   0   0 ];
  n1expand = [  50  50  50 ];

  itcheck = 0;
  np = [ 4 4 2 ];

% 0. rectangular
  affine = [ 1. 0. 0.  0. 1. 0.  0. 0. 1. ] / 1.;
  nn       = [ 421 271 201 ];
  ihypo    = [  -1  -1  -1 ];
  bc2      = [  -2   2  -2 ];
  n2expand = [   0   0   0 ];

