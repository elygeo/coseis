% Test

  debug = 1;
  faultnormal = 3;
  nn = [ 3 3 4 ];
  nn = [ 8 8 8 ];
  bc1 = [ 0 0 0 ];
  bc2 = [ -3 3 -2 ];
  ihypo = [ -1 -1 0 ];
  nt = 1;
  mus = .5;
  vrup = -1.;
  out = { 'x'   1  1 1 1 0   -1 -1 -1  0 };
  out = { 'v'   1  1 1 1 1   -1 -1 -1 -1 };
  out = { 'sl'  1  1 1 1 1   -1 -1 -1 -1 };
  out = { 'svm' 1  1 1 1 1   -1 -1 -1 -1 };

