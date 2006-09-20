% TeraShake fault viz

clear all
flim = 4;
iz = 21;
meta
dit = out{iz}{3};
i1 = [ out{iz}{4:7}  ];
i2 = [ out{iz}{8:11} ];
format compact
clf
colorscheme
pos = get( gcf, 'Position' );
set( gcf, ...
  'Position', [ pos(1:2) 1280 720 ], ...
  'Renderer', 'painters', ...
  'InvertHardcopy', 'off', ...
  'DefaultLineLinewidth', 1, ...
  'DefaultLineClipping', 'off', ...
  'DefaultImageClipping', 'off', ...
  'DefaultSurfaceClipping', 'off', ...
  'DefaultTextClipping', 'off', ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextVerticalAlignment', 'middle', ...
  'DefaultTextFontName', 'Helvetica', ...
  'DefaultTextFontSize', 14 )

% position data
[ msg, x2 ] = read4d( 'x', [ i1(1:3) 0 ], [ i2(1:3) 0 ], 3 );
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
xlim = [ min(x1(:)) max(x1(:)) min(x2(:)) max(x2(:)) ];

panes = [ 140 140 140 140 160 ];

% shear traction pane
flim = 200;
axes( 'Units', 'pixels', 'Position', [ 30 565 1240 135 ] );
hsurf = pcolor( x1, x2, x1 );
hold on
text( .8*lf - 21, -18, 'Shear Traction: 0', 'Hor', 'right' )
text( .8*lf + 21, -18, [ num2str(flim) 'MPa' ], 'Hor', 'left' )
imagesc( .8*lf + [ -20 20 ], -18 + .1 * [ -1 1 ], 0:.001*flim:flim )
caxis( flim * [ -1 1 ] )
plot( x1(:,k), x2(:,k) )
plot( x1(:,1), x2(:,1) )
plot( x1(1,:), x2(1,:) )
plot( x1(j,:), x2(j,:) )
for i = jf
  plot( x1(i,:), x2(i,:), ':' )
end
shading flat
axis equal
axis( xlim )
axis off

% top annotations
plot( [ 0 0 nan 0 100 nan 100 100 ], -18 + .3 * [ -1 1 nan 0 0 nan -1 1 ], 'LineWidth', 1 )
plot(  -2 + .3 * [ -1 1 nan 0 0 nan -1 1 ], -15 + [ 0 0 nan 0 16 nan 16 16 ], 'LineWidth', 1 )
text(  -2,  -7, '16km', 'Back', 'k', 'Rotation', 90 )
text(  50, -18, '100km', 'Back', 'k' )
text(   0,   3, 'NW', 'Hor', 'left' )
text(  lf,   3, 'SE', 'Hor', 'right' )
text(  26,   3, 'San Bernardino' )
text( 103,   3, 'Palm Springs' )
text( 177,   3, 'Salton Sea' )

% normal traction pane
flim = 200;
axes( 'Units', 'pixels', 'Position', [ 30 430 1240 135 ] );
hsurf(2) = pcolor( x1, x2, x1 );
hold on
text( .8*lf - 21, -18, 'Normal Traction: 0', 'Hor', 'right' )
text( .8*lf + 21, -18, [ num2str(flim) 'MPa' ], 'Hor', 'left' )
imagesc( .8*lf + [ -20 20 ], -18 + .1 * [ -1 1 ], 0:.001*flim:flim )
caxis( flim * [ -1 1 ] )
plot( x1(:,k), x2(:,k) )
plot( x1(:,1), x2(:,1) )
plot( x1(1,:), x2(1,:) )
plot( x1(j,:), x2(j,:) )
for i = jf
  plot( x1(i,:), x2(i,:), ':' )
end
shading flat
axis equal
axis( xlim )
axis off

% slip pane
flim = 4;
axes( 'Units', 'pixels', 'Position', [ 30 295 1240 135 ] );
hsurf(3) = pcolor( x1, x2, x1 );
hold on
hcont = plot( [ 0 1 ], [ 0 1 ] );
text( .8*lf - 21, -18, 'Slip: 0', 'Hor', 'right' )
text( .8*lf + 21, -18, [ num2str(flim) 'm' ], 'Hor', 'left' )
imagesc( .8*lf + [ -20 20 ], -18 + .1 * [ -1 1 ], 0:.001*flim:flim )
caxis( flim * [ -1 1 ] )
plot( x1(:,k), x2(:,k) )
plot( x1(:,1), x2(:,1) )
plot( x1(1,:), x2(1,:) )
plot( x1(j,:), x2(j,:) )
for i = jf
  plot( x1(i,:), x2(i,:), ':' )
