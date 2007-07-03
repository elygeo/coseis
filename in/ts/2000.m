% TeraShake 2000m
  datadir = 'ts/2000/data';
  itcheck = 0;
  itio = 100;
  nt = 1500;
  np = [ 1 1 2 ];




  grid  = 'read';
  rho   = 'read';
  vp    = 'read';
  vs    = 'read';
  vs1   = 500.;
  vp1   = 1500.;
  vdamp = 400.;
  gam2  = .8;
  bc1   = [ 10 10 10 ];
  bc2   = [ 10 10  0 ];

  fixhypo = 1;
  faultnormal = 2;
  slipvector = [ 1. 0. 0. ];
  mus = 1000.;
  mud = .5;
  dc  = .5;
  tn  = -20e6;
  ts1 = 'read';
  vrup = 2300.;
  rcrit = 3000.;

  trelax = 1.2;
  dt = .12;
  dx = 2000.;
  nn    = [  301  152  41 ];
  ihypo = [  138  101  -4 ];
  ihypo = [  227  101  -4 ];
  mus = [ 1.04 'zone'   133   0  -9         232  0 -1      ];
  out = { 'x'      1    133   0  -9    0    232  0 -1    0 };
  out = { 'vs'     1    133 100  -9    0    232  0 -1    0 };
  out = { 'tn'    10    133   0  -9    0    232  0 -1  750 };
  out = { 'tsm'   10    133   0  -9    0    232  0 -1  750 };
  out = { 'sl'    10    133   0  -9    0    232  0 -1  750 };
  out = { 'svm'   10    133   0  -9    0    232  0 -1  750 };
  out = { 'psv'   10    133   0  -9    0    232  0 -1  750 };
  out = { 'trup'   1    133   0  -9  750    232  0 -1  750 };
  out = { 'x'      1      1   1  -1    0     -1 -1 -1    0 };
  out = { 'vs'     1      1   1  -2    0     -1 -1 -1    0 };
  out = { 'pv2'  750      1   1  -1  750     -1 -1 -1 1500 };
% out = { 'vm2'   10      1   1  -1    0     -1 -1 -1 1500 };
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

