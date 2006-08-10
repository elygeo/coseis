% Terashake

% testing
  out = { 'tn'   1  1 0  1  -1  0 -1 };
  out = { 'ts'   1  1 0  1  -1  0 -1 };
  out = { 't0'   1  1 0  1  -1  0 -1 };
  out = { 't'    1  1 0  1  -1  0 -1 };

  out = { 'x'     1  1 1 -1  -1 -1 -1 };
  out = { 'v'   100  1 1 -1  -1 -1 -1 };
  out = { 'pv'   -1  1 1 -1  -1 -1 -1 };
  out = { 'x'     1  1 0  1  -1  0 -1 };
  out = { 'svm' 100  1 0  1  -1  0 -1 };
  out = { 'psv'  -1  1 0  1  -1  0 -1 };
  out = { 'trup' -1  1 0  1  -1  0 -1 };
  timeseries = { 'v' 243000. 127800. 73. }; % Montebello

  upvector = [ 0 0 1 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 0 ];
  faultnormal = 2;
  datadir = 'ts/tmp';
  grid = 'read';
  rho  = 'read';
  vp   = 'read';
  vs   = 'read';
  tn   = 'read';
  th   = 'read';
  vs1 = 500.;
  vp1 = 1500.;
  mus = 1.;
  mud = 0.;
  dc = .64592

% 4000m - Single processor
  np = [ 1 1 1 ]
  nn = [ 151 77 21 ];
  ihypo = [ 67 51 -1 ];
  dx = 4000.;
  nt = 750;
  nt = 1;
  dt = .24;
return

% 1000m - Babieca
  np = [ 8 4 1 ]
  nn = [ 601 302 81 ];
  ihypo = FIXME
  dx = 1000.;
  nt = 3000;
  dt = .06;
return

% 200m - DataStar
  np = [ 16 8 4 ]
  nn = [ 3001 1502 401 ];
  ihypo = FIXME
  dx = 200.;
  nt = 13000;
  dt = .014;
  itcheck = 1000;
return

% 2000m - Single processor
  np = [ 1 1 1 ]
  nn = [ 301 152 41 ];
  ihypo = FIXME
  dx = 2000.;
  nt = 1300;
  dt = .14;
return

% 500m - Babieca
  np = [ 8 4 1 ]
  nn = [ 1201 602 161 ];
  ihypo = FIXME
  dx = 500.;
  nt = 5200;
  dt = .035;
return

% 400m - DataStar
  np = [ 16 8 4 ]
  nn = [ 1501 752 201 ];
  ihypo = FIXME
  dx = 400.;
  nt = 6500;
  dt = .028;
return

