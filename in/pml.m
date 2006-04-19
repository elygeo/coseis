% PML test problem

  debug = 1;
  np = [ 1 1 1 ];
  faultnormal = 0;
  rsource = 150.;
  out = { 'x' 50  1 1 1   -1 -1 -1 };
  out = { 'v' 50  1 1 1   -1 -1 -1 };
  nt = 160;
  nt = 30;
  nt = 1000;

  moment1 = [ 0 0 0 ];
  moment2 = [ 3e16 0 0 ];

% Rect
  ihypo = [ 0 0 0 ];
  ihypo = [ -1 -1 -1 ];
  nn = [ 81 81 81 ];
  nn = [ 11 11 11 ];
  nn = [ 41 41 41 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 3 3 3 ];
return

% Non-rect
  nn = [ 41 41 41 ];
  affine = [   1. 0. 0.  0.  1. 1.  0. 0.  1. ] /  1.; % shear 1
  affine = [   1. 0. 1.  0.  1. 0.  0. 0.  1. ] /  1.; % shear 2
  affine = [   1. 1. 0.  0.  1. 0.  0. 0.  1. ] /  1.; % shear 3
  affine = [  25. 0. 9.  0. 10. 0.  0. 0. 16. ] / 10.; % 2D strain
  affine = [   4. 0. 0.  0.  1. 0.  0. 0.  1. ] /  1.; % 1D strain
  affine = [  12. 3. 3.  0.  9. 1.  0. 0.  8. ] /  6.; % 3D strain
  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 1 ];
return

