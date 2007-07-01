% Boundary condition test
  out = { 'x'   1  1 1 1 1   2 2 2 -1 };
  out = { 'rho' 1  1 1 1 1   2 2 2 -1 };
  out = { 'vp'  1  1 1 1 1   2 2 2 -1 };
  out = { 'vs'  1  1 1 1 1   2 2 2 -1 };
  out = { 'gam' 1  1 1 1 1   2 2 2 -1 };
  out = { 'u'   1  1 1 1 1   2 2 2 -1 };
  out = { 'v'   1  1 1 1 1   2 2 2 -1 };
  out = { 'a'   1  1 1 1 1   2 2 2 -1 };
  out = { 'su'  1  1 1 1 1   2 2 2 -1 };
  out = { 'sv'  1  1 1 1 1   2 2 2 -1 };
  out = { 'sa'  1  1 1 1 1   2 2 2 -1 };
  np = [ 1 1 1 ];
  debug = 3;
  nt = 8;
  itstats = 1;
  hourglass = [ 1. 4. ];
  tsource = .1;
  tfunc = 'brune';
  slipvector = [ 1. 0. 0. ];
  mus = .6;
  mud = .5;
  dc  = .4;
  ts1 = -70e6;
  tn  = -120e6;
  bc1 = [ 0 0 0 ];

% Test 3 and -3 with fault
  faultnormal = 3;
  rsource = -1.;
  ihypo = [ 3 3 2 ];
  fixhypo = -1;
  nn = [ 5 5 4 ]; bc2 = [  0 0  0 ];
  nn = [ 3 3 3 ]; bc2 = [ -3 3 -2 ];
return

% Test 2 and -2 with fault
  ihypo = [ 2 2 2 ];
  fixhypo = -2;
  faultnormal = 3;
  rsource = -1.;
  nn = [ 4 4 3 ]; bc2 = [ 0 0 0 ];
  nn = [ 4 4 4 ]; bc2 = [ 0 0 0 ];
  nn = [ 3 3 3 ]; bc2 = [ -2 2 -2 ];
return

% Test 3 and -3
  ihypo = [ 3 3 3 ];
  fixhypo = -1;
  faultnormal = 0;
  rsource = 100.;
  moment1 = [ 0. 0. 0. ];
  nn = [ 5 5 5 ]; bc2 = [  0  0 0 ]; moment2 = [ 0. 0. 8e18 ];
  nn = [ 3 3 3 ]; bc2 = [ -3 -3 3 ]; moment2 = [ 0. 0. 1e18 ];
return

% Test 3
  ihypo = [ 3 3 3 ];
  fixhypo = -1;
  faultnormal = 0;
  rsource = 100.;
  moment2 = [ 0. 0. 0. ];
  nn = [ 5 5 5 ]; bc2 = [ 0 0 0 ]; moment1 = [ 8e18 8e18 8e18 ];
  nn = [ 3 3 3 ]; bc2 = [ 3 3 3 ]; moment1 = [ 1e18 1e18 1e18 ];
return

% Test 2
  ihypo = [ 2 2 2 ];
  fixhypo = -2;
  faultnormal = 0;
  rsource = 50.;
  moment1 = [ 1e18 1e18 1e18 ];
  moment2 = [ 0. 0. 0. ];
  nn = [ 3 3 3 ]; bc2 = [ 2 2 2 ];
  nn = [ 4 4 4 ]; bc2 = [ 0 0 0 ];
return

% Test 2 and -2
  ihypo = [ 2 2 2 ];
  fixhypo = -2;
  faultnormal = 0;
  rsource = 50.;
  moment1 = [ 0. 0. 0. ];
  moment2 = [ 0. 0. 1e18 ];
  nn = [ 4 4 4 ]; bc2 = [ 0 0 0 ];
  nn = [ 3 3 3 ]; bc2 = [ -2 -2 2 ];
return

