% TeraShake fault viz

field = 'tsm'; t = 0;
field = 'svm'; t = 100:100:5000;
field = 'svm'; t = 2000;

i1 = [ 1317 0 -81 ];
i2 = [ 2311 0  -1 ];

meta
[ msg, x2 ] = read4d( 'x', [ i1 0 ], [ i2 0 ], 3 );
if msg, error( msg ), end
x2 = squeeze( x2 );
n = size( x2 );
x1 = zeros( n );
for i = 1:n(1)
  x1(i,:) = (i-1) * dx;
end

aspect = ( max(x1(:)) - min(x1(:)) ) / ( max(x2(:)) - min(x2(:)) )
1240 / aspect

for it = t
  clf
  set( gcf, 'Position', [ 0 400 1280 360 ] )
  axes( 'Units', 'pixels', 'Position', [ 20 228 1240 112 ] )
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
  caxis( [ 0 4 ] )
  plot( x1(1,:), x2(1,:), 'k' )
  plot( x1(:,1), x2(:,1), 'k' )
  plot( x1(end,:), x2(end,:), 'k' )
  plot( x1(:,end), x2(:,end), 'k' )

  axes( 'Units', 'pixels', 'Position', [ 20 20 1240 112 ] )
  [ msg, s ] = read4d( 'sl', [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  contour( x1, x2, s, [ dc0 dc0 ], '-k' );
  contour( x1, x2, s, .01 * [ dc0 dc0 ], '-k' );
  ss = s;
  ss(1:end-1,1:end-1) = .25 * ( ...
    s(1:end-1,1:end-1) + s(2:end,1:end-1) + ...
    s(1:end-1,2:end)   + s(2:end,2:end) );
  pcolor( x1, x2, ss )
  shading flat
  axis image
  axis off
  hold on
  caxis( [ 0 6 ] )
  plot( x1(1,:), x2(1,:), 'k' )
  plot( x1(:,1), x2(:,1), 'k' )
  plot( x1(end,:), x2(end,:), 'k' )
  plot( x1(:,end), x2(:,end), 'k' )
  contour( x1, x2, s, [ dc0 dc0 ], '-k' );
  contour( x1, x2, s, .01 * [ dc0 dc0 ], '-k' );
  drawnow
end

