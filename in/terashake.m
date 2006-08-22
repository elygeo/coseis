% Terashake
  upvector = [ 0 0 1 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 0 ];
  faultnormal = 2;
  datadir = 'tmp';
  grid = 'read';
  rho = 'read';
  vp = 'read';
  vs = 'read';
  vs1 = 500.;
  vp1 = 1500.;
  vdamp = 400.;
  th = 'read';
  tn = 'read';
  mud = .3;
  mus = 1000.;
  dc = .64592;
  rcrit = 6000.;
  vrup = 500.;
  out = { 'x'     1   1 1 -1   -1 -1 -1 };
  out = { 'v'   100   1 1 -1   -1 -1 -1 };
  out = { 'pv'   -1   1 1 -1   -1 -1 -1 };
  out = { 'x'     1   1 0  1   -1  0 -1 };
  out = { 'sv'  100   1 0  1   -1  0 -1 };
  out = { 'psv'  -1   1 0  1   -1  0 -1 };
  out = { 'su'   -1   1 0  1   -1  0 -1 };
  out = { 'sl'   -1   1 0  1   -1  0 -1 };
  out = { 'tn'   -1   1 0  1   -1  0 -1 };
  out = { 'ts'   -1   1 0  1   -1  0 -1 };
  out = { 'trup' -1   1 0  1   -1  0 -1 };
  timeseries = { 'v'  89667.  58002.  11. }; % UCSB
  timeseries = { 'v' 214284. 109183. 135. }; % UCLA
  timeseries = { 'v' 220592. 101610.   3. }; % ISI
  timeseries = { 'v' 228866. 113967.  54. }; % USC
  timeseries = { 'v' 231991. 133257. 238. }; % Caltech
  timeseries = { 'v' 243000. 127800.  73. }; % Montebello
  timeseries = { 'v' 300417. 166543. 321. }; % UCR
  timeseries = { 'v' 384166.  76740.  58. }; % SIO
  timeseries = { 'v' 403893.  80018. 107. }; % SDSU
  timeseries = { 'v' 366597. 200401. 130. }; % Palm Springs

% 4000m
% rcrit = 10000.;
% vrup = 1000.;
% tn  = -11500000.;
  dx = 4000.;
  dt = .24;
  nt = 750;
  nt = 100;
  itcheck = 80;
  np = [ 1 1 1 ]
  np = [ 2 3 1 ]
  nn = [ 151 77 21 ];
  ihypo = [  69 51 -2 ];
  ihypo = [ 114 51 -2 ];
  mus = [ .6 'zone'  67 0 -5   116 0 -1 ];
  out = { 'v'   10   1 1 -1   -1 -1 -1 };
  out = { 'su'  10   1 0  1   -1  0 -1 };
  out = { 'sv'  10   1 0  1   -1  0 -1 };
return

% 400m
  dx = 400.;
  dt = .024;
  nt = 7500;
  np = [ 21 8 3 ]
  nn = [ 1501 752 201 ];
  ihypo = [  679 499 -21 ];
  ihypo = [ 1136 499 -21 ];
  mus  = [ .6 'zone' 659 0 -41   1156 0 -1 ];
return

% 1000m
  dx = 1000.;
  dt = .06;
  nt = 3000;
  np = [ 8 4 1 ]
  nn = [ 601 302 81 ];
  ihypo = [ 272 200 -9 ];
  ihypo = [ 455 200 -9 ];
  mus = [ .6 'zone'  264 0 -17   463 0 -1 ];
return

% 2000m
  dx = 2000.;
  dt = .12;
  nt = 1500;
  np = [ 1 1 1 ]
  nn = [ 301 152 41 ];
  ihypo = [ 137 101 -5 ];
  ihypo = [ 228 101 -5 ];
  mus = [ .6 'zone'  133 0 -9   232 0 -1 ];
return

% 200m
  dx = 200.;
  dt = .012;
  nt = 15000;
  np = [ 16 8 4 ]
  nn = [ 3001 1502 401 ];
  ihypo = [ ? ? -1 ];
  ihypo = [ ? ? -1 ];
  mus = [ .6 'zone'  ? 0 -81   ? 0 -1 ];
  itcheck = 1000;
return

% 500m
  dx = 500.;
  dt = .03;
  nt = 6000;
  np = [ 8 4 1 ]
  nn = [ 1201 602 161 ];
  ihypo = [ ? ? -1 ];
  ihypo = [ ? ? -1 ];
  mus = [ .6 'zone'  ? 0 -33   ? 0 -1 ];
return

