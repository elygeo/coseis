% Time series
% input: vizfield sensor dofilter
% output: tg vg ta va
% search through outpur for desired timeseries data
% try to find analytica solution as well if known

clear tg xg vg va ta

% Read metadata if SORD not running
if ~exist( 'sordrunning', 'var' )
  cwd = pwd;
  cd 'out'
  defaults
  in
  meta
  faultmeta
  timestep
  cd( cwd )
  if ~exist( 'vizfield', 'var' ), vizfield = 'v'; end
  if ~exist( 'dofilter', 'var' ), dofilter = 1;   end
  if ~exist( 'sensor', 'var' ), sensor = [ 1 1 1 ]; end
end

iz = 0;
i1s = [ sensor 1 1 ];
i2s = [ sensor it 1 ];
extract4d
if msg, return, end
if ng(4) == 1, return, end

% Filter
if dofilter
  fcorner = vp / ( 8 * dx );
  n = 2 * round( 1 / ( fcorner * dt ) );
  b = .5 * ( 1 - cos( 2 * pi * ( 1 : n - 1 ) / n ) );  % hanning
  a  = sum( b );
  vg = filter( b, a, [ vg; zeros( n - 1, size( vg, 2 ) ) ] );
  tg = [ tg tg(end) + dt * ( 1 : n - 1 ) ];
end

% For moment source, rotate to r,h,v coords
if ~abs( faultnormal )
  if exist( 'sordrunning', 'var' )
    xg = xcursor - xhypo;
  else
    vfsave = vizfield;
    vgsave = vg;
    tgsave = tg;
    vizfield = 'x';
    timeseries
    if msg, return, error 'x file', end
    vizfield = vfsave;
    vg = vgsave;
    tg = tgsave;
    xg = vg - xhypo;
  end
  rg = sqrt( sum( xg .* xg ) );
  if ( xg(1) || xg(2) )
    rot = [ xg(1)  xg(2) xg(1)*xg(3)
            xg(2) -xg(1) xg(2)*xg(3)
            xg(3)     0 -xg(1)*xg(1)-xg(2)*xg(2) ];
    tmp = sqrt( sum( rot .* rot, 1 ) );
    for i = 1:3
      rot(i,:) = rot(i,:) ./ tmp;
    end
    vg = vg * rot;
  end
end

% Find analytical solution for known problems
haveanalytical = 1;
switch model
case 'explosion'
  haveanalytical = 1;
  tdom = tsource;
  c = [ 1 6 5; 6 2 4; 5 4 3 ];
  [ vec, val ] = eig( moment(c) );
  m0 = max( abs( val(:) ) );
  mw = 2. / 3. * log10( m0 ) - 10.7;
  d  = m0 / ( rho * vs * vs * dx * dx );
  switch timefcn
  case 'brune'
    va = m0 * exp( -tg / tdom ) .* ( tg * vp / rg - tg / tdom + 1 ) ...
       / ( 4. * pi * rho * vp * vp * tdom ^ 2 * rg * vp );
  case 'sbrune'
    va = m0 * exp( -tg / tdom ) .* ( tg * vp / rg - tg / tdom + 2 ) .* tg ...
       / ( 8. * pi * rho * vp * vp * tdom ^ 3 * rg * vp );
  otherwise va = 0;
  end
  ta = tg + rg / vp;
case 'kostrov'
  haveanalytical = 1;
  c = .81;
  dtau = ts0 - mud0 * tn0;
  va = c * dtau / rho / vs * ( tg + rg / vrup ) ...
     ./ sqrt( tg .* ( tg + 2 * rg / vrup ) );
  va = filter( b, a, vk );
  ta = tg + rg / vrup;
otherwise
  haveanalytical = 0;
  return
end

% Filter
if dofilter
  va = filter( b, a, [ va; zeros( n - 1, 1 ) ] );
end

