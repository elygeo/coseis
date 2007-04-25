% Time series
function [ msg, tt, vt, x, tta, vta, labels ] = tsread( varargin )

field  = varargin{1};
sensor = varargin{2};
dofilter = 0;
upvector = [ 0 0 1 ];
if nargin >= 3, dofilter = varargin{3}; end
if nargin >= 4, upvector = varargin{4}; end

tt = [];
tta = [];
vta = [];
labels = {};

% Read metadata
meta
currentstep

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

% Find sensor location
[ msg, x ] = read4d( 'x', [ sensor 0 ], [ sensor 0 ] );
x = squeeze( x )';
if msg
  pointsource = 0;
  explosion = 0;
  kostrov = 0;
else
  nr = x - xhypo;
  rg = sqrt( sum( nr .* nr ) );
  if rg, nr = nr / rg; end
end

% Time
if any( strcmp( field, { 'v' 'vm' 'sv' } ) )
  it0 = 1;
  tt = ( it0 : it ) * dt - .5 * dt;
else
  it0 = 1;
  tt = ( it0 : it ) * dt - dt;
end

% Extract data
[ msg, vt ] = read4d( field, [ sensor it0 ], [ sensor it ] );
if msg, return, end
if nargout < 2, return, end
msg = 'Time Series';

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

% Labels
labels = fieldlabels( field, pointsource );

