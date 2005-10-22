% Kostrov constant rupture velocity test

  nn = [ 81 81 42 ];
  nt = 300;
  nn = [ 41 41 42 ];
  nt = 200;
  bc1 = [ 0 0 1 ];
  bc2 = [ 0 0 1 ];
  nn = [ 3 3 4 ];
  nt = 1;
  bc1 = [ 0 0 0 ];
  bc2 = [ 0 0 0 ];

  faultnormal = 3;
  mus = 1e9;
  mud = 0.;
  dc = 1e9;
  co = 0.;
  tn = -100e6;
  th = -90e6;
  td = 0.;
  vrup = 3117.6914;
  rcrit = 1e9;
  trelax = 0.;
  out = { 'x'  1   1 1 0   -1 -1 0 };
  out = { 'sv' 1   1 1 0   -1 -1 0 };
  out = { 'v'  20  1 1 0   -1 -1 0 };

