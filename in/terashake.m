% Terashake
  upvector = [ 0 0 1 ];
  bc1 = [ 1 1 1 ];
  bc2 = [ 1 1 0 ];
  faultnormal = 2;
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
  out = { 'x'     1   1 1 -1 0   -1 -1 -1  0 };
  out = { 'vm'   10   1 1 -1 1   -1 -1 -1 -1 };
  out = { 'pv'  500   1 1 -1 1   -1 -1 -1 -1 };
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
  itcheck = 100;

% 2000m
  datadir = 'tmp/2000';
  dx = 2000.;
  dt = .12;
  trelax = 1.2;
  nt = 1500;
  np = [ 2 1 1 ] % Wide
  nn = [ 301 152 41 ];
  ihypo = [ 137 101 -5 ];
  ihypo = [ 228 101 -5 ];
  mus = [ 1.  'zone'  133 0 -9     232 0 -1      ];
  out = { 'x'      1  133 0 -9 0   232 0 -1    0 };
  out = { 'vs'     1  133 0 -9 0   232 0 -1    0 };
  out = { 'tsm'  100  133 0 -9 0   232 0 -1 1000 };
  out = { 'sl'    10  133 0 -9 1   232 0 -1 1000 };
  out = { 'svm'   10  133 0 -9 1   232 0 -1 1000 };
  out = { 'psv'  100  133 0 -9 1   232 0 -1 1000 };
  out = { 'trup' 100  133 0 -9 1   232 0 -1 1000 };
return

% 1000m
  dx = 1000.;
  dt = .06;
  trelax = .6;
  nt = 3000;
  np = [ 8 4 1 ] % Babiaca
  np = [ 2 1 1 ] % Wide
  nn = [ 601 302 81 ];
  ihypo = [ 273 200 -6 ];
  ihypo = [ 454 200 -6 ];
  mus = [ 1. 'zone'   264 0 -17     463 0 -1      ];
  out = { 'x'      1  264 0 -17 0   463 0 -1    0 };
  out = { 'vs'     1  264 0 -17 0   463 0 -1    0 };
  out = { 'tsm'  100  264 0 -17 0   463 0 -1 1500 };
  out = { 'sl'    10  264 0 -17 1   463 0 -1 1500 };
  out = { 'svm'   10  264 0 -17 1   463 0 -1 1500 };
  out = { 'psv'  100  264 0 -17 1   463 0 -1 1500 };
  out = { 'trup' 100  264 0 -17 1   463 0 -1 1500 };
return

% 4000m
  datadir = 'tmp/data';
  dx = 4000.;
  dt = .24;
  trelax = 2.4;
  nt = 200;
  nt = 10;
  np = [ 2 1 1 ] % Wide
  nn = [ 151 77 21 ];
  ihypo = [  69 51 -2 ];
  ihypo = [ 114 51 -2 ];
  mus = [ 1. 'zone'   67 0 -5     116 0 -1     ];
  out = { 'x'     1   67 0 -5 0   116 0 -1   0 };
  out = { 'vs'    1   67 0 -5 0   116 0 -1   0 };
  out = { 'tsm'  10   67 0 -5 0   116 0 -1 100 };
  out = { 'sl'    1   67 0 -5 1   116 0 -1 100 };
  out = { 'svm'   1   67 0 -5 1   116 0 -1 100 };
  out = { 'psv'  10   67 0 -5 1   116 0 -1 100 };
  out = { 'trup' 10   67 0 -5 1   116 0 -1 100 };
return

% 200m
  dx = 200.;
  dt = .012;
  trelax = .12;
  nt = 15000;
  np = [ 32 16 4 ] % DataStar
  np = [ 21  8 3 ] % TeraGrid
  nn = [ 3001 1502 401 ];
  ihypo = [  1362 997 -26  ];
  ihypo = [  2266 997 -26  ];
  mus = [ 1.  'zone' 1317 0 -81     2311 0 -1      ];
  out = { 'x'      1 1317 0 -81 0   2311 0 -1    0 };
  out = { 'vs'     1 1317 0 -81 0   2311 0 -1    0 };
  out = { 'tsm'  100 1317 0 -81 0   2311 0 -1 7500 };
  out = { 'sl'    10 1317 0 -81 1   2311 0 -1 7500 };
  out = { 'svm'   10 1317 0 -81 1   2311 0 -1 7500 };
  out = { 'psv'  100 1317 0 -81 1   2311 0 -1 7500 };
  out = { 'trup' 100 1317 0 -81 1   2311 0 -1 7500 };
return

% 500m
  dx = 500.;
  dt = .03;
  trelax = .3;
  nt = 6000;
  np = [ 8 4 1 ] % Babiaca
  nn = [ 1201 602 161 ];
  ihypo = [ 545 399 -11 ];
  ihypo = [ 907 399 -11 ];
  mus = [ 1.  'zone' 527 0 -33     925 0 -1      ];
  out = { 'x'      1 527 0 -33 0   925 0 -1    0 };
  out = { 'vs'     1 527 0 -33 0   925 0 -1    0 };
  out = { 'tsm'  100 527 0 -33 0   925 0 -1 3000 };
  out = { 'sl'    10 527 0 -33 1   925 0 -1 3000 };
  out = { 'svm'   10 527 0 -33 1   925 0 -1 3000 };
  out = { 'psv'  100 527 0 -33 1   925 0 -1 3000 };
  out = { 'trup' 100 527 0 -33 1   925 0 -1 3000 };
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
  mus = [ 1.  'zone' 659 0 -41     1156 0 -1      ];
  out = { 'x'      1 659 0 -41 0   1156 0 -1    0 };
  out = { 'vs'     1 659 0 -41 0   1156 0 -1    0 };
  out = { 'tsm'  100 659 0 -41 0   1156 0 -1 3500 };
  out = { 'sl'    10 659 0 -41 1   1156 0 -1 3500 };
  out = { 'svm'   10 659 0 -41 1   1156 0 -1 3500 };
  out = { 'psv'  100 659 0 -41 1   1156 0 -1 3500 };
  out = { 'trup' 100 659 0 -41 1   1156 0 -1 3500 };
return

