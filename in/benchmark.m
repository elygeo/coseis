% Benchmark

  dx = 100.;
  dt = .0075;
  faultnormal = 0;
  fixhypo = 2;
  rsource = 50.;
  debug = 0;
  oplevel = 6;
  oplevel = 5;
  oplevel = 4;
  oplevel = 3;
  oplevel = 2;
  oplevel = 1;
  hourglass = [ 1. 1. ];
  bc1 = [ 1 0 0 ];
  npml = 1;

  % 4^3
  nt = 4;
  nn = [ 16 16 16 ]; np = [ 8 8 8 ];
  nn = [  8  8  8 ]; np = [ 4 4 4 ];
  nn = [  4  4  4 ]; np = [ 2 2 2 ];
  nn = [  2  2  2 ]; np = [ 1 1 1 ];

  % 128^3
  nt = 128;
  nn = [ 1024 1024 1024 ]; np = [ 8 8 8 ];
  nn = [  512  512  512 ]; np = [ 4 4 4 ];
  nn = [  256  256  256 ]; np = [ 2 2 2 ];
  nn = [  128  128  128 ]; np = [ 1 1 1 ];

  % 32^3
  nt = 32;
  nn = [ 256 256 256 ]; np = [ 8 8 8 ];
  nn = [ 128 128 128 ]; np = [ 4 4 4 ];
  nn = [  64  64  64 ]; np = [ 2 2 2 ];
  nn = [  32  32  32 ]; np = [ 1 1 1 ];

  % 32^3
  nt = 64;
  nn = [ 512 512 512 ]; np = [ 8 8 8 ];
  nn = [ 256 256 256 ]; np = [ 4 4 4 ];
  nn = [ 128 128 128 ]; np = [ 2 2 2 ];
  nn = [  64  64  64 ]; np = [ 1 1 1 ];

