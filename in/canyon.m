% Canyon
  datadir = 'canyon/data';
  x1  = { 'read' 'zone' 1 1 1   -1 -1 1 };
  x2  = { 'read' 'zone' 1 1 1   -1 -1 1 };
  np  = [   1   1   1 ];
  nn  = [ 181 321   2 ];
  rho = 1000.;
  vp  = 1732.;
  vs  = 1000.;
  gam = 0.0;
  hourglass = [ 1. 2. ];
  faultnormal = 0;
  dx  = 15.;
  nt  = 3200;
  dt  = .005;
  tsource = 4.6188022;
  tsource = 2.3094011;
  moment2 = [ 0. 0. 0. ];

  moment1 = [ 0. 1. 0. ];
  bc1      = [    0   0   1 ];
  bc2      = [    1   0   1 ];

  moment1 = [ 0. 0. 1. ];
  bc1      = [    0   0   -1 ];
  bc2      = [    0   0   -1 ];

  i1source = [ -1  81  1 ];
  i2source = [ -1 241 -1 ];

  out = { 'x'   1   1  1  1  0   -1 -1  1  0 };
  out = { 'u'   1   1  1  1  0   -1 -1  1 -1 };
  out = { 'u'   1   1  1  1  0    1 -1  1 -1 };
  out = { 'u'   1   1  1  1  0   -1  1  1 -1 };
  out = { 'u'   1   1 -1  1  0   -1 -1  1 -1 };
  out = { 'u'   1  -1 81  1  0   -1 241 1 -1 };

