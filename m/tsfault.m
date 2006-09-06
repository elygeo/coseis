% TeraShake fault viz

clear all
field = 'tsm'; t = 0;
field = 'svm'; t = 100:100:5000;
field = 'svm'; t = 2000;
foldcs = 1;
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
  'InvertHardcopy', 'off', ...
  'Color', 'k', ...
  'DefaultLineColor', 'w', ...
  'DefaultTextFontSize', 12, ...
  'DefaultLineClipping', 'off', ...
  'DefaultTextColor', 'w' )

meta
[ msg, x2 ] = read4d( 'x', [ i1 0 ], [ i2 0 ], 3 );
if msg, error( msg ), end
x2 = squeeze( x2 );
n = size( x2 );
j = n(1);
k = n(2);
x1 = zeros( n );
for i = 1:n(1)
  x1(i,:) = (i-1) * dx;
end

aspect = ( max(x1(:)) - min(x1(:)) ) / ( max(x2(:)) - min(x2(:)) );
1240 / aspect;

set( gcf, 'Position', [ 0 442 1280 360 ], 'Clipping', 'off' )

for it = t
  clf
  axes( 'Units', 'pixels', 'Position', [ 0 210 1280 112 ] )
  [ msg, s ] = read4d( 'svm', [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  if size( s, 3 ) > 1, s = sqrt( sum( s .* s, 3 ) ); end
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  pcolor( x1, x2, s )
  shading flat
  axis image
  axis off
  hold on
  caxis( [ -4 4 ] )
  plot( x1(:,k), x2(:,k), 'w' )
  plot( [ x1(j,k:-1:1) x1(j-1:-1:2,1)' x1(1,:) ], [ x2(j,k:-1:1) x2(j-1:-1:2,1)' x2(1,:) ], 'w--' )
  text( x1(1,k), x2(1,k)+1000, 'NW', 'Hor', 'left', 'Ver', 'bottom' )
  text( x1(j,k), x2(j,k)+1000, 'SE', 'Hor', 'right', 'Ver', 'bottom' )
  text( x1(134,k), x2(134,k)+1000, { 'San' 'Bernardino' }, 'Hor', 'center', 'Ver', 'bottom' )
  text( x1(521,k), x2(521,k)+1000, { 'Palm' 'Springs' }, 'Hor', 'center', 'Ver', 'bottom' )
  text( x1(900,k), x2(900,k)+1000, { 'Salton' 'Sea' }, 'Hor', 'center', 'Ver', 'bottom' )
  [ msg, s ] = read4d( 'sl', [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  contour( x1, x2, s, [ dc0 dc0 ], '-w' );
  contour( x1, x2, s, .01 * [ dc0 dc0 ], '-w' );

  axes( 'Units', 'pixels', 'Position', [ 0 40 1280 112 ], 'Clipping', 'off' )
  ss = s;
  ss(1:end-1,1:end-1) = .25 * ( ...
    s(1:end-1,1:end-1) + s(2:end,1:end-1) + ...
    s(1:end-1,2:end)   + s(2:end,2:end) );
  pcolor( x1, x2, ss )
  shading flat
  axis image
  axis off
  hold on
  caxis( [ -6 6 ] )
  plot( x1(:,end), x2(:,end), 'w' )
  plot( [ x1(j,k:-1:1) x1(j-1:-1:2,1)' x1(1,:) ], [ x2(j,k:-1:1) x2(j-1:-1:2,1)' x2(1,:) ], 'w--' )
  contour( x1, x2, s, [ dc0 dc0 ], '-w' );
  contour( x1, x2, s, .01 * [ dc0 dc0 ], '-w' );
  drawnow
end

