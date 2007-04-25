% SORD Defaults

% Wave model parameters
  nn = [ 41 41 42 ];			% nx ny nz double nodes counted
  nt = 40;				% number of time steps
  dx = 100.;				% spatial step length
  dt = .0075;				% time step length
  grid = 'constant';			% regular mesh
  affine = [ 1. 0. 0.  0. 1. 0.  0. 0. 1.  1. ]; % grid tranformation
  symmetry = [ 0 0 0 ];			% grid symmetry
  gridnoise = 0.			% Random noise added to mesh
  oplevel = 0;				% 1=const, 2=rect, 3=parallel, 3=onepoint, 5=exact, 6=saved, 0=auto pick 2 or 6
  rho = 2670.;				% **density
  vp = 6000.;				% **P-wave speed
  vs = 3464.1016;			% **S-wave speed
  rho1 = 0.;				% min density
  rho2 = 1e9;				% max density
  vp1 = 0.;				% min P-wave speed
  vp2 = 1e9;				% max P-wave speed
  vs1 = 0.;				% min S-wave speed
  vs2 = 1e9;				% max S-wave speed
  gam = .0;				% viscosity
  vdamp = -1.;				% Vs dependent damping
  hourglass = [ 1. 1. ];		% hourglass stiffness (1) and viscosity (2)
% npml = 0;				% no PML absorbing boundary
  npml = 10;				% 10 PML nodes
  bc1 = [ 0 0 0 ];			% j1 k1 l1 boundary cond (see below)
  bc2 = [ 0 0 0 ];			% j2 k2 l2 boundary cond (see below)
  ihypo	 = [ 0 0 0 ];			% hypocenter node
  xhypo	 = [ 0. 0. 0. ];		% hypocenter location
  fixhypo = 1;				% 0=none 1=inode, 2=icell, -1=xnode, -2=xcell
  rexpand = 1.06;			% grid expansion ratio
  n1expand = [ 0 0 0 ];			% n grid expansion nodes for j1 k1 l1
  n2expand = [ 0 0 0 ];			% n grid expansion nodes for j2 k2 l2
% lock = [ 1 1 0   1 1 1  -1 -1 -1 ];	% **lock v1 & v2, v3 is free

% Moment source parameters
% rfunc = 'box';			% spatial weighting: uniform
  rfunc = 'tent';			% spatial weighting: tapered
% tfunc = 'delta';			% source time function: delta
% tfunc = 'brune';			% source time function: Brune
  tfunc = 'sbrune';			% source time function: smooth Brune
% rsource = 150.;			% source radius: 1.5*dx = 8 nodes
  rsource = -1.;			% no moment source
  tsource = .056;			% dominant period of 8*dt
  moment1 = [ 1e16 1e16 1e16 ];         % normal components, explosion source
  moment2 = [ 0. 0. 0. ];               % shear components

% Fault parameters;
% faultnormal = 0;			% no fault
  faultnormal = 3;			% constant l fault plane
  slipvector = [ 1. 0. 0. ];		% shear traction direction for ts1
  mus = .6;				% **coef of static friction
  mud = .5;				% **coef of dynamic friction
  dc  = .25;				% **slip-weakening distance
  co  = 0.;				% **cohesion
  ts1 = -70e6;				% **shear traction component 1
  ts2 = 0.;				% **shear traction component 2
  tn  = -120e6;				% **normal traction
  sxx = 0.;				% **prestress Sxx
  syy = 0.;				% **prestress Syy
  szz = 0.;				% **prestress Szz
  syz = 0.;				% **prestress Syz
  szx = 0.;				% **prestress Szx
  sxy = 0.;				% **prestress Sxy
  vrup = 3117.6914;			% nucleation rupture velocity
  rcrit = 1000.;			% nucleation critical radius
  trelax = .07;				% nucleation relaxation time
  svtol = .001;				% slip velocity considered rupturing

% Code execution and output parameters
  np = [ 1 1 1 ];			% number of processors in j k l
% itcheck = 100;			% checkpoint every 100 time steps
% itcheck = -1;				% checkpoint just before finishing
  itcheck = 0;				% checkpointing off
  itstats = 10;				% write statistic every 10 time steps
  debug = 0;                            % debugging off
% out = { 'v'  10   1 1 1 1  -1 -1 -1 -1 };	% write v every 10 steps, 4D zone
% out = { 'sl' -1   1 1 1 1  -1 -1 -1 -1 };	% write final slip length, 4D zone

% Boundary conditions:
%  0: free surface
%  1: PML absorbing
%  2: mirror symmetry on exterior cell center
%     continuous tangential and oposing normal vecotor components
%  3: mirror symmetry on boundary node
%     continuous tangential and oposing normal vecotor components
% -2: mirror symmetry on exterior cell center, 180 phase shift
%     continuous normal and oposing tangential vecotor components
% -3: mirror symmetry on boundary node, 180 phase shift
%     continuous normal and oposing tangential vecotor components
%  4: continuation
%  9: domain boundary (for internal use only)

% **optional 3D zone argument, zones accumulate when specified multiple times
%   'zone' j1 k1 l1   j2 k2 l2
%   negative indices count inward from nn
%   an index of zero is replaced by the hypocenter index

