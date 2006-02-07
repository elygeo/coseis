% PML test problem

  viscosity = [ 0 16 ];
  debug = 1;
  np = [ 1 1 1 ];
  faultnormal = 0;
  rsource = 150.;
  out = { 'x' 1  1 1 1   -1 -1 -1 };
  out = { 'v' 1  1 1 1   -1 -1 -1 };
  nt = 160;

  gridtrans = [   1. 0. 0.; 0.  1. 0.; 0. 0.  1. ] /  1.; % no strain
  ihypo = [ -1 -1 -1 ];
  bc2 = [ 2 2 2 ];
  nn = [ 161 161 161 ];
  bc1 = [ 0 0 0 ];
  nn = [ 81 81 81 ];
  bc1 = [ 1 1 1 ];
  nn = [ 41 41 41 ];
  return

  gridtrans = [  25. 0. 9.; 0. 10. 0.; 0. 0. 16. ] / 10.; % 2D strain
  gridtrans = [   4. 0. 0.; 0.  1. 0.; 0. 0.  1. ] /  1.; % 1D strain
  gridtrans = [  12. 3. 3.; 0.  9. 1.; 0. 0.  8. ] /  6.; % 3D strain
  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 1 ];

