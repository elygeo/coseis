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
  tn = -20e6;
  mud = .5;
  mus = 1000.;
  dc = .5;
  rcrit = 6000.;
  vrup = 2300.;
  out = { 'x'     0   1 0  1   -1  0 -1 };
  out = { 'vs'    0   1 0  1   -1  0 -1 };
  out = { 'tsm'   0   1 0  1   -1  0 -1 };
  out = { 'tsm'  -1   1 0  1   -1  0 -1 };
  out = { 'sl'  100   1 0  1   -1  0 -1 };
  out = { 'svm' 100   1 0  1   -1  0 -1 };
  out = { 'psv'  -1   1 0  1   -1  0 -1 };
  out = { 'trup' -1   1 0  1   -1  0 -1 };
  out = { 'x'     0   1 1 -1   -1 -1 -1 };
  out = { 'vm'  100   1 1 -1   -1 -1 -1 };
  out = { 'pv'   -1   1 1 -1   -1 -1 -1 };
  timeseries = { 'v'  82188. 188340. 129. }; % Bakersfield
  timeseries = { 'v'  99691.  67008.  21. }; % Santa Barbara
  timeseries = { 'v' 191871. 180946. 714. }; % Lancaster
  timeseries = { 'v' 229657. 119310. 107. }; % Los Angeles
  timeseries = { 'v' 243000. 127800.  73. }; % Montebello
  timeseries = { 'v' 256108. 263112. 648. }; % Barstow
  timeseries = { 'v' 263052. 216515. 831. }; % Victorville
  timeseries = { 'v' 286666. 111230.  15. }; % Irvine
  timeseries = { 'v' 293537. 180173. 327. }; % San Bernardino
  timeseries = { 'v' 296996. 160683. 261. }; % Riverside
  timeseries = { 'v' 366020. 200821. 140. }; % Palm Springs
  timeseries = { 'v' 402013.  69548.  23. }; % San Diego
  timeseries = { 'v' 501570.  31135.  24. }; % Ensenada
  timeseries = { 'v' 526989. 167029.   1. }; % Mexicali
  timeseries = { 'v' 581530. 224874.  40. }; % Yuma
  itcheck = 1000;

% 200m
  dx = 200.;
  dt = .012;
  trelax = .12;
  nt = 15000;
  np = [ 21  8 3 ] % TeraGrid
  np = [ 32 16 4 ] % DataStar
  nn = [ 3001 1502 401 ];
  ihypo = [  1362 997 -26  ];
  ihypo = [  2266 997 -26  ];
  mus = [ 1. 'zone' 1317 0 -81   2311 0 -1  ];
return

% 400m
  dx = 400.;
  dt = .024;
  trelax = .24;
  nt = 7500;
  np = [ 21  8 3 ] % TeraGrid
  np = [ 16 16 4 ] % DataStar
  nn = [ 1501 752 201 ];
  ihypo = [  682 499 -14 ];
  ihypo = [ 1133 499 -14 ];
  mus  = [ 1. 'zone' 659 0 -41   1156 0 -1 ];
return

% 1000m
  dx = 1000.;
  dt = .06;
  trelax = .6;
  nt = 3000;
  np = [ 8 4 1 ] % Babiaca
  nn = [ 601 302 81 ];
  ihypo = [ 273 200 -6 ];
  ihypo = [ 454 200 -6 ];
  mus = [ 1. 'zone'  264 0 -17   463 0 -1 ];
return

% 4000m
  dx = 4000.;
  dt = .24;
  trelax = 2.4;
  nt = 200;
  np = [ 2 1 1 ]
  nn = [ 151 77 21 ];
  ihypo = [  69 51 -2 ];
  ihypo = [ 114 51 -2 ];
  mus = [ 1. 'zone'  67 0 -5   116 0 -1 ];
  rcrit = 10000.;
return

% 2000m
  dx = 2000.;
  dt = .12;
  trelax = 1.2;
  nt = 1500;
  np = [ 2 1 1 ]
  nn = [ 301 152 41 ];
  ihypo = [ 137 101 -5 ];
  ihypo = [ 228 101 -5 ];
  mus = [ 1. 'zone'  133 0 -9   232 0 -1 ];
return

% 500m
  dx = 500.;
  dt = .03;
  trelax = .3;
  nt = 6000;
  np = [ 8 4 1 ] % Babiaca
  nn = [ 1201 602 161 ];
  ihypo = [ ? ? -1 ];
  ihypo = [ ? ? -1 ];
  mus = [ 1. 'zone'  ? 0 -33   ? 0 -1 ];
return

