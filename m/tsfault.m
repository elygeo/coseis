% TeraShake fault viz

clear all
srcdir
cd 'runs/ts200'
field = 'tsm'; t = 0;
field = 'svm'; t = 100:100:5000;
field = 'svm'; t = 2500;
foldcs = 1;
colorexp = .5;
colorexp = 1;
i1 = [ 1317 0 -81 ];
i2 = [ 2311 0  -1 ];

if ~foldcs
  cmap = [
    0 0 0 1 1
    1 0 0 0 1
    1 1 0 0 0 ]';
  h = 2 / ( size( cmap, 1 ) - 1 );
  x1 = -1 : h : 1;
  x2 = -1 : .0005 : 1;
  x2 = sign( x2 ) .* abs( x2 ) .^ colorexp;
else
  cmap = [
    0 0 0 1 1 1
    0 0 1 1 0 0
    0 1 1 0 0 1 ]';
  h = 1 / ( size( cmap, 1 ) - 1 );
  x1 = 0 : h : 1;
  x2 = -1 : .0005 : 1;
  x2 = abs( x2 ) .^ colorexp;
end
colormap( interp1( x1, cmap, x2 ) );
set( gcf, ...
  'Renderer', 'painters', ...
  'KeyPressFcn', '', ...
  'ResizeFcn', '', ...
  'Name', 'TS Fault', ...
  'NumberTitle', 'off', ...
  'InvertHardcopy', 'off', ...
  'Color', 'k', ...
  'DefaultAxesColor', 'k', ...
  'DefaultAxesColorOrder', [1 1 1], ...
  'DefaultAxesXColor', 'w', ...
  'DefaultAxesYColor', 'w', ...
  'DefaultAxesZColor', 'w', ...
  'DefaultLineColor', 'w', ...
  'DefaultLineLinewidth', 1, ...
  'DefaultLineClipping', 'off', ...
  'DefaultTextClipping', 'off', ...
  'DefaultTextFontName', 'Helvetica', ...
  'DefaultTextFontSize', 12, ...
  'DefaultTextColor', 'w' )

meta
[ msg, x2 ] = read4d( 'x', [ i1 0 ], [ i2 0 ], 3 );
if msg, error( msg ), end
x2 = squeeze( x2 );
x2 = .001 * x2;
dx = .001 * dx;
n = size( x2 );
j = n(1);
k = n(2);
x1 = zeros( n );
for i = 1:n(1)
  x1(i,:) = (i-1) * dx;
end

lf = max(x1(:));
rf = [ 0 28.230 74.821 103.231 129.350 198.778 ];
jf = round( rf / dx ) + 1;

set( gcf, 'Position', [ 0 442 1280 360 ] )

for it = t
  clf
  flim = 4;
  axes( 'Units', 'pixels', 'Position', [ 30 180 1240 170 ] );
  [ msg, s ] = read4d( 'svm', [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  if size( s, 3 ) > 1, s = sqrt( sum( s .* s, 3 ) ); end
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  pcolor( x1, x2, s )
  shading flat
  hold on
  [ msg, s ] = read4d( 'sl', [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  [ c1, h ] = contour( x1', x2', s', [ dc0 dc0 ] );
  delete( h );
  i = 1;
  while i < size( c1, 2 )
    n = c1(2,i);
    c1(:,i) = nan;
    i = i + n + 1;
  end 
  [ c2, h ] = contour( x1', x2', s', .01 * [ dc0 dc0 ] );
  delete( h );
  i = 1;
  while i < size( c2, 2 )
    n = c2(2,i);
    c2(:,i) = nan;
    i = i + n + 1;
  end 
  plot( c1(1,:), c1(2,:) );
  plot( c2(1,:), c2(2,:) );
  plot( x1(:,k), x2(:,k) )
  plot( x1(:,1), x2(:,1), '--' )
  for i = jf
    plot( x1(i,:), x2(i,:), '--' )
  end
  plot( -3 + .3 * [ -1 1 nan 0 0 nan -1 1 ], ...
    [ x2(1,1) x2(1,1) nan x2(1,1) x2(1,k) nan x2(1,k) x2(1,k) ], 'LineWidth', 1 )
  imagesc( 142 + [ -25 25 ], -19 + .1 * [ -1 1 ], 0:.001*flim:flim )
  h    = text( 142 - 25, -20, '0' );
  h(2) = text( 142,      -20, 'Slip Rate' );
  h(3) = text( 142 + 25, -20, [ num2str(flim) 'm/s' ] );
  set( h, 'Ver', 'top', 'Hor', 'center' );
  text( 10, -20, sprintf( 'Time = %.1fs', it*dt ), 'Ver', 'top', 'Hor', 'left' )
  h    = text( x1(1,k), x2(1,k)+1, 'NW', 'Hor', 'left' );
  h(2) = text( x1(j,k), x2(j,k)+1, 'SE', 'Hor', 'right' );
  h(3) = text( x1(134,k), x2(134,k)+1, { 'San' 'Bernardino' }, 'Hor', 'center' );
  h(4) = text( x1(521,k), x2(521,k)+1, { 'Palm' 'Springs' }, 'Hor', 'center' );
  h(5) = text( x1(900,k), x2(900,k)+1, { 'Salton' 'Sea' }, 'Hor', 'center' );
  set( h, 'Ver', 'bottom' )
  text( -3, x2(1,41), '16km', 'Ver', 'middle', 'Hor', 'center', 'Rotation', 90, 'Back', 'k' );
  axis equal
  axis off
  caxis( flim * [-1 1] )

  haxes(2) = axes( 'Units', 'pixels', 'Position', [ 30 10 1240 170 ] );
  flim = 6;
  s(1:end-1,1:end-1) = .25 * ( ...
    s(1:end-1,1:end-1) + s(2:end,1:end-1) + ...
    s(1:end-1,2:end)   + s(2:end,2:end) );
  pcolor( x1, x2, s )
  shading flat
  hold on
  plot( c1(1,:), c1(2,:) );
  plot( c2(1,:), c2(2,:) );
  plot( x1(:,k), x2(:,k) )
  plot( x1(:,1), x2(:,1), '--' )
  for i = jf
    plot( x1(i,:), x2(i,:), '--' )
  end
  imagesc( .71 * lf + [ -25 25 ], -19 + .1 * [ -1 1 ], 0:.001*flim:flim )
  h    = text( .71 * lf - 25, -20, '0' );
  h(2) = text( .71 * lf,      -20, 'Slip' );
  h(3) = text( .71 * lf + 25, -20, [ num2str(flim) 'm/s' ] );
  set( h, 'Ver', 'top', 'Hor', 'center' );
  axis equal
  axis off
  caxis( flim * [-1 1] )
  drawnow
end

