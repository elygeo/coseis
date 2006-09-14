% TeraShake fault viz

clear all
flim = 4;
field = 'svm';
t = 200:200:3400;
i1 = [ 1317 0 -81 ];
i2 = [ 2311 0  -1 ];
pos = get( gcf, 'Position' );
set( gcf, ...
  'Renderer', 'painters', ...
  'Position', [ pos(1:2) 1280 128 ], ...
  'DefaultAxesColorOrder', [0 0 0], ...
  'DefaultLineColor', 'k', ...
  'DefaultLineLinewidth', 1, ...
  'DefaultLineClipping', 'off', ...
  'DefaultTextClipping', 'off', ...
  'DefaultTextFontName', 'Helvetica', ...
  'DefaultTextFontSize', 14, ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextVerticalAlignment', 'bottom', ...
  'DefaultTextColor', 'k' )
setcolormap( 'folded', 'light' )

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
jf = round( rf(2:end-1) / dx ) + 1;

for it = t
  clf
  axes( 'Position', [0 0 1 1] )
  [ msg, s ] = read4d( 'svm', [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  if size( s, 3 ) > 1, s = sqrt( sum( s .* s, 3 ) ); end
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  pcolor( x1, x2, s )
  caxis( flim * [0 1] )
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
  plot( c1(1,:), c1(2,:) )
  plot( c2(1,:), c2(2,:) )
  plot( x1(:,k), x2(:,k) )
  plot( x1(:,1), x2(:,1) )
  plot( x1(1,:), x2(1,:) )
  plot( x1(j,:), x2(j,:) )
  for i = jf
    plot( x1(i,:), x2(i,:), ':' )
  end
  axis equal
  axis off
  snap( sprintf( 'fault%04d.png', it ) )
end

