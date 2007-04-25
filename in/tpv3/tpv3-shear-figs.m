% TPV3
  debug = 1;
  faultnormal = 3;
  vrup = -1.;
  fixhypo = -1;
  ihypo = [ 0 0 0 ];
  out = { 'x'   1   1 1 1 0   -1 -1 -1  0 };
  out = { 'svm' 1   1 1 1 1   -1 -1 -1 -1 };
  out = { 'sl'  1   1 1 1 1   -1 -1 -1 -1 };
  out = { 'dc'  1   1 1 1 1   -1 -1 -1 -1 };
  dc = 0.;
  dc = { 1. 'cube' -15001. -7501. -1.  15001. 7501. 1. };
  dc = { 2. 'cube'  -1501. -1501. -1.   1501. 1501. 1. };
  dx  = 1500;
  nt  = 2;
  nn = [ 33 13 14 ];

% yz-shear
  affine = [ 1. 0. 0.  0. 1. 1.  0. 0. 1.  1. ];
  symmetry = [ 1 0 1 ];
  symmetry = [ 1 0 0 ];

% rectangular
  affine = [ 1. 0. 0.  0. 1. 0.  0. 0. 1.  1. ];
  symmetry = [ 0 0 0 ];

% xy-shear
  affine = [ 1. 1. 0.  0. 1. 0.  0. 0. 1.  1. ];
  symmetry = [ 0 1 1 ];
  symmetry = [ 0 0 1 ];

% zx-shear
  affine = [ 1. 0. 1.  0. 1. 0.  0. 0. 1.  1. ];
  symmetry = [ 0 1 1 ];
  symmetry = [ 0 1 0 ];

