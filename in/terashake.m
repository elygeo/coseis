% Terashake
  upvector = [ 0 0 1 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 0 ];
  faultnormal = 2;
  datadir = 'tmp';
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
  dc = .64592;
  rcrit = -1.;
  out = { 'x'     1  1 1 -1  -1 -1 -1 };
  out = { 'v'   100  1 1 -1  -1 -1 -1 };
  out = { 'pv'   -1  1 1 -1  -1 -1 -1 };
  out = { 'x'     1  1 0  1  -1  0 -1 };
  out = { 'sum' 100  1 0  1  -1  0 -1 };
  out = { 'svm' 100  1 0  1  -1  0 -1 };
  out = { 'ts'  100  1 0  1  -1  0 -1 };
  out = { 'psv'  -1  1 0  1  -1  0 -1 };
  out = { 'trup' -1  1 0  1  -1  0 -1 };
  timeseries = { 'v'  89667.  58002.   11. }; % UCSB
  timeseries = { 'v' 214284. 109183.  135. }; % UCLA
  timeseries = { 'v' 220592. 101610.    3. }; % ISI
  timeseries = { 'v' 228866. 113967.   54. }; % USC
  timeseries = { 'v' 231991. 133257.  238. }; % Caltech
  timeseries = { 'v' 243000. 127800.   73. }; % Montebello
  timeseries = { 'v' 300417. 166543.  321. }; % UCR
  timeseries = { 'v' 384166.  76740.   58. }; % SIO
  timeseries = { 'v' 403893.  80018.  107. }; % SDSU
  timeseries = { 'v' 366597. 200401.  130. }; % Palm Springs
  timeseries = { 'v' 387717. 187412. 1296. }; % PFO

% 2000m - Single processor
  np = [ 1 1 1 ]
  nn = [ 301 152 41 ];
  ihypo = [ 133 101 -1 ];
  ihypo = [ 232 101 -1 ];
  dx = 2000.;
  nt = 1500;
  dt = .12;
return

% 1000m - Babieca
  np = [ 8 4 1 ]
  nn = [ 601 302 81 ];
  ihypo = [ 264 200 -1 ];
  ihypo = [ 463 200 -1 ];
  dx = 1000.;
  nt = 3000;
  dt = .06;
return

% 4000m - Single processor
  np = [ 1 1 1 ]
  nn = [ 151 77 21 ];
  ihypo = [  67 51 -1 ];
  ihypo = [ 116 51 -1 ];
  dx = 4000.;
  dt = .24;
  nt = 750;
  nt = 1;
% out = { 'x'    1  1 1  1  -1 -1 -1 };
% out = { 'nhat' 1  1 0  1  -1  0 -1 };
% out = { 't0'   1  1 0  1  -1  0 -1 };
% out = { 'tnm'  1  1 0  1  -1  0 -1 };
% out = { 'tsm'  1  1 0  1  -1  0 -1 };
% out = { 't'    1  1 0  1  -1  0 -1 };
% rho = 2670.;
% vp  = 6000.;
% vs  = 3464.1016;
% rcrit = 10000.;
% tn = -1e12;
% th = 0.;
% tn = [ -10e6 'zone'  67 0 -5   116 0 -1 ];
% th = [   9e6 'zone'  67 0 -5   116 0 -1 ];
return

% 200m - DataStar
  np = [ 16 8 4 ]
  nn = [ 3001 1502 401 ];
  ihypo = FIXME
% ihypo = [ -1 ];
% ihypo = [ -1 ];
  dx = 200.;
  nt = 15000;
  dt = .012;
  itcheck = 1000;
return

% 500m - Babieca
  np = [ 8 4 1 ]
  nn = [ 1201 602 161 ];
  ihypo = FIXME
% ihypo = [ -1 ];
% ihypo = [ -1 ];
  dx = 500.;
  nt = 6000;
  dt = .03;
return

% 400m - DataStar
  np = [ 16 8 4 ]
  nn = [ 1501 752 201 ];
  ihypo = FIXME
% ihypo = [ -1 ];
% ihypo = [ -1 ];
  dx = 400.;
  nt = 7500;
  dt = .024;
return

