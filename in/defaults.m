% SORD Defaults

% Wave model parameters
  nn = [ 41 41 42 ];		% nx ny nz double nodes counted
  nt = 40;			% number of time steps
  dx = 100.;			% spatial step length
  dt = .0075;			% time step length
  grid = 'rect';		% rectangular mesh
% grid = 'read';		% read mesh from files 'data/x1', 'data/x2', and 'data/x3'
  affine = [ 1. 0. 0.   0. 1. 0.   0. 0. 1. ]; % grid transformation
  gridnoise = 0.		% Random noise added to mesh
  oplevel = 0;			% 1=const, 2=rect, 3=parallel, 3=onepoint, 5=exact, 6=saved, 0=auto pick 2 or 6
  rho = 2670.;			% **density
  vp = 6000.;			% **P-wave speed
  vs = 3464.1016;		% **S-wave speed
% gam = 0.;			% **viscosity
  vdamp = -1.;			% Vs dependent damping
  hourglass = [ 1. 1. ];	% hourglass stiffness (1) and viscosity (2)
  rho1 = -1.;			% min density
  rho2 = -1.;			% max density
  vp1 = -1.;			% min P-wave speed
  vp2 = -1.;			% max P-wave speed
  vs1 = -1.;			% min S-wave speed
  vs2 = -1.;			% max S-wave speed
  gam1 = -1.;			% min viscosity
  gam2 = .8;			% max viscosity
% npml = 0;			% no PML absorbing boundary
  npml = 10;			% 10 PML nodes
  bc1 = [ 0 0 0 ];		% j1 k1 l1 boundary cond (see below)
  bc2 = [ 0 0 0 ];		% j2 k2 l2 boundary cond (see below)
  ihypo	 = [ 0 0 0 ];		% hypocenter node
  xhypo	 = [ 0. 0. 0. ];	% hypocenter location
  fixhypo = 1;			% 0=none 1=inode, 2=icell, -1=xnode, -2=xcell
  rexpand = 1.06;		% grid expansion ratio
  n1expand = [ 0 0 0 ];		% n grid expansion nodes for j1 k1 l1
  n2expand = [ 0 0 0 ];		% n grid expansion nodes for j2 k2 l2

% Moment source parameters
% rfunc = 'box';		% spatial weighting: uniform
% rfunc = 'tent';		% spatial weighting: tapered
  rfunc = 'point';		% point source
% tfunc = 'delta';		% source time function: delta
% tfunc = 'brune';		% source time function: Brune
  tfunc = 'sbrune';		% source time function: smooth Brune
% rsource = 150.;		% source radius: 1.5*dx = 8 nodes
  rsource = -1.;		% no moment source
  tsource = .056;		% dominant period of 8*dt
  moment1 = [ 1e16 1e16 1e16 ];	% normal components, explosion source
  moment2 = [ 0. 0. 0. ];       % shear components

% Fault parameters;
% faultnormal = 0;		% no fault
  faultnormal = 3;		% constant l fault plane
  faultopening = 0;		% 0=not allowed, 1=allowed
  slipvector = [ 1. 0. 0. ];	% shear traction direction for ts1
  mus = .6;			% **coef of static friction
  mud = .5;			% **coef of dynamic friction
  dc  = .4;			% **slip-weakening distance
% co  = 0.;			% **cohesion
  ts1 = -70e6;			% **shear traction component 1
% ts2 = 0.;			% **shear traction component 2
  tn  = -120e6;			% **normal traction
% sxx = 0.;			% **prestress Sxx
% syy = 0.;			% **prestress Syy
% szz = 0.;			% **prestress Szz
% syz = 0.;			% **prestress Syz
% szx = 0.;			% **prestress Szx
% sxy = 0.;			% **prestress Sxy
  vrup = 3117.6914;		% nucleation rupture velocity
  rcrit = 1000.;		% nucleation critical radius
  trelax = .07;			% nucleation relaxation time
  svtol = .001;			% slip velocity considered rupturing

% Code execution and output parameters
  np = [ 1 1 1 ];		% number of processors in j k l
  itstats = 4;			% calculate statistics every 4
  itio =   32;			% empty buffers every 32
  itcheck = 0;			% checkpointing off
% itcheck = 1000;		% checkpoint every 1000 time steps
% itcheck = -1;			% checkpoint just before finishing
  itstop = 0;			% for testing, leave at 0
  debug = 0;                    % debugging off
  mpin  = 1;			% 0=separate files, 1=MPIIO
  mpout = 1;			% 0=separate files, 1=MPIIO
% out = { 'v'  10   1 1 1 1   -1 -1 -1 -1 };	% write v every 10 steps, 4D zone
% out = { 'sl' -1   1 1 1 1   -1 -1 -1 -1 };	% write final slip length, 4D zone

% Boundary conditions:
%  0: Vacuum free surface: zero cell stress
%  1: Mirror symmetry at the node
%  2: Mirror symmetry at the cell
% -1: Anti-mirror symmetry at the node, useful for nodal planes
% -2: Anti-mirror symmetry at the cell, useful for nodal planes and fault planes
%  3: Rigid boundary: zero node displacement
%  4: Continue
% 10: PML absorbing

% **optional 3D region argument: 'zone', 'cube', or 'read'
%   when not specified, defaults to the entire volume
%   'zone' j1 k1 l1   j2 k2 l2
%     specifies region node indices
%     negative indices count inward from nn
%     an index of zero is replaced by the hypocenter index
%   'cube' x1 y1 z1   x2 y2 z2
%     specifies cuboid physical region
%   'read'
%     read from disk file in the directory 'data'
%     optional 'zone' argument

