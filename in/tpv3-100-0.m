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
  dx  = 100;
  dt  = .008;
  nt  = 2;
  out = { 'nhat'  1    1  1 0    1  1  0 };
  out = { 'nhat'  1   -1 -1 0   -1 -1  0 };
  out = { 't0'    1    1  1 0    1  1  0 };
  out = { 't0'    1   -1 -1 0   -1 -1  0 };
  out = { 'mus'   1    1  1 0    1  1  0 };
  out = { 'mus'   1   -1 -1 0   -1 -1  0 };
  out = { 'mud'   1    1  1 0    1  1  0 };
  out = { 'mud'   1   -1 -1 0   -1 -1  0 };
  out = { 'dc'    1    1  1 0    1  1  0 };
  out = { 'dc'    1   -1 -1 0   -1 -1  0 };
  out = { 'co'    1    1  1 0    1  1  0 };
  out = { 'co'    1   -1 -1 0   -1 -1  0 };
  out = { 'f'     1    1  1 0    1  1  0 };
  out = { 'f'     1   -1 -1 0   -1 -1  0 };
  out = { 'tnm'   1    1  1 0    1  1  0 };
  out = { 'tnm'   1   -1 -1 0   -1 -1  0 };
  out = { 'tsm'   1    1  1 0    1  1  0 };
  out = { 'tsm'   1   -1 -1 0   -1 -1  0 };
  out = { 'sa'    1    1  1 0    1  1  0 };
  out = { 'sa'    1   -1 -1 0   -1 -1  0 };

  out = { 'x'     1   1 1 1   -1 -1  0 };
  out = { 'su'   -1   1 1 0   -1 -1  0 };
  out = { 'svp'  -1   1 1 0   -1 -1  0 };
  out = { 'trup' -1   1 1 0   -1 -1  0 };
  timeseries = { 'su' -7500.     0. 0. };
  timeseries = { 'sv' -7500.     0. 0. };
  timeseries = { 'ts' -7500.     0. 0. };
  timeseries = { 'su'     0. -6000. 0. };
  timeseries = { 'sv'     0. -6000. 0. };
  timeseries = { 'ts'     0. -6000. 0. };
  timeseries = { 'su' -7500. -6000. 0. };
  timeseries = { 'sv' -7500. -6000. 0. };
  timeseries = { 'ts' -7500. -6000. 0. };
  bc1      = [   0   0   0 ];
  n1expand = [  50  50  50 ];

  itcheck = 0;
  np = [ 1 1 1 ];
  np = [ 4 2 2 ];
  np = [ 4 4 4 ];

% 0. rectangular
  affine = [ 1. 0. 0.  0. 1. 0.  0. 0. 1. ] / 1.;
  nn       = [ 211 136 101 ];
  ihypo    = [  -1  -1  -1 ];
  bc2      = [  -3   3  -2 ];
  n2expand = [   0   0   0 ];

