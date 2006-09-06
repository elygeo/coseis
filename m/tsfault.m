% TeraShake fault viz

field = 'tsm'; t = 0;
field = 'svm'; t = 100:100:5000;
field = 'svm'; t = 2000;
foldcs = 1;
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
x1 = zeros( n );
for i = 1:n(1)
  x1(i,:) = (i-1) * dx;
end

aspect = ( max(x1(:)) - min(x1(:)) ) / ( max(x2(:)) - min(x2(:)) );
1240 / aspect;

for it = t
  clf
  set( gcf, 'Position', [ 0 400 1280 360 ], 'Clipping', 'off' )
  axes( 'Units', 'pixels', 'Position', [ 20 200 1240 112 ] )
  [ msg, s ] = read4d( 'svm', [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  if size( s, 3 ) > 1, s = sqrt( sum( s .* s, 3 ) ); end
  s(1:end-1,1:end-1) = .25 * ( ...
    s(1:end-1,1:end-1) + s(2:end,1:end-1) + ...
    s(1:end-1,2:end)   + s(2:end,2:end) );
  pcolor( x1, x2, s )
  shading flat
  axis image
  axis off
  hold on
  caxis( [ -4 4 ] )
  plot( x1(1,:)+1, x2(1,:), 'w' )
  plot( x1(:,1), x2(:,1), 'w' )
  plot( x1(end,:), x2(end,:), 'w' )
  plot( x1(:,end), x2(:,end), 'w' )
  text( x1(1,end), x2(1,end)+1000, 'NW', 'Hor', 'left', 'Ver', 'bottom' )
  text( x1(end,end), x2(end,end)+1000, 'SE', 'Hor', 'right', 'Ver', 'bottom' )
  text( x1(134,end), x2(134,end)+1000, { 'San' 'Bernardino' }, 'Hor', 'center', 'Ver', 'bottom' )
  text( x1(521,end), x2(521,end)+1000, { 'Palm' 'Springs' }, 'Hor', 'center', 'Ver', 'bottom' )
  text( x1(900,end), x2(900,end)+1000, { 'Salton' 'Sea' }, 'Hor', 'center', 'Ver', 'bottom' )
  [ msg, s ] = read4d( 'sl', [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  contour( x1, x2, s, [ dc0 dc0 ], '-w' );
  contour( x1, x2, s, .01 * [ dc0 dc0 ], '-w' );

  axes( 'Units', 'pixels', 'Position', [ 20 20 1240 112 ], 'Clipping', 'off' )
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
  plot( x1(1,:), x2(1,:), 'w' )
  plot( x1(:,1), x2(:,1), 'w' )
  plot( x1(end,:), x2(end,:), 'w' )
  plot( x1(:,end), x2(:,end), 'w' )
  contour( x1, x2, s, [ dc0 dc0 ], '-w' );
  contour( x1, x2, s, .01 * [ dc0 dc0 ], '-w' );
  drawnow
end

