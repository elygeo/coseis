% TPV3
  faultnormal = 3;
  vrup = -1.;
  out = { 'x'    1      1 1 1   -1 -1 -1 };
  out = { 'v'    100    1 1 1   -1 -1 -1 };
  out = { 'sv'   1      1 1 0   -1 -1  0 };
  out = { 'sl'   1      1 1 0   -1 -1  0 };
  out = { 'ts'   1      1 1 0   -1 -1  0 };
  out = { 'trup' 100    1 1 0   -1 -1  0 };
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
  nt  = 900;
  itcheck = -1;

% 0. no strain
  affine = [ 1. 0. 0.; 0. 1. 0.; 0. 0. 1. ] / 1.;
  nn    = [ 176 101 61 ];
  ihypo = [ -1 -1 -1 ];
  bc1   = [  1  0  1 ];
  bc2   = [ -3  3 -2 ];
  n1expand = [ 0 0 0 ];
  n2expand = [ 0 0 0 ];

% 1a. yz-shear
  affine = [ 1. 0. 0.; 0. 1. 1.; 0. 0. 1. ] / 1.;
  nn    = [ 176 201 122 ];
  ihypo = [ -1  0  0 ];
  bc1   = [  1  0  0 ];
  bc2   = [ -3  0  0 ];
  n1expand = [ 0 0 0 ];
  n2expand = [ 0 0 0 ];

% 2a. xz-shear
  affine = [ 1. 0. 1.; 0. 1. 0.; 0. 0. 1. ] / 1.;
  nn    = [ 351 101 122 ];
  ihypo = [  0 -1  0 ];
  bc1   = [  0  1  0 ];
  bc2   = [  0  3  0 ];
  n1expand = [ 0 0 0 ];
  n2expand = [ 0 0 0 ];

% 3a. xy-shear
  affine = [ 1. 1. 0.; 0. 1. 0.; 0. 0. 1. ] / 1.;
  nn    = [ 401 201 61 ];
  ihypo = [  0  0 -1 ];
  bc1   = [  0  0  1 ];
  bc2   = [  0  0 -3 ];
  n1expand = [ 0 0 0 ];
  n2expand = [ 0 0 0 ];

% 1b. symmetric yz-shear
  affine = [ 1. 0. 0.; 0. 1. 1.; 0. 0. 1. ] / 1.;
  nn    = [ 176 271 101 ];
  ihypo = [ -1  0 -1 ];
  bc1   = [  1  0  0 ];
  bc2   = [ -3  0 -3 ];
  n1expand = [ 0 50 50 ];
  n2expand = [ 0 50  0 ];

% 3b. symmetric xy-shear
  affine = [ 1. 1. 0.; 0. 1. 0.; 0. 0. 1. ] / 1.;
  nn    = [ 471 136 61 ];
  ihypo = [  0 -1 -1 ];
  bc1   = [  0  0  1 ];
  bc2   = [  0  3 -3 ];
  n1expand = [ 50 50 0 ];
  n2expand = [ 50  0 0 ];

% 2b. symmetric xz-shear
  affine = [ 1. 0. 1.; 0. 1. 0.; 0. 0. 1. ] / 1.;
  nn    = [ 421 101 101 ];
  ihypo = [  0 -1 -1 ];
  bc1   = [  0  1  0 ];
  bc2   = [  0  3 -3 ];
  n1expand = [ 50 0 50 ];
  n2expand = [ 50 0  0 ];

