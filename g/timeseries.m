% Time series
% input: field icursor dofilter
% output: tt vt ta va labels
% search through outpur for desired timeseries data
% try to find analytica solution as well if known

clear xg rg tt vt ta va

% Read metadata if SORD not running
if ~exist( 'dofilter', 'var' ), dofilter = 0; end
cd 'out'
defaults
in
meta
faultmeta
currentstep
cd '..'

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

% Find sensor location if needed
vfsave = field;
if pointsource || explosion || kostrov
  [ xsensor, msg ] = read4d( 'x', [ sensor 0 ], [ sensor 0 ], 0 );
  if msg
    fprintf( 'Warning: cannot locate sensor for analytical solution\n' )
    pointsource = 0;
    explosion = 0;
    kostrov = 0;
  else
    xg = squeeze( xsensor )' - xhypo;
    rg = sqrt( sum( xg .* xg ) );
  end
end

% Time
if any( strcmp( vfsave, { 'v' 'vm' 'sv' } ) )
  it0 = 1;
  tt = ( it0 : it ) * dt - .5 * dt;
else
  it0 = 0;
  tt = ( it0 : it ) * dt;
end

% Extract data
[ vt, msg ] = read4d( field, [ sensor it0 ], [ sensor it ], 0 );
if msg, return, end
vt = squeeze( vt );

% For point source, rotate to r,h,v coords
if pointsource
  if ( xg(1) || xg(2) )
    rot = [ xg(1)  xg(2) xg(1)*xg(3)
            xg(2) -xg(1) xg(2)*xg(3)
            xg(3)     0 -xg(1)*xg(1)-xg(2)*xg(2) ];
    tmp = sqrt( sum( rot .* rot, 1 ) );
    for i = 1:3
      rot(i,:) = rot(i,:) ./ tmp;
    end
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
         vt([6 2 4]) * rot(:,1) ]'
    end
  end
end

% Filter
if dofilter
  fcorner = vp0 / ( 8 * dx );
  n = 2 * round( 1 / ( fcorner * dt ) );
  b = .5 * ( 1 - cos( 2 * pi * ( 1 : n - 1 ) / n ) );  % hanning
  a  = sum( b );
  vt = filter( b, a, vt );
end

% Find analytical solution for known cases
haveanalytical = explosion || kostrov;
if explosion
  m0 = moment1(1);
  tdom = tsource;
  switch timefcn
  case 'brune'
    va = m0 * exp( -tt / tdom ) .* ( tt * vp0 / rg - tt / tdom + 1 ) ...
       / ( 4. * pi * rho0 * vp0 ^ 3 * tdom ^ 2 * rg );
  case 'sbrune'
    va = m0 * exp( -tt / tdom ) .* ( tt * vp0 / rg - tt / tdom + 2 ) .* tt ...
       / ( 8. * pi * rho0 * vp0 ^ 3 * tdom ^ 3 * rg );
  otherwise va = 0;
  end
  if dofilter, va = filter( b, a, va ); end
  ta = tt + rg / vp0;
  i = ta <= tt(end);
  ta = ta(i);
  va = va(i);
elseif kostrov
  c = .81;
  dtau = ts0 - mud0 * tn0;
  va = c * dtau / rho0 / vs0 * ( tt + rg / vrup ) ...
     ./ sqrt( tt .* ( tt + 2 * rg / vrup ) );
  if dofilter, va = filter( b, a, va ); end
  ta = tt + rg / vrup;
  i = ta <= tt(end);
  ta = ta(i);
  va = va(i);
end

% Labels
switch field
case 'x',    labels = { 'Position'        'x' 'y' 'z' };
case 'a',    labels = { 'Acceleration'    'Ax' 'Ay' 'Az' };
case 'v',    labels = { 'Velocity'        'Vx' 'Vy' 'Vz' };
case 'u',    labels = { 'Displacement'    'Ux' 'Uy' 'Uz' };
case 'w',    labels = { 'Stress'          'Wxx' 'Wyy' 'Wzz' 'Wyz' 'Wzx' 'Wxy' };
case 'am',   labels = { 'Acceleration'    '|A|' };
case 'vm',   labels = { 'cceleration'     '|V|' };
case 'um',   labels = { 'Displacement'    '|U|' };
case 'wm',   labels = { 'Stress'          '|W|' };
case 'sv',   labels = { 'Slip Velocity'   'Vslip' };
case 'sl',   labels = { 'Slip Length'     'lslip' };
case 'tn',   labels = { 'Normal Traction' 'Tn' };
case 'ts',   labels = { 'Shear Traction'  'Ts' };
case 'trup', labels = { 'Rupture Time'    'trup' };
case 'tarr', labels = { 'Arrest Time'     'tarr' };
otherwise error 'field'
end

if pointsource
  switch field
  case 'x',  labels = { 'Position'     'r' 'h' 'v' };
  case 'a',  labels = { 'Acceleration' 'Ar' 'Ah' 'Av' };
  case 'v',  labels = { 'Velocity'     'Vr' 'Vh' 'Vv' };
  case 'u',  labels = { 'Displacement' 'Ur' 'Uh' 'Uv' };
  case 'w',  labels = { 'Stress' 'Wrr' 'Whh' 'Wvv' 'Whv' 'Wvr' 'Wrh' };
  end
end

