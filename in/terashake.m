% Terashake

  out = { 'x'    1  1 1 -1  -1 -1 -1 };
  out = { 'v'   10  1 1 -1  -1 -1 -1 };
  out = { 'x'    1  1 0  1  -1  0 -1 };
  out = { 'svm' 10  1 0  1  -1  0 -1 };
  out = { 'sl'  10  1 0  1  -1  0 -1 };

  upvector = [ 0 0 1 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 0 ];
  faultnormal = 2;
  datadir = 'tstmp';
  grid = 'read';
  rho  = 'read';
  vp   = 'read';
  vs   = 'read';
  vs1 = 500.;
  vp1 = 1500.;
  mus = 1.;
  mud = 0.;
% mus = [ .6 'cube' 265863. 0. -16000.   459340. -2000. 4000. ];

% 1000m - Babieca
  np = [ 8 4 1 ]
  nn = [ 601 302 81 ];
  mus = [ .6   'zone'   267 0 -17   460 0 -3 ];
  ihypo = [ 275 203 -9 ];
  ihypo = [ 452 203 -9 ];
  dx = 1000.;
  nt = 3000;
  dt = .06;
return

% 4000m - Single processor
  np = [ 1 1 2 ]
  np = [ 1 1 1 ]
  nn = [ 151 77 21 ];
  mus = FIXME
  ihypo = [  69 52 -3 ];
  ihypo = [ 114 52 -3 ];
  dx = 4000.;
  nt = 1;
  nt = 750;
  dt = .24;
return

% 200m - DataStar
  np = [ 16 8 4 ]
  nn = [ 3001 1502 401 ];
  mus = FIXME
  ihypo = FIXME
  dx = 200.;
  nt = 13000;
  dt = .014;
  itcheck = 1000;
return

% 2000m - Single processor
  np = [ 1 1 1 ]
  nn = [ 301 152 41 ];
  mus = FIXME
  ihypo = FIXME
  dx = 2000.;
  nt = 1300;
  dt = .14;
return

% 500m - Babieca
  np = [ 8 4 1 ]
  nn = [ 1201 602 161 ];
  mus = FIXME
  ihypo = FIXME
  dx = 500.;
  nt = 5200;
  dt = .035;
return

% 400m - DataStar
  np = [ 16 8 4 ]
  nn = [ 1501 752 201 ];
  mus = FIXME
  ihypo = FIXME
  dx = 400.;
  nt = 6500;
  dt = .028;
return