end
shading flat
axis equal
axis( xlim )
axis off


% slip rate pane
flim = 4;
axes( 'Units', 'pixels', 'Position', [ 30 160 1240 135 ] );
hsurf(4) = pcolor( x1, x2, x1 );
hold on
hcont(2) = plot( [ 0 1 ], [ 0 1 ] );
text( .8*lf - 21, -18, 'Slip Rate: 0', 'Hor', 'right' )
text( .8*lf + 21, -18, [ num2str(flim) 'm/s' ], 'Hor', 'left' )
imagesc( .8*lf + [ -20 20 ], -18 + .1 * [ -1 1 ], 0:.001*flim:flim )
caxis( flim * [ -1 1 ] )
plot( x1(:,k), x2(:,k) )
plot( x1(:,1), x2(:,1) )
plot( x1(1,:), x2(1,:) )
plot( x1(j,:), x2(j,:) )
for i = jf
  plot( x1(i,:), x2(i,:), ':' )
end
shading flat
axis equal
axis( xlim )
axis off

% peak slip rate pane
flim = 4;
axes( 'Units', 'pixels', 'Position', [ 30 25 1240 135 ] );
hsurf(5) = pcolor( x1, x2, x1 );
hold on
text( .8*lf - 21, -18, 'Peak Slip Rate: 0', 'Hor', 'right' )
text( .8*lf + 21, -18, [ num2str(flim) 'm/s' ], 'Hor', 'left' )
imagesc( .8*lf + [ -20 20 ], -18 + .1 * [ -1 1 ], 0:.001*flim:flim )
caxis( flim * [ -1 1 ] )
plot( x1(:,k), x2(:,k) )
plot( x1(:,1), x2(:,1) )
plot( x1(1,:), x2(1,:) )
plot( x1(j,:), x2(j,:) )
for i = jf
  plot( x1(i,:), x2(i,:), ':' )
end
shading flat
axis equal
axis( xlim )
axis off

% bottom annotations
htime = text( 0, -18, 'Time: 0s', 'Hor', 'left' );
sio = imread( 'sio.png' );
igpp = imread( 'igpp.png' );
sdsu = imread( 'sdsu.png' );
image( 53 - [ 1 3    ], [ -17 -19 ], sio )
image( 66 - [ 1 4    ], [ -17 -19 ], igpp )
image( 78 - [ 1 2.25 ], [ -17 -19 ], sdsu )
text( 53, -18, 'SIO',  'Hor', 'left' )
text( 66, -18, 'IGPP', 'Hor', 'left' )
text( 78, -18, 'SDSU', 'Hor', 'left' )

% time loop
for it = 100
  [ msg, s ] = read4d( 'sl', [ i1(1:3) it ], [ i2(1:3) it ] );
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
  set( hcont, ...
    'XData', [ c1(1,:); nan; c2(1,:) ], ...
    'YData', [ c1(2,:); nan; c2(2,:) ] )
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  set( hsurf(3), 'CData', s )

  [ msg, s ] = read4d( 'svm', [ i1(1:3) it ], [ i2(1:3) it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  set( hsurf(4), 'CData', s )

  [ msg, s ] = read4d( 'psv', [ i1(1:3) it ], [ i2(1:3) it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  set( hsurf(5), 'CData', s )

  [ msg, s ] = read4d( 'tn', [ i1(1:3) it ], [ i2(1:3) it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  set( hsurf(1), 'CData', s )

  [ msg, s ] = read4d( 'tsm', [ i1(1:3) it ], [ i2(1:3) it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  set( hsurf(2), 'CData', s )

  set( htime, 'String', sprintf( 'Time = %5.1fs', it*dt ) )
  drawnow
  %snap( sprintf( 'tmp/frame%04d.png', iframe ) )
end

