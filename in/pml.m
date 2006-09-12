% PML test problem
  np = [ 4 4 2 ];
  faultnormal = 0;
  rsource = 150.;
  out = { 'x'    1  1 1   0 0   -1 -1   0  0 };
  out = { 'vm' 100  1 1   0 1   -1 -1   0 -1 };
  out = { 'x'    1  1 1  20 0   -1 -1  20  0 };
  out = { 'vm' 100  1 1  20 1   -1 -1  20 -1 };
  out = { 'x'    1  1 1 -20 0   -1 -1 -20  0 };
  out = { 'vm' 100  1 1 -20 1   -1 -1 -20 -1 };
  timeseries = { 'vm'  -6000.      0.     0. }
  timeseries = { 'vm'  -6000.  -6000.     0. }
  timeseries = { 'vm'  -6000.  -6000. -6000. }
  nt = 1000;
  origin = 0;
  moment1 = [ 0 0 0 ];
  moment2 = [ 3e16 3e16 3e16 ];

% Rect
  ihypo = [ -1 -1 -1 ];
  nn = [ 81 81 81 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 3 3 3 ];
return

% Mixed rect
  ihypo = [ 0 0 0 ];
  nn = [ 161 161 161 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 0 0 0 ];
return

% Non-rect
  ihypo = [ 0 0 0 ];
  nn = [ 41 41 41 ];
  affine = [   1. 0. 0.  0.  1. 1.  0. 0.  1.   1. ]; % shear 1
  affine = [   1. 0. 1.  0.  1. 0.  0. 0.  1.   1. ]; % shear 2
  affine = [   1. 1. 0.  0.  1. 0.  0. 0.  1.   1. ]; % shear 3
  affine = [  25. 0. 9.  0. 10. 0.  0. 0. 16.  10. ]; % 2D strain
  affine = [   4. 0. 0.  0.  1. 0.  0. 0.  1.   1. ]; % 1D strain
  affine = [  12. 3. 3.  0.  9. 1.  0. 0.  8.   6. ]; % 3D strain
  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 1 ];
return

