% TeraShake fault viz

clear all
flim = 4;
iz = 21;
meta
dit = out{iz}{3};
i1 = [ out{iz}{4:7}  ];
i2 = [ out{iz}{8:11} ];
i1 = [ out{iz}{4:6}  0 ];
i2 = [ out{iz}{8:10} 0 ];
format compact
clf
colorscheme
pos = get( gcf, 'Position' );
set( gcf, ...
  'Position', [ pos(1:2) 1280 720 ], ...
  'Renderer', 'painters', ...
  'InvertHardcopy', 'off', ...
  'DefaultLineLinewidth', 1, ...
  'DefaultLineMarkerSize', 15, ...
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
x1 = zeros( n );
for i = 1:n(1)
  x1(i,:) = (i-1) * dx;
end
xlim = [ min(x1(:)) max(x1(:)) min(x2(:)) max(x2(:)) ];
lf = max(x1(:));
ihypo = ihypo - i1(1:3) + 1;
j = ihypo(1);
k = ihypo(3);
rf = [ 0 28.230 74.821 103.231 129.350 198.778 ];
jf = round( rf(2:end-1) / dx ) + 1;

panes = [ 140 140 140 140 160 ];

% normal traction pane
flim = 50;
axes( 'Units', 'pixels', 'Position', [ 30 565 1220 135 ] );
hsurf = pcolor( x1, x2, x1 );
hold on
text( 2, -1, 'Normal Traction', 'Ver', 'top', 'Hor', 'left', 'FontWeight', 'bold' )
text( .1*lf - 16, -18, '0', 'Hor', 'right' )
text( .1*lf + 16, -18, [ num2str(flim) 'MPa' ], 'Hor', 'left' )
h = flim / ( length( colormap ) - 1 );
imagesc( .1*lf + [ -15 15 ], -18 + .2 * [ -1 1 ], 0:h:flim )
caxis( flim * [ -1 1 ] )
plot( x1(:,1), x2(:,1) )
plot( x1(1,:), x2(1,:) )
plot( x1(:,end), x2(:,end) )
plot( x1(end,:), x2(end,:) )
for i = jf
  plot( x1(i,:), x2(i,:), ':' )
end
plot( x1(j,k), x2(j,k), 'p' )
shading flat
axis equal
axis( xlim )
axis off

% top annotations
plot( lf - [ 0 0 nan 0 100 nan 100 100 ], -18 + .6 * [ -1 1 nan 0 0 nan -1 1 ], 'LineWidth', 1 )
plot( lf+2 + .6 * [ -1 1 nan 0 0 nan -1 1 ], -16 + [ 0 0 nan 0 16 nan 16 16 ], 'LineWidth', 1 )
text( lf+2,  -7, '16km', 'Back', 'k', 'Rotation', -90 )
text( lf-50, -18, '100km', 'Back', 'k' )
text(   0,   3, 'NW', 'Hor', 'left' )
text(  26,   3, 'San Bernardino' )
text( 103,   2.5, 'Palm Springs' )
text( 177,   2.5, 'Salton Sea' )
text(  lf,   2.5, 'SE', 'Hor', 'right' )

% shear traction pane
flim = 25;
axes( 'Units', 'pixels', 'Position', [ 30 430 1220 135 ] );
hsurf(2) = pcolor( x1, x2, x1 );
hold on
text( 2, -1, 'Shear Traction', 'Ver', 'top', 'Hor', 'left', 'FontWeight', 'bold' )
hcont = plot( [ 0 1 ], [ 0 1 ] );
h = flim / ( length( colormap ) - 1 );
imagesc( .1*lf + [ -15 15 ], -18 + .2 * [ -1 1 ], 0:h:flim )
text( .1*lf - 16, -18, '0', 'Hor', 'right' )
text( .1*lf + 16, -18, [ num2str(flim) 'MPa' ], 'Hor', 'left' )
caxis( flim * [ -1 1 ] )
plot( x1(:,1), x2(:,1) )
plot( x1(1,:), x2(1,:) )
plot( x1(:,end), x2(:,end) )
plot( x1(end,:), x2(end,:) )
for i = jf
  plot( x1(i,:), x2(i,:), ':' )
end
plot( x1(j,k), x2(j,k), 'p' )
shading flat
axis equal
axis( xlim )
axis off

% slip pane
flim = 6;
axes( 'Units', 'pixels', 'Position', [ 30 295 1220 135 ] );
hsurf(3) = pcolor( x1, x2, x1 );
hold on
text( 2, -1, 'Slip', 'Ver', 'top', 'Hor', 'left', 'FontWeight', 'bold' )
hcont(2) = plot( [ 0 1 ], [ 0 1 ] );
text( .1*lf - 16, -18, '0', 'Hor', 'right' )
text( .1*lf + 16, -18, [ num2str(flim) 'm' ], 'Hor', 'left' )
h = flim / ( length( colormap ) - 1 );
imagesc( .1*lf + [ -15 15 ], -18 + .2 * [ -1 1 ], 0:h:flim )
caxis( flim * [ -1 1 ] )
plot( x1(:,1), x2(:,1) )
plot( x1(1,:), x2(1,:) )
plot( x1(:,end), x2(:,end) )
plot( x1(end,:), x2(end,:) )
for i = jf
  plot( x1(i,:), x2(i,:), ':' )
end
plot( x1(j,k), x2(j,k), 'p' )
shading flat
axis equal
axis( xlim )
axis off

% slip rate pane
flim = 6;
axes( 'Units', 'pixels', 'Position', [ 30 160 1220 135 ] );
hsurf(4) = pcolor( x1, x2, x1 );
hold on
text( 2, -1, 'Peak Slip Rate', 'Ver', 'top', 'Hor', 'left', 'FontWeight', 'bold' )
hcont(3) = plot( [ 0 1 ], [ 0 1 ] );
text( .1*lf - 16, -18, '0', 'Hor', 'right' )
text( .1*lf + 16, -18, [ num2str(flim) 'm/s' ], 'Hor', 'left' )
h = flim / ( length( colormap ) - 1 );
imagesc( .1*lf + [ -15 15 ], -18 + .2 * [ -1 1 ], 0:h:flim )
caxis( flim * [ -1 1 ] )
plot( x1(:,1), x2(:,1) )
plot( x1(1,:), x2(1,:) )
plot( x1(:,end), x2(:,end) )
plot( x1(end,:), x2(end,:) )
for i = jf
  plot( x1(i,:), x2(i,:), ':' )
end
plot( x1(j,k), x2(j,k), 'p' )
shading flat
axis equal
axis( xlim )
axis off

% peak slip rate pane
flim = 6;
axes( 'Units', 'pixels', 'Position', [ 30 25 1220 135 ] );
hsurf(5) = pcolor( x1, x2, x1 );
hold on
text( 2, -1, 'Slip Rate', 'Ver', 'top', 'Hor', 'left', 'FontWeight', 'bold' )
hcont(4) = plot( [ 0 1 ], [ 0 1 ] );
text( .1*lf - 16, -18, '0', 'Hor', 'right' )
text( .1*lf + 16, -18, [ num2str(flim) 'm/s' ], 'Hor', 'left' )
h = flim / ( length( colormap ) - 1 );
imagesc( .1*lf + [ -15 15 ], -18 + .2 * [ -1 1 ], 0:h:flim )
caxis( flim * [ -1 1 ] )
plot( x1(:,1), x2(:,1) )
plot( x1(1,:), x2(1,:) )
plot( x1(:,end), x2(:,end) )
plot( x1(end,:), x2(end,:) )
for i = jf
  plot( x1(i,:), x2(i,:), ':' )
end
plot( x1(j,k), x2(j,k), 'p' )
shading flat
axis equal
axis( xlim )
axis off

% bottom annotations
htime = text( .5*lf, -18, 'Time: 0s' );
sio = imread( 'sio.png' );
igpp = imread( 'igpp.png' );
sdsu = imread( 'sdsu.png' );
image( 163 - [ 1 3    ], [ -17 -19 ], sio )
image( 176 - [ 1 4    ], [ -17 -19 ], igpp )
image( 188 - [ 1 2.25 ], [ -17 -19 ], sdsu )
text( 163, -18, 'SIO',  'Hor', 'left' )
text( 176, -18, 'IGPP', 'Hor', 'left' )
text( 188, -18, 'SDSU', 'Hor', 'left' )

% time loop
for it = i1(4) : dit : i2(4)
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
  c1 = [ c1 c2 ];
  if size( c1 ), set( hcont, 'XData', c1(1,:), 'YData', c1(2,:) )
  else, set( hcont, 'XData', [], 'YData', [] )
  end
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
  set( hsurf(5), 'CData', s )

  [ msg, s ] = read4d( 'psv', [ i1(1:3) it ], [ i2(1:3) it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  set( hsurf(4), 'CData', s )

  [ msg, s ] = read4d( 'tn', [ i1(1:3) it ], [ i2(1:3) it ] );
  if msg, error( msg ), end
  s = squeeze( s ) * 1e-6;
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  set( hsurf(1), 'CData', s )

  [ msg, s ] = read4d( 'tsm', [ i1(1:3) it ], [ i2(1:3) it ] );
  if msg, error( msg ), end
  s = squeeze( s ) * 1e-6;
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  set( hsurf(2), 'CData', s )

  set( htime, 'String', sprintf( 'Time = %5.1fs', it*dt ) )
  drawnow
  %snap( sprintf( 'tmp/frame%04d.png', iframe ) )
end

