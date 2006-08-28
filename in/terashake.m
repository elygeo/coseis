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
  mud = .5;
  mus = 1000.;
  dc = .5;
  rcrit = 6000.;
  vrup = 2300.;
  out = { 'x'     0   1 1 -1   -1 -1 -1 };
  out = { 'v'   100   1 1 -1   -1 -1 -1 };
  out = { 'pv'   -1   1 1 -1   -1 -1 -1 };
  out = { 'x'     0   1 0  1   -1  0 -1 };
  out = { 'sv'  100   1 0  1   -1  0 -1 };
  out = { 'psv'  -1   1 0  1   -1  0 -1 };
  out = { 'su'   -1   1 0  1   -1  0 -1 };
  out = { 'sl'   -1   1 0  1   -1  0 -1 };
  out = { 'tn'    0   1 0  1   -1  0 -1 };
  out = { 'ts'    0   1 0  1   -1  0 -1 };
  out = { 'tn'   -1   1 0  1   -1  0 -1 };
  out = { 'ts'   -1   1 0  1   -1  0 -1 };
  out = { 'trup' -1   1 0  1   -1  0 -1 };
  timeseries = { 'v'  89667.  58002.  11. }; % UCSB
  timeseries = { 'v' 214284. 109183. 135. }; % UCLA
  timeseries = { 'v' 228866. 113967.  54. }; % USC
  timeseries = { 'v' 231991. 133257. 239. }; % Caltech
  timeseries = { 'v' 286862. 108014.  14. }; % UCI
  timeseries = { 'v' 300417. 166543. 321. }; % UCR
  timeseries = { 'v' 384166.  76740.  58. }; % SIO
  timeseries = { 'v' 403893.  80018. 107. }; % SDSU
  timeseries = { 'v'  82188. 188340. 129. }; % Bakersfield
  timeseries = { 'v' 191871. 180946. 714. }; % Lancaster
  timeseries = { 'v' 243000. 127800.  73. }; % Montebello
  timeseries = { 'v' 256108. 263112. 648. }; % Barstow
  timeseries = { 'v' 263052. 216515. 831. }; % Victorville
  timeseries = { 'v' 366597. 200401. 131. }; % Palm Springs
  timeseries = { 'v' 501570.  31135.  24. }; % Ensenada
  timeseries = { 'v' 526989. 167029.   1. }; % Mexicali
  timeseries = { 'v' 581530. 224874.  40. }; % Yuma

  itcheck = 1000;
  tn = -20e6;

% 4000m
  dx = 4000.;
  dt = .24;
  trelax = 2.4;
  nt = 300;
  np = [ 2 1 1 ]
  nn = [ 151 77 21 ];
  ihypo = [  69 51 -2 ];
  ihypo = [ 114 51 -2 ];
  mus = [ 1.1 'zone'  67 0 -5   116 0 -1 ];
return

% 1000m
  dx = 1000.;
  dt = .06;
  trelax = .6;
  nt = 3000;
  np = [ 8 4 1 ]
  nn = [ 601 302 81 ];
  ihypo = [ 273 200 -6 ];
  ihypo = [ 454 200 -6 ];
  mus = [ 1.1 'zone'  264 0 -17   463 0 -1 ];
return

% 400m
  dx = 400.;
  dt = .024;
  trelax = .24;
  nt = 7500;
  np = [ 21 8 3 ]
  nn = [ 1501 752 201 ];
  ihypo = [  682 499 -14 ];
  ihypo = [ 1133 499 -14 ];
  mus  = [ 1.1 'zone' 659 0 -41   1156 0 -1 ];
return

% 2000m
  dx = 2000.;
  dt = .12;
  trelax = 1.2;
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
  trelax = .12;
  nt = 15000;
  np = [ 16 8 4 ]
  nn = [ 3001 1502 401 ];
  ihypo = [ ? ? -1 ];
  ihypo = [ ? ? -1 ];
  mus = [ .6 'zone'  ? 0 -81   ? 0 -1 ];
return

% 500m
  dx = 500.;
  dt = .03;
  trelax = .3;
  nt = 6000;
  np = [ 8 4 1 ]
  nn = [ 1201 602 161 ];
  ihypo = [ ? ? -1 ];
  ihypo = [ ? ? -1 ];
  mus = [ .6 'zone'  ? 0 -33   ? 0 -1 ];
return

