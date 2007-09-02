% Canyon
  np  = [ 1 1 2 ];
  rho = 1.;
  vp  = 2.;
  vs  = 1.;
  gam = 0.0;
  hourglass = [ 1. 2. ];
  faultnormal = 0;
  tfunc = 'ricker1';
  moment1 = [  0. 1. 0. ];
  moment2 = [  0. 0. 0. ];
  bc1     = [  0  0  1  ];
  bc2     = [  1 -1  1  ];
  x1  = { 'read' 'zone' 1 1 1   -1 -1 1 };
  x2  = { 'read' 'zone' 1 1 1   -1 -1 1 };
  i1source = [ -1  0  1 ];
  i2source = [ -1 -1 -1 ];

  nn  = [ 301 321 2 ];
  nt  = 6000;
  dt  = 0.002;
  dx  = .0075;
  tsource = 2;
  datadir = 'canyon/data';

  out = { 'x'   1   1  1 1 0   -1 -1 1  0 };
  out = { 'u' 500   1  1 1 0   -1 -1 1 -1 }; % snaps
  out = { 'u'   1   1  1 1 0    1 -1 1 -1 }; % canyon
  out = { 'u'   1   2  1 1 0  158  1 1 -1 }; % flank
  out = { 'u'   1  -1 -1 1 0   -1 -1 1 -1 }; % source

