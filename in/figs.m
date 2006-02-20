% TPV3
  debug = 1;
  faultnormal = 3;
  vrup = -1.;
  origin = 0;
  ihypo = [ 0 0 0 ];
  out = { 'x'    1      1 1 1   -1 -1 -1 };
  out = { 'sv'   1      1 1 1   -1 -1 -1 };
  out = { 'sl'   1      1 1 1   -1 -1 -1 };
  out = { 'dc'   1      1 1 1   -1 -1 -1 };
  dc = 0.;
  dc = { 1. 'cube' -15001. -7501. -1.  15001. 7501. 1. };
  dc = { 2. 'cube'  -1501. -1501. -1.   1501. 1501. 1. };
  dx  = 1500;
  nt  = 2;
  nn = [ 33 13 14 ];

% shear 3
  affine = [ 1. 1. 0.; 0. 1. 0.; 0. 0. 1. ] / 1.;
  symmetry = [ 0 1 1 ];
  symmetry = [ 0 0 1 ];

% shear 2
  affine = [ 1. 0. 1.; 0. 1. 0.; 0. 0. 1. ] / 1.;
  symmetry = [ 0 1 1 ];
  symmetry = [ 0 1 0 ];

% shear 1
  affine = [ 1. 0. 0.; 0. 1. 1.; 0. 0. 1. ] / 1.;
  symmetry = [ 1 0 1 ];
  symmetry = [ 1 0 0 ];

% no strain
  affine = [ 1. 0. 0.; 0. 1. 0.; 0. 0. 1. ] / 1.;
  symmetry = [ 0 0 0 ];

