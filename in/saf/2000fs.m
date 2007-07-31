% SAF 2000 m - fault and surface movies

  datadir = 'saf/2000/data'; itio = 100; itcheck = 0; itstats = 10;
  nt = 1500;
  nt =  750;
  np = [ 1 1 4 ];



  x1    = { 'read' 'zone' 1 1 1   -1 -1 1 };
  x2    = { 'read' 'zone' 1 1 1   -1 -1 1 };
% x3    = 'read';
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

  dx = 2000.; dt = .12; trelax = 1.2;
  nn    = [  301  152  41 ];
  ihypo = [  138  101  -4 ];
  ihypo = [  227  101  -4 ];
  mus = [ 1.04 'zone'   133   0  -9         232   0 -1      ];
  out = { 'x'      1    133 101  -9    0    232 101 -1    0 };
  out = { 'rho'    1    133   0  -9    0    232   0 -1    0 };
  out = { 'vp'     1    133   0  -9    0    232   0 -1    0 };
  out = { 'vs'     1    133   0  -9    0    232   0 -1    0 };
  out = { 'gam'    1    133   0  -9    0    232   0 -1    0 };
  out = { 'gamt'   1    133   0  -9    0    232   0 -1    0 };
  out = { 'tn'    10    133   0  -9    0    232   0 -1  750 };
  out = { 'tsm'   10    133   0  -9    0    232   0 -1  750 };
  out = { 'sl'    10    133   0  -9    0    232   0 -1  750 };
  out = { 'svm'   10    133   0  -9    0    232   0 -1  750 };
  out = { 'psv'   10    133   0  -9    0    232   0 -1  750 };
  out = { 'trup'   1    133   0  -9  750    232   0 -1  750 };
  out = { 'x'      1      1   1  -1    0     -1  -1 -1    0 };
  out = { 'rho'    1      1   1  -2    0     -1  -1 -1    0 };
  out = { 'vp'     1      1   1  -2    0     -1  -1 -1    0 };
  out = { 'vs'     1      1   1  -2    0     -1  -1 -1    0 };
  out = { 'pv2'   20      1   1  -1    0     -1  -1 -1   -1 };
  out = { 'vm2'   20      1   1  -1    0     -1  -1 -1   -1 };
  out = { 'v' 1     42   97 -1 0     42   97 -1 -1 }; % Bakersfield
  out = { 'v' 1     51   35 -1 0     51   35 -1 -1 }; % Santa
  out = { 'v' 1     77   41 -1 0     77   41 -1 -1 }; % Oxnard
  out = { 'v' 1     96   97 -1 0     96   97 -1 -1 }; % Lancaster
  out = { 'v' 1    109   60 -1 0    109   60 -1 -1 }; % Westwood
  out = { 'v' 1    115   65 -1 0    115   65 -1 -1 }; % Los
  out = { 'v' 1    122   68 -1 0    122   68 -1 -1 }; % Montebello
  out = { 'v' 1    127   54 -1 0    127   54 -1 -1 }; % Long
  out = { 'v' 1    129  135 -1 0    129  135 -1 -1 }; % Barstow
  out = { 'v' 1    132  116 -1 0    132  116 -1 -1 }; % Victorville
  out = { 'v' 1    136   85 -1 0    136   85 -1 -1 }; % Ontario
  out = { 'v' 1    139   63 -1 0    139   63 -1 -1 }; % Santa
  out = { 'v' 1    147   97 -1 0    147   97 -1 -1 }; % San
  out = { 'v' 1    149   86 -1 0    149   86 -1 -1 }; % Riverside
  out = { 'v' 1    177   48 -1 0    177   48 -1 -1 }; % Oceanside
  out = { 'v' 1    185   95 -1 0    185   95 -1 -1 }; % Palm
  out = { 'v' 1    204   99 -1 0    204   99 -1 -1 }; % Coachella
  out = { 'v' 1    202   34 -1 0    202   34 -1 -1 }; % San
  out = { 'v' 1    252   16 -1 0    252   16 -1 -1 }; % Ensenada
  out = { 'v' 1    265   83 -1 0    265   83 -1 -1 }; % Mexicali
  out = { 'v' 1    292  114 -1 0    292  114 -1 -1 }; % Yuma
