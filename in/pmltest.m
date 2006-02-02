% PML test problem

  np = [ 1 1 1 ];
  rfunc = 'box';
  gridtrans = [   1. 0. 0.; 0.  1. 0.; 0. 0.  1. ] /  1.; % no strain
  gridtrans = [   4. 0. 0.; 0.  1. 0.; 0. 0.  1. ] /  1.; % 1D strain
  gridtrans = [  12. 3. 3.; 0.  9. 1.; 0. 0.  8. ] /  6.; % 3D strain
  gridtrans = [  25. 0. 9.; 0. 10. 0.; 0. 0. 16. ] / 10.; % 2D strain
  faultnormal = 0;
  rsource = 150.;
  nt = 1;
  nt = 100;
  nn = [ 161 161 161 ];
  nn = [ 81 81 81 ];
  nn = [ 8 4 4 ];
  nn = [ 41 41 41 ];
  %ihypo = [ 31 21 21 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 1 ];
  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];
  %out = { 'x' 1   21 21 61   61 61 61 };
  %out = { 'v' 1   21 21 61   61 61 61 };
  out = { 'x' 1  1 1 1   -1 -1 -1 };
  out = { 'v' 1  1 1 1   -1 -1 -1 };

