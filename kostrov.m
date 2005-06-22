%------------------------------------------------------------------------------%
% KOSTROV

if ~defined( dark )
  inputs
  dark = 1;
  if dark, foreground = [ 1 1 1 ]; background = [ 0 0 0 ]; linewidth = 1;
  else     foreground = [ 0 0 0 ]; background = [ 1 1 1 ]; linewidth = 1;
  end
  if dark
    cmap = [
     0 .5  2  4  6  8
     0  0  0  8  8  8
     0  0  8  8  0  0
     0  8  8  0  0  8]' / 8;
  else
    cmap = [
     0 .5  2  4  6  8
     8  2  2  8  8  4
     8  2  8  8  2  0
     8  8  8  2  2  0]' / 8;
  end
  endian = textread( 'out/endian', '%c' );
  it = textread( 'out/timestep', '', 1 );
  rho0 = material(1);
  fd0 = friction(2);
  tn0 = -traction(nrmdim);
  i = 1:3;
  i(nrmdim) = [];
  ts0 = sqrt( sum( traction(i) .^ 2 ) );
  miu0 = rho0 .* vs .* vs;
end

c = .81;
dtau = ts0 - fd0 * tn0;
fcorner = vp / ( 8 * h );
nn = 2 * round( 1 / ( fcorner * dt ) );
b = .5 * ( 1 - cos( 2 * pi * (1:nn-1) / nn ) );  % hanning
a = sum( b );
tg = ( .5 : it - .5 )' * dt;
xg = [];
for i = '123'
  fid  = fopen( [ 'out/01/mesh' i ], 'r', endian );
  xg(:,end+1) = fread( fid, inf, 'float32' );
  fclose( fid );
end
ng = size( xg, 1 );
xg = xg(2:end,:) - xg(1:end-1,:);
xg = [ 0; cumsum( sqrt( sum( xg .* xg, 2 ) ) ) ];
for i = 1:it
  file = sprintf( 'out/02/1/%05d', i );
  fid = fopen( file, 'r', endian );
  vg(i,:) = fread( fid, inf, 'float32' );
  fclose( fid );
end
vg = filter( b, a, vg );

if ~ishandle(3), figure(3), end
set( 0, 'CurrentFigure', 3 )
clf
set( 3, ...
  'InvertHardCopy', 'off', ...
  'Color', background, ...
  'DefaultAxesColorOrder', foreground, ...
  'DefaultAxesColor', background, ...
  'DefaultAxesXColor', foreground, ...
  'DefaultAxesYColor', foreground, ...
  'DefaultAxesZColor', foreground, ...
  'DefaultLineColor', foreground, ...
  'DefaultLineLinewidth', linewidth, ...
  'DefaultTextColor', foreground, ...
  'DefaultTextFontSize', 18, ...
  'DefaultTextFontName', 'FixedWidth' )
id = max( 1, round( ng / 6 ) );
ix = id:id:4*id;
plot( tg, vg(:,ix) )
drawnow
hold on
axis manual
for i = ix
  ta = xg(i) / vrup;
  vk = c * dtau / miu0 * vs * ( tg + ta ) ./ sqrt( tg .* ( tg + 2 * ta ) );
  vk = filter( b, a, vk );
  plot( tg + ta, vk, ':' )
end
xlabel( 'Time (s)' )
ylabel( 'Slip Velocity (m/s)' )

if ~ishandle(4), figure(4), end
set( 0, 'CurrentFigure', 4 )
clf
set( 4, ...
  'InvertHardCopy', 'off', ...
  'Color', background, ...
  'DefaultAxesColorOrder', foreground, ...
  'DefaultAxesColor', background, ...
  'DefaultAxesXColor', foreground, ...
  'DefaultAxesYColor', foreground, ...
  'DefaultAxesZColor', foreground, ...
  'DefaultLineColor', foreground, ...
  'DefaultLineLinewidth', linewidth, ...
  'DefaultTextColor', foreground, ...
  'DefaultTextFontSize', 18, ...
  'DefaultTextFontName', 'FixedWidth' )
imagesc( tg, xg, double( vg' ) );
hold on
plot( [ 0 rcrit/vrup tg(end) ], [ 0 rcrit rcrit ] );
if nclramp
  plot( [ 0 rcrit/vrup tg(end) ] + nclramp * dt, [ 0 rcrit rcrit ] );
end
title( 'Slip Velocity (m/s)' )
xlabel( 'Time (s)' )
ylabel( 'Distance (m)' )
axis xy
shading flat
clim = [ 0 1 ] * max( vg(:) );
colormap( interp1( cmap(:,1), cmap(:,2:4), cmap(1,1) : ( cmap(end,1) - cmap(1,1) ) / 1000 : cmap(end,1) ) );
set( gca, 'CLim', clim );

