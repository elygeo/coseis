% TeraShake 200 m
% np(2) = 1:43, 56, 76, 80, np(3) = 1:4, 10, 15, 20, 24, 29, 34, 37, 45
  datadir = 'ts/0200/data'; itio = 400; itcheck = 2000;
  nt =  7500;
  np = [ 1 40 45 ] % DS 225/265
  np = [ 1 24 20 ] % TG 240/256
  np = [ 1 15 20 ] % TG 150/256


  grid  = 'read';
  rho   = 'read';
  vp    = 'read'; vp1  = 1500.;
  vs    = 'read'; vs1  = 500.;
  vdamp = 400.;   gam2 = .8;
  bc1   = [ 10 10 10 ];
  bc2   = [ 10 10  0 ];
  fixhypo = 1; faultnormal = 2; slipvector = [ 1. 0. 0. ];
  mus = 1000.;
  mud = .5;
  dc  = .5;
  tn  = -20e6;
  ts1 = 'read';
  rcrit = 3000.; vrup = 2300.;

  dx = 200.; dt = .012; trelax = .12;
  nn    = [ 3001 1502 401 ];
  ihypo = [ 1362  997 -26 ];
  ihypo = [ 2266  997 -26 ];
  mus = [ 1.10 'zone'  1317   0 -81        2311   0 -1      ];
  out = { 'x'      1   1317 997 -81    0   2311 997 -1    0 };
  out = { 'rho'    1   1317   0 -81    0   2311   0 -1    0 };
  out = { 'vp'     1   1317   0 -81    0   2311   0 -1    0 };
  out = { 'vs'     1   1317   0 -81    0   2311   0 -1    0 };
  out = { 'gam'    1   1317   0 -81    0   2311   0 -1    0 };
  out = { 'gamt'   1   1317   0 -81    0   2311   0 -1    0 };
  out = { 'tn'    10   1317   0 -81    0   2311   0 -1 7500 };
  out = { 'tsm'   10   1317   0 -81    0   2311   0 -1 7500 };
  out = { 'sl'    10   1317   0 -81    0   2311   0 -1 7500 };
  out = { 'svm'   10   1317   0 -81    0   2311   0 -1 7500 };
  out = { 'psv'   10   1317   0 -81    0   2311   0 -1 7500 };
  out = { 'trup' 500   1317   0 -81 5000   2311   0 -1 7500 };
% return
  out = { 'x'      1      1   1  -1    0     -1  -1 -1    0 };
  out = { 'rho'    1      1   1  -2    0     -1  -1 -1    0 };
  out = { 'vp'     1      1   1  -2    0     -1  -1 -1    0 };
  out = { 'vs'     1      1   1  -2    0     -1  -1 -1    0 };
  out = { 'pv2'  100      1   1  -1    0     -1  -1 -1   -1 };
  out = { 'pv2'  100      1   1  -1   20     -1  -1 -1   -1 };
  out = { 'pv2'  100      1   1  -1   40     -1  -1 -1   -1 };
  out = { 'pv2'  100      1   1  -1   60     -1  -1 -1   -1 };
  out = { 'pv2'  100      1   1  -1   80     -1  -1 -1   -1 };
  out = { 'vm2'  100      1   1  -1    0     -1  -1 -1   -1 };
  out = { 'vm2'  100      1   1  -1   20     -1  -1 -1   -1 };
  out = { 'vm2'  100      1   1  -1   40     -1  -1 -1   -1 };
  out = { 'vm2'  100      1   1  -1   60     -1  -1 -1   -1 };
  out = { 'vm2'  100      1   1  -1   80     -1  -1 -1   -1 };
  timeseries = { 'v'  82188. 188340. 129. }; % Bakersfield
  timeseries = { 'v'  99691.  67008.  21. }; % Santa Barbara
  timeseries = { 'v' 152641.  77599.  16. }; % Oxnard
  timeseries = { 'v' 191871. 180946. 714. }; % Lancaster
  timeseries = { 'v' 216802. 109919.  92. }; % Westwood
  timeseries = { 'v' 229657. 119310. 107. }; % Los Angeles
  timeseries = { 'v' 242543. 123738.  63. }; % Montebello
  timeseries = { 'v' 253599.  98027.   7. }; % Long Beach
  timeseries = { 'v' 256108. 263112. 648. }; % Barstow
  timeseries = { 'v' 263052. 216515. 831. }; % Victorville
  timeseries = { 'v' 271108. 155039. 318. }; % Ontario
  timeseries = { 'v' 278097. 115102.  36. }; % Santa Ana
  timeseries = { 'v' 293537. 180173. 327. }; % San Bernardino
  timeseries = { 'v' 296996. 160683. 261. }; % Riverside
  timeseries = { 'v' 351928.  97135.  18. }; % Oceanside
  timeseries = { 'v' 366020. 200821. 140. }; % Palm Springs
  timeseries = { 'v' 403002. 210421. -18. }; % Coachella
  timeseries = { 'v' 402013.  69548.  23. }; % San Diego
  timeseries = { 'v' 501570.  31135.  24. }; % Ensenada
  timeseries = { 'v' 526989. 167029.   1. }; % Mexicali
  timeseries = { 'v' 581530. 224874.  40. }; % Yuma

