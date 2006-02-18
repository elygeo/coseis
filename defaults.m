% SORD Defaults

% Wave model parameters
  nn = [ 41 41 42 ];			% nx ny nz double nodes counted
  nt = 40;				% number of time steps
  dx = 100.;				% spatial step length
  dt = .0075;				% time step length
  grid = 'constant';			% regular mesh
  gridtrans = [ 1. 0. 0.; 0. 1. 0.; 0. 0. 1. ] / 1.; % grid tranformation
  gridnoise = 0.			% Random noise added to mesh
% upvector = [ 0 0 1 ];			% positive z up
  upvector = [ 0 -1 0 ];		% negative y up
  rho = 2670.;				% **density
  vp  = 6000.;				% **P-wave speed
  vs  = 3464.1016;			% **S-wave speed
% lock = [ 1 1 0   1 1 1  -1 -1 -1 ];	% **lock v1 & v2, v3 is free
  viscosity = [ .0 .3 ];		% stress (1) & hourglass (2)
  viscosity = [ .1 .7 ];		% stress (1) & hourglass (2)
% npml = 0;				% no PML absorbing boundary
  npml = 10;				% 10 PML nodes
  bc1 = [ 0 0 0 ];			% j1 k1 l1 boundary cond
  bc2 = [ 0 0 0 ];			% j2 k2 l2 boundary cond
  ihypo	 = [ 0 0 0 ];			% hypocenter node
  xhypo	 = [ -1. -1. -1. ];		% hypocenter location
  rexpand = 1.06;			% grid expansion ratio
  n1expand = [ 0 0 0 ];			% n grid expansion nodes for j1 k1 l1
  n2expand = [ 0 0 0 ];			% n grid expansion nodes for j2 k2 l2

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
  mus = .6;				% **coef of static friction
  mud = .5;				% **coef of dynamic friction
  dc  = .25;				% **slip-weakening distance
  co  = 0.;				% **cohesion
  tn  = -120e6;				% **normal pretraction
  th  = -70e6;				% **horizontal (strike) pretraction
  td  = 0.;				% **dip pretraction
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
  debug = 0;                            % debugging off
% out = { 'v'  10   1 1 1  -1 -1 -1 };	% **write v every 10 steps
% out = { 'sl' -1   1 1 1  -1 -1 -1 };	% **write final slip length

% **optional zone argument, zones accumulate when specified multiple times
%   'zone' j1 k1 l1   j2 k2 l2
%   negative indices count inward from nn
%   an index of zero is replaced by the hypocenter index

