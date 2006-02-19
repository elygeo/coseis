% PML test problem

  debug = 1;
  np = [ 1 1 1 ];
  faultnormal = 0;
  rsource = 150.;
  out = { 'x' 1  1 1 1   -1 -1 -1 };
  out = { 'v' 1  1 1 1   -1 -1 -1 };
  nt = 160;
  nt = 30;

% Rect
  gridtrans = [   1. 0. 0.; 0.  1. 0.; 0. 0.  1. ] /  1.; % no strain
  ihypo = [ 0 0 0 ];
  ihypo = [ -1 -1 -1 ];
  nn = [ 81 81 81 ];
  nn = [ 41 41 41 ];
  nn = [ 11 11 11 ];
  bc1 = [ 0 0 0 ];
  bc2 = [ 3 3 3 ];
return

% Non-rect
  nn = [ 41 41 41 ];
  gridtrans = [   1. 0. 0.; 0.  1. 1.; 0. 0.  1. ] /  1.; % shear 1
  gridtrans = [   1. 0. 1.; 0.  1. 0.; 0. 0.  1. ] /  1.; % shear 2
  gridtrans = [   1. 1. 0.; 0.  1. 0.; 0. 0.  1. ] /  1.; % shear 3
  gridtrans = [  25. 0. 9.; 0. 10. 0.; 0. 0. 16. ] / 10.; % 2D strain
  gridtrans = [   4. 0. 0.; 0.  1. 0.; 0. 0.  1. ] /  1.; % 1D strain
  gridtrans = [  12. 3. 3.; 0.  9. 1.; 0. 0.  8. ] /  6.; % 3D strain
  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 1 ];
return

