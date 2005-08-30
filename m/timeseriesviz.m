%------------------------------------------------------------------------------%
% TIMESERIESVIZ

nout = size( outvar, 1 );

if ~exist( 'w1', 'var' ) % not running from in sord
  addpath m
  input
  % init = 1; viz
  % init = 2; viz
  km = 0;
  field = 'v';
  ncomp = 3;
  offset = [ 0 0 0 ];
  xhypo = textread( 'out/xhypo', '', 1 );
  if strcmp( model, 'explosion' ) && strcmp( field, 'v' )
    found = 0;
    iz = 0;
    while iz < nout
      iz = iz + 1;
      [ i1, i2 ] = zoneselect( iout(iz,:), nn, offset, hypocenter, nrmdim );
      if strcmp( outvar{iz}, field ) && sum( xhair >= i1 & xhair <= i2 ) == 3
        found = 1;
        break
      end
    end
    if ~found, error xfile, end
    n = i2 - i1 + 1;
    i = xhair - i1;
    goffset = 4 * sum( i .* cumprod( [ 1 n(1:2) ] ) );
    for i = 1:3
      file = sprintf( 'out/%02d/%1d/00001', iz, i );
      fid = fopen( file, 'rl' );
      fseek( fid, goffset, -1 );
      xhairtarg(i) = fread( fid, 1, 'float32' );
      fclose( fid );
    end
  end
end

% read time series
iz = 0;
msg = 'no time series data at this location';
while iz < nout
  iz = iz + 1;
  [ i1, i2 ] = zoneselect( iout(iz,:), nn, offset, hypocenter, nrmdim );
  if strcmp( outvar{iz}, field ) && sum( xhair >= i1 & xhair <= i2 ) == 3 && outit(iz) == 1
    msg = '';
    break
  end
end
if msg, return, end
n = i2 - i1 + 1;
i = xhair - i1;
goffset = 4 * sum( i .* cumprod( [ 1 n(1:2) ] ) );
clear vg
for i = 1:ncomp
for itt = 1:it
  file = sprintf( 'out/%02d/%1d/%05d', iz, i, itt );
  fid = fopen( file, 'rl' );
  fseek( fid, goffset, -1 );
  vg(itt+1,i) = fread( fid, 1, 'float32' );
  fclose( fid );
end
end

switch field
case 'v', time = ( 0 : it ) * dt + dt / 2;
otherwise time = ( 0 : it ) * dt;
end
tg = time;
newtitles = titles(2:end);

if km
  fcorner = vp / ( 6 * dx );
  n = 2 * round( 1 / ( fcorner * dt ) );
  b = .5 * ( 1 - cos( 2 * pi * ( 1 : n - 1 ) / n ) );  % hanning
  %b = [ b b(end-1:-1:1) ];
  a  = sum( b );
  vg = filter( b, a, [ vg; zeros( n - 1, size( vg, 2 ) ) ] );
  time = [ time time(end) + dt * ( 1 : n - 1 ) ];
end

figure( ...
 'Color', background, ...
 'KeyPressFcn', 'delete(gcbf)', ...
 'DefaultAxesColorOrder', foreground, ...
 'DefaultAxesColor', background, ...
 'DefaultAxesXColor', foreground, ...
 'DefaultAxesYColor', foreground, ...
 'DefaultAxesZColor', foreground, ...
 'DefaultLineColor', foreground, ...
 'DefaultLineLinewidth', linewidth, ...
 'DefaultTextHorizontalAlignment', 'center', ...
 'DefaultTextColor', foreground )
if strcmp( model, 'explosion' ) && strcmp( field, 'v' )
  xg = xhairtarg - xhypo;
  rg = sqrt( sum( xg .* xg ) );
  tg = tg - rg / vp;
  if ( xg(1) || xg(2) )
    rot = [ xg(1)  xg(2) xg(1)*xg(3)
            xg(2) -xg(1) xg(2)*xg(3)
            xg(3)     0 -xg(1)*xg(1)-xg(2)*xg(2) ];
    tmp = sqrt( sum( rot .* rot, 1 ) );
    for i = 1:3
      rot(i,:) = rot(i,:) ./ tmp;
    end
    vg = vg * rot;
    newtitles = { 'Vr' 'Vh' 'Vv' };
  end
  vk = zeros( it+1, 1 );
  i = find( tg > 0 );
  switch srctimefcn
  case 'brune'
    vk(i,1) = moment(1) / 4 / pi / rho0 / vp ^ 2 / domp ^ 2 / rg / vp * ...
    exp( -tg(i) / domp ) .* ( tg(i) * vp / rg - tg(i) / domp + 1 );
  case 'sbrune'
    vk(i,1) = moment(1) / 8 / pi / rho0 / vp ^ 2 / domp ^ 3 / rg / vp * ...
    exp( -tg(i) / domp ) .* ( tg(i) * vp / rg - tg(i) / domp + 2 ) .* tg(i);
  otherwise error srctimefcn
  end
  if km
    vk = filter( b, a, [ vk; zeros( n - 1, 1 ) ] );
  end
  plot( time, vk, ':' )
  hold on
end

plot( time, vg )
hold on
for i = 1 : length( newtitles )
  [ tmp, ii ] = max( abs( vg(:,i) ) );
  iii = max( 1, ii - 1 );
  xg1 = .5 * double( time(ii) + time(iii) );
  xg2 = .5 * double( vg(ii,i) + vg(iii,i) );
  if xg2 > 0
    text( xg1, xg2, newtitles(i), 'Hor', 'right', 'Ver', 'bottom' )
  else
    text( xg1, xg2, newtitles(i), 'Hor', 'right', 'Ver', 'top' )
  end
end
ylabel( field )
xlabel( 'Time' )
title( num2str( xhair ) )
set( 0, 'CurrentFigure', 1 )

