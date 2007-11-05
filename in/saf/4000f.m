% SAF 4000 m - fault

  datadir = 'saf/cvm3/4000';
  datadir = 'saf/cvm4/4000';
  itio = 100; itcheck = 0; itstats = 10;
  nt = 750;
  np = [ 1 1 2 ];




  x1    = { 'read' 'zone' 1 1 1   -1 -1 1 };
  x2    = { 'read' 'zone' 1 1 1   -1 -1 1 };
  x3    = 'read';
  rho   = 'read';
  vp    = 'read'; vp1  = 1500.;
  vs    = 'read'; vs1  = 500.;
  vdamp = 400.;   gam2 = 0.8;
  bc1   = [ 10 10 10 ];
  bc2   = [ 10 10  0 ];
  fixhypo = 1; faultnormal = 2; slipvector = [ 1. 0. 0. ];
  mus = 1000.;
  mud = 0.5;
  dc  = 0.5;
  tn  = -20e6;
  ts1 = 'read';
  rcrit = 3000.; vrup = 2300.;

  dx = 4000.; dt = 0.24; trelax = 2.4;
  nn    = [  151   77  21 ];
  ihypo = [   69   51  -2 ];
  ihypo = [  114   51  -2 ];
  mus = [ 1.00 'zone'    67   0  -5         116   0 -1      ];
  out = { 'x'      1     67  51  -5    0    116  51 -1    0 };
  out = { 'rho'    1     67   0  -5    0    116   0 -1    0 };
  out = { 'vp'     1     67   0  -5    0    116   0 -1    0 };
  out = { 'vs'     1     67   0  -5    0    116   0 -1    0 };
  out = { 'gam'    1     67   0  -5    0    116   0 -1    0 };
  out = { 'gamt'   1     67   0  -5    0    116   0 -1    0 };
  out = { 'tn'    10     67   0  -5    0    116   0 -1  375 };
  out = { 'tsm'   10     67   0  -5    0    116   0 -1  375 };
  out = { 'sl'    10     67   0  -5    0    116   0 -1  375 };
  out = { 'svm'   10     67   0  -5    0    116   0 -1  375 };
  out = { 'psv'   10     67   0  -5    0    116   0 -1  375 };
  out = { 'trup'   1     67   0  -5  375    116   0 -1  375 };
  out = { 'x'      1      1   1  -1    0     -1  -1 -1    0 };
  out = { 'rho'    1      1   1  -2    0     -1  -1 -1    0 };
  out = { 'vp'     1      1   1  -2    0     -1  -1 -1    0 };
  out = { 'vs'     1      1   1  -2    0     -1  -1 -1    0 };
  out = { 'pv2'  375      1   1  -1  375     -1  -1 -1   -1 };
  out = { 'vm2'    1      1   1  -1  375     -1  -1 -1  375 };
  out = { 'v' 1     21   49 -1 0     21   49 -1 -1 }; % Bakersfield
  out = { 'v' 1     26   18 -1 0     26   18 -1 -1 }; % Santa
  out = { 'v' 1     39   21 -1 0     39   21 -1 -1 }; % Oxnard
  out = { 'v' 1     49   49 -1 0     49   49 -1 -1 }; % Lancaster
  out = { 'v' 1     55   30 -1 0     55   30 -1 -1 }; % Westwood
  out = { 'v' 1     58   33 -1 0     58   33 -1 -1 }; % Los
  out = { 'v' 1     61   34 -1 0     61   34 -1 -1 }; % Montebello
  out = { 'v' 1     64   27 -1 0     64   27 -1 -1 }; % Long
  out = { 'v' 1     65   68 -1 0     65   68 -1 -1 }; % Barstow
  out = { 'v' 1     66   59 -1 0     66   59 -1 -1 }; % Victorville
  out = { 'v' 1     68   43 -1 0     68   43 -1 -1 }; % Ontario
  out = { 'v' 1     70   32 -1 0     70   32 -1 -1 }; % Santa
  out = { 'v' 1     74   49 -1 0     74   49 -1 -1 }; % San
  out = { 'v' 1     75   44 -1 0     75   44 -1 -1 }; % Riverside
  out = { 'v' 1     89   25 -1 0     89   25 -1 -1 }; % Oceanside
  out = { 'v' 1     93   48 -1 0     93   48 -1 -1 }; % Palm
  out = { 'v' 1    103   50 -1 0    103   50 -1 -1 }; % Coachella
  out = { 'v' 1    102   18 -1 0    102   18 -1 -1 }; % San
  out = { 'v' 1    126    9 -1 0    126    9 -1 -1 }; % Ensenada
  out = { 'v' 1    133   42 -1 0    133   42 -1 -1 }; % Mexicali
  out = { 'v' 1    146   58 -1 0    146   58 -1 -1 }; % Yuma

