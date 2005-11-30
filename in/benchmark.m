% Kostrov constant rupture velocity test

  nt = 16;
  nn = [ 2048 2048 2048 ];
  nn = [ 1024 1024 1024 ];
  nn = [ 512 512 512 ];
  nn = [ 256 256 256 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 1 ];
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
  out = { 'sl' 1   1 1 0   -1 -1 0 };
  out = { 'sv' 1   1 1 0   -1 -1 0 };

