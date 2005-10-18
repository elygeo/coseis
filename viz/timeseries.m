% Time series
% input: vizfield sensor dofilter
% output: tg vg ta va labels
% search through outpur for desired timeseries data
% try to find analytica solution as well if known

clear tg xg rg vg va ta

% Read metadata if SORD not running
if ~exist( 'dofilter', 'var' ), dofilter = 0; end
cwd = pwd;
cd 'out'
defaults
in
meta
faultmeta
timestep
cd( cwd )

% Test for special cases
pointsource = ... 
  any( strcmp( vizfield, { 'a' 'v' 'u' } ) ) && ...
  ~faultnormal;
explosion = ...
  strcmp( vizfield, 'v' ) && ...
  ~faultnormal && ...
  all( moment2 == 0 ) && ...
  all( moment1 == moment1(1) );
kostrov = ...
  strcmp( vizfield, 'sv' ) && ...
  faultnormal && ...
  rcrit > 1e8 && ...
  trelax == 0.;

% Find sensor location if needed
vfsave = vizfield;
if pointsource || explosion || kostrov
  vizfield = 'x';
  i1s = [ sensor 0 ];
  i2s = [ sensor 0 ];
  ic = 0;
  get4dsection
  if msg
    fprintf( 'Warning: cannot locate sensor for analytical solution\n' )
    pointsource = 0;
    explosion = 0;
    kostrov = 0;
  else
    xg = squeeze( vg )' - xhypo;
    rg = sqrt( sum( xg .* xg ) );
  end
end

% Time
if any( strcmp( vfsave, { 'v' 'vm' 'sv' } ) )
  it0 = 1;
  tg = ( it0 : it ) * dt - .5 * dt;
else
  it0 = 0;
  tg = ( it0 : it ) * dt;
end

% Extract data
vizfield = vfsave;
i1s = [ sensor it0 ];
i2s = [ sensor it  ];
ic = 0;
get4dsection
if msg, return, end
vg = squeeze( vg );

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
      vg = vg * rot;
    case 6
      vg = [ ...
         vg([1 6 5]) * rot(:,1) ...
         vg([6 2 4]) * rot(:,2) ...
         vg([5 4 3]) * rot(:,3) ...
         vg([5 4 3]) * rot(:,2) ...
         vg([1 6 5]) * rot(:,3) ...
         vg([6 2 4]) * rot(:,1) ]'
    end
  end
end

% Filter
if dofilter
  fcorner = vp0 / ( 8 * dx );
  n = 2 * round( 1 / ( fcorner * dt ) );
  b = .5 * ( 1 - cos( 2 * pi * ( 1 : n - 1 ) / n ) );  % hanning
  a  = sum( b );
  vg = filter( b, a, vg );
end

% Find analytical solution for known cases
haveanalytical = explosion || kostrov;
if explosion
  m0 = moment1(1);
  tdom = tsource;
  switch timefcn
  case 'brune'
    va = m0 * exp( -tg / tdom ) .* ( tg * vp0 / rg - tg / tdom + 1 ) ...
       / ( 4. * pi * rho0 * vp0 ^ 3 * tdom ^ 2 * rg );
  case 'sbrune'
    va = m0 * exp( -tg / tdom ) .* ( tg * vp0 / rg - tg / tdom + 2 ) .* tg ...
       / ( 8. * pi * rho0 * vp0 ^ 3 * tdom ^ 3 * rg );
  otherwise va = 0;
  end
  if dofilter, va = filter( b, a, va ); end
  ta = tg + rg / vp0;
  i = ta <= tg(end);
  ta = ta(i);
  va = va(i);
elseif kostrov
  c = .81;
  dtau = ts0 - mud0 * tn0;
  va = c * dtau / rho0 / vs0 * ( tg + rg / vrup ) ...
     ./ sqrt( tg .* ( tg + 2 * rg / vrup ) );
  if dofilter, va = filter( b, a, va ); end
  ta = tg + rg / vrup;
  i = ta <= tg(end);
  ta = ta(i);
  va = va(i);
end

% Labels
switch vizfield
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
otherwise error 'vizfield'
end

if pointsource
  switch vizfield
  case 'x',   labels = { 'Position'     'r' 'h' 'v' };
  case 'a',   labels = { 'Acceleration' 'Ar' 'Ah' 'Av' };
  case 'v',   labels = { 'Velocity'     'Vr' 'Vh' 'Vv' };
  case 'u',   labels = { 'Displacement' 'Ur' 'Uh' 'Uv' };
  case 'w',   labels = { 'Stress' 'Wrr' 'Whh' 'Wvv' 'Whv' 'Wvr' 'Wrh' };
  end
end

