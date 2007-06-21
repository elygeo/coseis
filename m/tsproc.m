% Process time series
function [ tt, vt, tta, vta ] = tsproc( varargin )

meta
x = [];
tt = [];
tta = [];
vta = [];
field = [];
dofilter = 0;
upvector = [ 0 0 1 ];
vt = varargin{1};
if nargin >= 2, x        = varargin{2}; end
if nargin >= 3, field    = varargin{3}; end
if nargin >= 4, dofilter = varargin{4}; end
if nargin >= 5, upvector = varargin{5}; end

% Test for special cases
pointsource = ... 
  any( strcmp( field, { 'a' 'v' 'u' } ) ) && ...
  ~faultnormal;
explosion = ...
  strcmp( field, 'v' ) && ...
  ~faultnormal && ...
  all( moment2 == 0 ) && ...
  all( moment1 == moment1(1) );
kostrov = ...
  strcmp( field, 'sv' ) && ...
  faultnormal && ...
  rcrit > 1e8 && ...
  trelax == 0.;

% Sensor radius
if x
  nr = x - xhypo;
  rg = sqrt( sum( nr .* nr ) );
  if rg, nr = nr / rg; end
else
  pointsource = 0;
  explosion = 0;
  kostrov = 0;
end

% Time
if any( strcmp( field, { 'v' 'vm' 'sv' } ) )
  it0 = 1;
  tt = ( it0 : it ) * dt - .5 * dt;
else
  it0 = 0;
  tt = ( it0 : it ) * dt;
end
nt = it - it0 + 1;
nc = size( vt, 5 );
vt = reshape( vt, nt, nc );

% For point source, rotate to r,h,v coords
if pointsource
  nh = cross( upvector, nr );
  if all( ~nh ), nh = cross( [ 1 0 0 ], nr ); end
  if all( ~nh ), nh = cross( [ 0 1 0 ], nr ); end
  nh = nh / sqrt( sum( nh .* nh ) );
  nv = cross( nr, nh );
  nv = nv / sqrt( sum( nv .* nv ) );
  rot = [ nr(:) nh(:) nv(:) ];
  switch nc
  case 3
    vt = vt * rot;
  case 6
    vt = [ ...
       vt([1 6 5]) * rot(:,1) ...
       vt([6 2 4]) * rot(:,2) ...
       vt([5 4 3]) * rot(:,3) ...
       vt([5 4 3]) * rot(:,2) ...
       vt([1 6 5]) * rot(:,3) ...
       vt([6 2 4]) * rot(:,1) ]';
  end
end

% Filter
if dofilter
  fcorner = vp0 / ( dofilter * 8 * dx )
  n = 2 * round( 1 / ( fcorner * dt ) );
  b = .5 * ( 1 - cos( 2 * pi * ( 1 : n - 1 ) / n ) );  % hanning
  a  = sum( b );
  vt = filter( b, a, vt );
end

% Find analytical solution for known cases
if explosion && rg
  m0 = moment1(1);
  tdom = tsource;
  switch tfunc
  case 'brune'
    vta = m0 * exp( -tt / tdom ) .* ( tt * vp0 / rg - tt / tdom + 1 ) ...
       / ( 4. * pi * rho0 * vp0 ^ 3 * tdom ^ 2 * rg );
  case 'sbrune'
    vta = m0 * exp( -tt / tdom ) .* ( tt * vp0 / rg - tt / tdom + 2 ) .* tt ...
       / ( 8. * pi * rho0 * vp0 ^ 3 * tdom ^ 3 * rg );
  otherwise, vta = 0;
  end
  if dofilter, vta = filter( b, a, vta ); end
  tta = tt + rg / vp0;
  i = tta <= tt(end);
  tta = tta(i);
  vta = vta(i);
elseif kostrov
  c = .81;
  dtau = ts0 - mud0 * tn0;
  vta = c * dtau / rho0 / vs0 * ( tt + rg / vrup ) ...
     ./ sqrt( tt .* ( tt + 2 * rg / vrup ) );
  if dofilter, vta = filter( b, a, vta ); end
  tta = tt + rg / vrup;
  i = tta <= tt(end);
  tta = tta(i);
  vta = vta(i);
end

