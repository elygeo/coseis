%------------------------------------------------------------------------------%
% TIMESERIES

% test if running from SORD
if ~exist( 'w1', 'var' )
  addpath m
  copyfile( [ outdir 'in' ], 'in' )
  readin
  nn = n(1:3);
  noff = [ 0 0 0 ];
  it = textread( [ outdir 'timestep' ] );
  x0 = textread( [ outdir 'x0' ], '%f', 3 )';
  endian = textread( [ outdir 'endian' ], '%c', 1 );
end

explosion = 0;
msg = 'no time series data at this location';
iz = 0;

% test if we have data saved for desired location
while iz < size( outvar, 1 )
  iz = iz + 1;
  [ i1, i2 ] = zone( iout(iz,:), nn, noff, i0, inrm );
  if strcmp( outvar{iz}, field ) & all( ixhair >= i1 & ixhair <= i2 ) & outit(iz) == 1
    msg = '';
    break
  end
end
if msg, return, end
if isfault, i2(inrm) = i1(inrm); end

% read timeseries
n = i2 - i1 + 1;
i = ixhair - i1;
gnoff = 4 * sum( i .* cumprod( [ 1 n(1:2) ] ) );
if strcmp( field, 'x' ), nit = 1; else nit = it; end
clear vg
for i = 1:ncomp
for itt = 1:nit
  file = sprintf( [ outdir '%02d/%s%1d%06d' ], iz, outvar{iz}, i, itt );
  fid = fopen( file, 'r', endian );
  fseek( fid, gnoff, -1 );
  vg(itt,i) = fread( fid, 1, 'float32' );
  fclose( fid );
end
end

if nit == 1
  msg = 'sting step read';
  return
end

vg = [ zeros(1,ncomp); vg ];

switch field
case 'v', time = ( 0 : it ) * dt + dt / 2;
otherwise time = ( 0 : it ) * dt;
end
tg = time;

% filter
if dofilter
  fcorner = 6000 / ( 6 * dx );
  n = 2 * round( 1 / ( fcorner * dt ) );
  b = .5 * ( 1 - cos( 2 * pi * ( 1 : n - 1 ) / n ) );  % hanning
  %b = [ b b(end-1:-1:1) ];
  a  = sum( b );
  vg = filter( b, a, [ vg; zeros( n - 1, size( vg, 2 ) ) ] );
  time = [ time time(end) + dt * ( 1 : n - 1 ) ];
end

% test for explosion source
explosion = ...
  all( moment(1:3) == moment(1) )  & ...
  all( moment(4:6) == 0. ) & ...
  rsource > 0. & ...
  inrm == 0;

% for explosion source, rotate to r,h,v coords and find analytica solution
tstitles = titles;
if explosion & strcmp( field, 'v' )
  tstitles = { '|V|' 'Vr' 'Vh' 'Vv' };
  if exist( 'w1', 'var' )
    xg = xxhair - x0;
  else
    field = 'x';
    timeseries
    if msg, return, error 'x file', end
    field = 'v';
    xg = vg - x0;
  end
  rho0 = material(end,1);
  vp0 = material(end,2);
  rg = sqrt( sum( xg .* xg ) );
  tg = time;
  tg = tg - rg / vp0;
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
  vk = zeros( it+1, 1 );
  i = find( tg > 0 );
  switch sourcetimefcn
  case 'brune'
    vk(i,1) = moment(1) / 4 / pi / rho0 / vp0 ^ 2 / domp ^ 2 / rg / vp0 * ...
    exp( -tg(i) / domp ) .* ( tg(i) * vp0 / rg - tg(i) / domp + 1 );
  case 'sbrune'
    vk(i,1) = moment(1) / 8 / pi / rho0 / vp0 ^ 2 / domp ^ 3 / rg / vp0 * ...
    exp( -tg(i) / domp ) .* ( tg(i) * vp0 / rg - tg(i) / domp + 2 ) .* tg(i);
  otherwise error 'sourcetimefcn'
  end
  if dofilter
    vk = filter( b, a, [ vk; zeros( n - 1, 1 ) ] );
  end
end

