% PML test problem

  debug = 1;
  np = [ 1 1 1 ];
  rfunc = 'box';
  faultnormal = 0;
  rsource = 150.;
  nt = 1;
  nt = 100;
  %out = { 'x' 1   21 21 61   61 61 61 };
  %out = { 'v' 1   21 21 61   61 61 61 };
  out = { 'x' 1  1 1 1   -1 -1 -1 };
  out = { 'v' 1  1 1 1   -1 -1 -1 };

  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 1 ];

  nn = [ 161 161 161 ];
  nn = [ 81 81 81 ];
  nn = [ 8 4 4 ];
  nn = [ 41 41 41 ];
  %ihypo = [ 31 21 21 ];

  gridtrans = [  25. 0. 9.; 0. 10. 0.; 0. 0. 16. ] / 10.; % 2D strain
  gridtrans = [   4. 0. 0.; 0.  1. 0.; 0. 0.  1. ] /  1.; % 1D strain
  gridtrans = [  12. 3. 3.; 0.  9. 1.; 0. 0.  8. ] /  6.; % 3D strain

  gridtrans = [   1. 0. 0.; 0.  1. 0.; 0. 0.  1. ] /  1.; % no strain
  ihypo = [ 0 -1 0 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 2 1 ];

