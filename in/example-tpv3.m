% TPV3 - SCEC validation problem version 3 with sheared mesh

  np  = [ 1 1 32 ];		% number of processors in each dimension
  nn  = [ 351 201 128 ];	% number of mesh nodes, nx ny nz
  nt  = 3000;			% number of time steps
  dx  = 50.;			% spatial step size
  dt  = 0.004;			% time step size

  bc1      = [ 10 10 10 ];
  bc2      = [ -2  2 -2 ];


% Material properties
  rho = 2670.;			% density
  vp  = 6000.;			% P-wave speed
  vs  = 3464.;			% S-wave speed
  gam = .2;			% viscosity
  gam = { .02 'cube' -15001. -7501. -4000.   15001. 7501. 4000. };
  hourglass = [ 1. 2. ];

% Fault parameters
  faultnormal = 3;
  ihypo    = [ -2 -2 -2 ];
  fixhypo  =  -2;
  vrup = -1.;
  dc  = 0.4;
  mud = 0.525;
  mus = 10000.;
  mus = { 0.677   'cube' -15001. -7501. -1.  15001. 7501. 1. };
  tn  = -120e6;
  ts1 = 70e6;
  ts1 = { 81.6e6 'cube'  -1501. -1501. -1.   1501. 1501. 1. };

% Fault plane output
  out = { 'x'     1   1  1 -2  0   -1 -1 -2  0 }; % Mesh coordinates
  out = { 'tsm'  -1   1  1  0  0   -1 -1  0 -1 }; % Shear traction
  out = { 'tn'    1   1  1  0 -1   -1 -1  0 -1 }; % Normal traction
  out = { 'su'    1   1  1  0 -1   -1 -1  0 -1 }; % Slip
  out = { 'psv'   1   1  1  0 -1   -1 -1  0 -1 }; % Peak slip velocity
  out = { 'trup'  1   1  1  0 -1   -1 -1  0 -1 }; % Rupture time

% Time series output
  timeseries = { 'su' -7499.    -1. 0. };
  timeseries = { 'sv' -7499.    -1. 0. };
  timeseries = { 'ts' -7499.    -1. 0. };
  timeseries = { 'su'    -1. -5999. 0. };
  timeseries = { 'sv'    -1. -5999. 0. };
  timeseries = { 'ts'    -1. -5999. 0. };
  timeseries = { 'su'  7499.     1. 0. };
  timeseries = { 'sv'  7499.     1. 0. };
  timeseries = { 'ts'  7499.     1. 0. };
  timeseries = { 'su'     1.  5999. 0. };
  timeseries = { 'sv'     1.  5999. 0. };
  timeseries = { 'ts'     1.  5999. 0. };
