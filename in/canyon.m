% Canyon
  datadir = 'canyon/data';
  x1  = { 'read' 'zone' 1 1 1   -1 -1 1 };
  x2  = { 'read' 'zone' 1 1 1   -1 -1 1 };
  np  = [   1   1   1 ];
  nn  = [ 181 321   2 ];
  dx  = 15.;
  dt  = 0.004;
  rho = 1000.;
  vp  = 1732.; % Possion's ratio = 1/4
  vp  = 2000.; % Possion's ratio = 1/3
  vs  = 1000.;
  gam = 0.0;
  hourglass = [ 1. 2. ];
  faultnormal = 0;
  i1source = [ -1  81  1 ];
  i2source = [ -1 241 -1 ];
  tsource = 4.6188022;
  tsource = 2.3094011;
  moment2 = [ 0. 0. 0. ];

  nt  = 7000;
  moment1 = [  0. 0. 1. ];
  bc1     = [  0  0 -1  ];
  bc2     = [  0  0 -1  ];

  nt  = 3500;
  moment1 = [  0. 1. 0. ];
  bc1     = [  0  0  1  ];
  bc2     = [  1  0  1  ];

  out = { 'x'   1   1   1 1 0   -1  -1 1  0 };
  out = { 'u' 100   1   1 1 0   -1  -1 1 -1 }; % snaps
  out = { 'u'   1   1   1 1 0    1  -1 1 -1 }; % canyon
  out = { 'u'   1   1   1 1 0   -1   1 1 -1 }; % surface right
  out = { 'u'   1   1  -1 1 0   -1  -1 1 -1 }; % surface left
  out = { 'u'   1   1 161 1 0   -1 161 1 -1 }; % depth profile

