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
  dx  = 100;
  dt  = .008;
  nt  = 1500;
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
  bc1      = [   0   0   0 ];
  n1expand = [  50  50  50 ];

  itcheck = 0;
  np = [ 4 4 2 ];

% xz-shear reverse slip
  affine = [ 1. 0. 1.   0. 1. 0.   0. 0. 1. ];
  nn       = [ 421 136 202 ];
  ihypo    = [   0  -1   0 ];
  bc2      = [   0   3   0 ];
  n2expand = [  50   0  50 ];

  th  =  70e6;
  th  = {  81.6e6 'cube'  -1501. -1501. -1.   1501. 1501. 1. };

