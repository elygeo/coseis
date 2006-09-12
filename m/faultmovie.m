% TeraShake fault viz

clear all
flim = 4;
field = 'tsm'; t = 0;
field = 'svm'; t = 100:100:4000;
field = 'svm'; t = 2800:100:4000;
foldcs = 1;
colorexp = 1;
i1 = [ 1317 0 -81 ];
i2 = [ 2311 0  -1 ];
pos = get( gcf, 'Position' );
set( gcf, ...
  'Position', [ pos(1:2) 1280 360 ], ...
  'Renderer', 'painters', ...
  'InvertHardcopy', 'off', ...
  'Color', 'k', ...
  'DefaultAxesColor', 'k', ...
  'DefaultAxesColorOrder', [ 1 1 1 ], ...
  'DefaultAxesXColor', 'w', ...
  'DefaultAxesYColor', 'w', ...
  'DefaultAxesZColor', 'w', ...
  'DefaultLineColor', 'w', ...
  'DefaultLineLinewidth', 1, ...
  'DefaultLineClipping', 'off', ...
  'DefaultTextColor', 'w'
  'DefaultTextClipping', 'off', ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextVerticalAlignment', 'bottom', ...
  'DefaultTextFontName', 'Helvetica', ...
  'DefaultTextFontSize', 14 )
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
    0 0 0 1 4 4 4
    0 0 4 4 4 0 0
    0 4 4 1 0 0 4 ]' / 4;
  h = 1 / ( size( cmap, 1 ) - 1 );
  x1 = 0 : h : 1;
  x2 = -1 : .0005 : 1;
  x2 = abs( x2 ) .^ colorexp;
end
colormap( interp1( x1, cmap, x2 ) );

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

sio = imread( 'sio.png' );
igpp = imread( 'igpp.png' );
sdsu = imread( 'sdsu.png' );

iframe = 0;
iframe = 27;
for it = t
  iframe = iframe + 1;
  clf
  axes( 'Units', 'pixels', 'Position', [ 30 170 1240 180 ] );
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
  plot( c1(1,:), c1(2,:) )
  plot( c2(1,:), c2(2,:) )
  plot( x1(:,k), x2(:,k) )
  plot( x1(:,1), x2(:,1) )
  plot( x1(1,:), x2(1,:) )
  plot( x1(j,:), x2(j,:) )
  for i = jf
    plot( x1(i,:), x2(i,:), ':' )
  end
  plot( -2 + .3 * [ -1 1 nan 0 0 nan -1 1 ], ...
    [ x2(1,1) x2(1,1) nan x2(1,1) x2(1,k) nan x2(1,k) x2(1,k) ], 'LineWidth', 1 )
  imagesc( .71*lf + [ -25 25 ], 3 + .1 * [ -1 1 ], 0:.001*flim:flim )
  text( .71*lf - 25, 4, '0' )
  text( .71*lf,      4, 'Slip Rate' )
  text( .71*lf + 25, 4, [ num2str(flim) 'm/s' ] )
  text( x1(1,k), x2(1,k)+1, 'NW', 'Hor', 'left' )
  text( x1(j,k), x2(j,k)+1, 'SE', 'Hor', 'right' )
  text( x1(134,k), x2(134,k)+1, { 'San' 'Bernardino' } )
  text( x1(521,k), x2(521,k)+1, { 'Palm' 'Springs'   } )
  text( x1(900,k), x2(900,k)+1, { 'Salton' 'Sea'     } )
  text( -2, x2(1,41), '16km', 'Ver', 'middle', 'Rotation', 90, 'Back', bg )
  axis equal
  axis off
  caxis( flim * [-1 1] )

  haxes(2) = axes( 'Units', 'pixels', 'Position', [ 30 10 1240 160 ] );
  flim = 20e6;
  flim = 6;
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  pcolor( x1, x2, s )
  shading flat
  hold on
  plot( c1(1,:), c1(2,:) );
  plot( c2(1,:), c2(2,:) );
  plot( x1(:,k), x2(:,k) )
  plot( x1(:,1), x2(:,1) )
  plot( x1(1,:), x2(1,:) )
  plot( x1(j,:), x2(j,:) )
  for i = jf
    plot( x1(i,:), x2(i,:), ':' )
  end
  imagesc( .71*lf + [ -25 25 ], -21 + .1 * [ -1 1 ], 0:.001*flim:flim )
  text( .71*lf - 25, -20, '0' );
  text( .71*lf,      -20, 'Slip' );
  text( .71*lf + 25, -20, [ num2str(flim) 'm' ] );
  text( 0, -22, sprintf( 'Time = %5.1fs', it*dt ), 'Hor', 'left' )
  image( 53 - [ 1 4    ], [ -22 -19 ], sio )
  image( 66 - [ 1 5.5  ], [ -22 -19 ], igpp )
  image( 78 - [ 1 2.88 ], [ -22 -19 ], sdsu )
  text( 53, -22, 'SIO',  'Hor', 'left' )
  text( 66, -22, 'IGPP', 'Hor', 'left' )
  text( 78, -22, 'SDSU', 'Hor', 'left' )
  axis equal
  axis off
  caxis( flim * [-1 1] )
  drawnow
  snap( sprintf( 'tmp/frame%04d.png', iframe ) )
end

