% Terashake

  out = { 'x'   1   1 1 1  -1 -1 -1 };
  out = { 'v'   20  1 1 1  -1 -1 -1 };
  out = { 'svm' 1   1 0 1  -1  0 -1 };
  out = { 'sl'  1   1 0 1  -1  0 -1 };

  upvector = [ 0 0 1 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 0 ];
  faultnormal = 2;
  grid = 'constant';
  grid = 'read';

  nn = [ 3001 1502 401 ];
  dx = 200.;
  nt = 6000;
  dt = .014;

  mus = 1e9;
  mus = [ .6 'zone' 68 51 16   115 51 21 ];
  ihypo = [ 115 51 16 ];
  nn = [ 151 76 21 ];
  dx = 4000.;
  nt = 300;
  dt = .28;

