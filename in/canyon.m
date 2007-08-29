% Canyon
  datadir = 'canyon/data';
  x1  = { 'read' 'zone' 1 1 1   -1 -1 1 };
  x2  = { 'read' 'zone' 1 1 1   -1 -1 1 };
  np  = [   1   1   1 ];
  nn  = [ 181 321   2 ];
  dx  = .015;
  dt  = 0.004;
  rho = 1.;
  vp  = 2.;
  vs  = 1.;
  gam = 0.0;
  hourglass = [ 1. 2. ];
  faultnormal = 0;
  i1source = [ -1  81  1 ];
  i2source = [ -1 241 -1 ];
  tsource = .25;
  tfunc = 'ricker1';
  moment2 = [ 0. 0. 0. ];

% SH
  nt  = 7000;
  moment1 = [  0. 0. 1. ];
  bc1     = [  0  0 -1  ];
  bc2     = [  0  0 -1  ];

% SV
  nt  = 7000;
  moment1 = [  1. 0. 0. ];
  bc1     = [  0  0  1  ];
  bc2     = [ -1  0  1  ];

% P
  nt  = 3500;
  moment1 = [  0. 1. 0. ];
  bc1     = [  0  0  1  ];
  bc2     = [  1  0  1  ];
nt = 0;

  out = { 'x'   1   1   1 1 0   -1  -1 1  0 };
  out = { 'u' 500   1   1 1 0   -1  -1 1 -1 }; % snaps
  out = { 'u'   1   1 161 1 0    1  -1 1 -1 }; % canyon
  out = { 'u'   1   2  -1 1 0   41  -1 1 -1 }; % flank
  out = { 'u'   1   1 161 1 0   -1 161 1 -1 }; % depth profile

