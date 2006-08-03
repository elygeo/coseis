% Terashake

  out = { 'x'   1   1 1 1  -1 -1 -1 };
  out = { 'v'   20  1 1 1  -1 -1 -1 };
  out = { 'svm' 1   1 0 1  -1  0 -1 };
  out = { 'sl'  1   1 0 1  -1  0 -1 };

  upvector = [ 0 0 1 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 0 ];
  faultnormal = 2;
  datadir = 'ts/tmp';
  grid = 'read';
  rho  = 'read';
  vp   = 'read';
  vs   = 'read';
  vs1 = 500.;
  vp1 = 1500.;
  mus = 1e9;
  mus = [ .6 'cube' 265863. 0. -15000.   459340. 300000. 4000. ];

% 4000m - Single processor
  np = [ 1 1 2 ]
  np = [ 1 1 1 ]
  nn = [ 151 77 21 ];
  ihypo = [  69 52 19 ];
  ihypo = [ 114 52 19 ];
  dx = 4000.;
  nt = 650;
  nt = 1;
  dt = .28;
return

% 1000m - Babieca
  np = [ 8 4 1 ]
  nn = [ 601 302 81 ];
  dx = 1000.;
  nt = 2600;
  dt = .07;
return

% 200m - DataStar
  np = [ 16 8 4 ]
  nn = [ 3001 1502 401 ];
  dx = 200.;
  nt = 13000;
  dt = .014;
  itcheck = 1000;
return

% 2000m - Single processor
  np = [ 1 1 1 ]
  nn = [ 301 152 41 ];
  dx = 2000.;
  nt = 1300;
  dt = .14;
return

% 500m - Babieca
  np = [ 8 4 1 ]
  nn = [ 1201 602 161 ];
  dx = 500.;
  nt = 5200;
  dt = .035;
return

% 400m - DataStar
  np = [ 16 8 4 ]
  nn = [ 1501 752 201 ];
  dx = 400.;
  nt = 6500;
  dt = .028;
return

