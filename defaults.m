%------------------------------------------------------------------------------%
% SORD Defaults

% Wave model parameters
  model = 'defaults';			% model ID
  nn = [ 41 41 42 ];			% nx ny nz double nodes counted
  nt = 40;				% number of time steps
  dx = 100.;				% spatial step length
  dt = .007;				% time step length
% grid = 'slant';			% skewed mesh
% grid = 'read';			% read files: data/x1 data/x2 data/x3
  grid = 'constant';			% regular mesh
% upvector = [ 0 0 1 ];			% positive z up
  upvector = [ 0 -1 0 ];		% negative y up
  rho = 2670.;				% **density
  vp  = 6000.;				% **P-wave speed
  vs  = 3464.1016;			% **S-wave speed
% vp   = [ 600.    1 1 1  10 -1 -1 ];	% **low velocity surface layer
% vs   = [ 346.    1 1 1  10 -1 -1 ];	% **low velocity surface layer
% lock = [ 1 1 0   1 1 1  -1 -1 -1 ];	% **lock v1 & v2, v3 is free
  viscosity = [ .0 .3 ];		% stress (1) & hourglass (2)
% npml = 0;				% no PML absorbing boundary
  npml = 10;				% 10 PML nodes
% bc = [ 1 1 1   1 1 1 ];		% PML absorbing on all sides
% bc = [ 1 1 1   1 1 0 ];		% free surface at l=nz
  bc = [ 1 0 1   1 1 1 ];		% free surface at k=1
  ihypo	 = [ 0 0 0 ];			% 0: mesh center
  xhypo	 = [ -1. -1. -1. ];		% <0: x(ihypo)

% Moment source parameters
% rfunc = 'box';			% uniform spatial weighting
  rfunc = 'tent';			% tapered spatial weighting
% tfunc = 'delta';			% impulse time function
% tfunc = 'sbrune';			% smooth Brune time fn
  tfunc = 'brune';			% Brune source time function
% rsource = 150.;			% source radius, 1.5*dt = 8 nodes
  rsource = -1.;			% no moment source
  tsource = .056;			% dominant period of 8*dt
  moment = [ 1e16 1e16 1e16 0. 0. 0. ]; % explosion source

% Fault parameters;
% faultnormal = 0;			% no fault
% faultnormal = 2;			% constant k fault plane
  faultnormal = 3;			% constant l fault plane
  mus = .6;				% **coef of static friction
  mud = .5;				% **coef of dynamic friction
  dc  = .25;				% **slip-weakening distance
  co  = 0.;				% **cohesion
  tn  = -70e6;				% **normal pretraction
  th  = -120e6;				% **horizontal (strike) pretraction
  td  = 0.;				% **dip pretraction
% sxx = 0.;				% **prestress Sxx
% syy = 0.;				% **prestress Syy
% szz = 0.;				% **prestress Szz
% syz = 0.;				% **prestress Syz
% szx = 0.;				% **prestress Szx
% sxy = 0.;				% **prestress Sxy
  vrup = 3117.6914;			% nucleation rupture velocity
  rcrit = 1000.;			% nucleation critical radius
  trelax = .07;				% nucleation relaxation time

% Code execution and output parameters
% np = [ 2 1 3 ];			% 6 processors
  np = [ 1 1 1 ];			% no parallelization
% itcheck = 0;				% no checkpointing
% itcheck = 100;			% checkpoint every 100 time steps
  itcheck = -1;				% checkpoint just before finishing
% out = { 'v'  10   1 1 1  -1 -1 -1 };	% **write v every 10 steps
% out = { 'sl' -1   1 1 1  -1 -1 -1 };	% **write final slip length

% **optional zone argument, zones accumulate when specified multiple times
%   zone = j1 k1 l1   j2 k2 l2
%   negative indices count inward from nn
%   an index of zero is replaced by the hypocenter index

