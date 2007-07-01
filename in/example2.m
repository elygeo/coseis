% TPV6
  nn = [ 421 211 202 ];
  dx = 100;
  dt = .008;
  nt = 1500;

% Mesh
  affine = [ 2. 0. 0.  0. 1. 0.  0. 0. 1.  1. ]; % xx
  affine = [ 1. 1. 0.  0. 1. 0.  0. 0. 1.  1. ]; % xy
  affine = [ 1. 0. 0.  0. 1. 0.  0. 0. 1.  1. ]; % rectangular

% Material model
  vp  = 6000.;
  vs  = 3464.;
  rho = 2670.;
  vp  = { 3750. 'zone' 1 1 0   -1 -1 -1 };
  vs  = { 2165. 'zone' 1 1 0   -1 -1 -1 };
  rho = { 2225. 'zone' 1 1 0   -1 -1 -1 };
  gam = .1
  hourglass = [ 1. .7 ];

% Fault model
  faultnormal = 3;
  ihypo = [ 0  76    0  ];
  xhypo = [ 0. 7500. 0. ];
  fixhypo = -1;
  dc  = 0.4;
  mud = .525;
  mus = 10000.;
  mus = { .677   'cube' -15001.   -1. -1.  15001. 15001. 1. };
  slipvector = [ 1. 0. 0. ];
  tn  = -120e6;
  ts1 = 70e6;
  ts1 = { 81.6e6 'cube'  -1501. 5999. -1.   1501.  9001. 1. };
  vrup = -1.;

% Boundary conditions
  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];
  n1expand = [ 50  0 50 ];
  n2expand = [ 50 50 50 ];

% Code execution and output
  np = [ 4 2 2 ];
  out = { 'x'    1   1 1 0  0   -1 -1  0  0 };
  out = { 'trup' 1   1 1 0 -1   -1 -1  0 -1 };
  out = { 'u'  1    91 1 101 0    91 1 101 1500 };
  out = { 'v'  1    91 1 101 0    91 1 101 1500 };
  out = { 'ts' 1    91 1 101 0    91 1 101 1500 };
  out = { 'tn' 1    91 1 101 0    91 1 101 1500 };

