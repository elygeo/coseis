% TeraShake fault viz

clear all
flim = 4;
iz = 21;
meta
dit = out{iz}{3};
i1 = out{iz}{4:7};
i2 = out{iz}{8:11};
pos = get( gcf, 'Position' );
clf
set( gcf, ...
  'Position', [ pos(1:2) 1280 720 ], ...
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
  'DefaultTextClipping', 'off', ...
  'DefaultTextColor', 'w'
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextVerticalAlignment', 'bottom', ...
  'DefaultTextFontName', 'Helvetica', ...
  'DefaultTextFontSize', 14 )
setcolormap( 'folded' )

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

% shear traction pane
flim = 999;
axes( 'Units', 'pixels', 'Position', [ 30 540 1240 180 ] );
hsurf = pcolor( x1, x2, x1 );
hold on
text( .71*lf - 25, 4, '0' )
text( .71*lf,      4, 'Shear Traction' )
text( .71*lf + 25, 4, [ num2str(flim) 'MPa' ] )
imagesc( .71*lf + [ -25 25 ], 3 + .1 * [ -1 1 ], 0:.001*flim:flim )
%caxis( flim * [ -1 1 ] )
plot( x1(:,k), x2(:,k) )
plot( x1(:,1), x2(:,1) )
plot( x1(1,:), x2(1,:) )
plot( x1(j,:), x2(j,:) )
for i = jf
  plot( x1(i,:), x2(i,:), ':' )
end
shading flat
axis equal
axis off

% top annotations
plot( -2 + .3 * [ -1 1 nan 0 0 nan -1 1 ], ...
  [ x2(1,1) x2(1,1) nan x2(1,1) x2(1,k) nan x2(1,k) x2(1,k) ], 'LineWidth', 1 )
hold on
text( x1(1,k), x2(1,k)+1, 'NW', 'Hor', 'left' )
text( x1(j,k), x2(j,k)+1, 'SE', 'Hor', 'right' )
text( x1(134,k), x2(134,k)+1, { 'San' 'Bernardino' } )
text( x1(521,k), x2(521,k)+1, { 'Palm' 'Springs'   } )
text( x1(900,k), x2(900,k)+1, { 'Salton' 'Sea'     } )
text( -2, x2(1,41), '16km', 'Ver', 'middle', 'Rotation', 90, 'Back', bg )

% normal traction pane
flim = 999;
axes( 'Units', 'pixels', 'Position', [ 30 420 1240 120 ] );
hsurf(2) = pcolor( x1, x2, x1 );
hold on
text( .71*lf - 25, 4, '0' )
text( .71*lf,      4, 'Normal Traction' )
text( .71*lf + 25, 4, [ num2str(flim) 'MPa' ] )
imagesc( .71*lf + [ -25 25 ], 3 + .1 * [ -1 1 ], 0:.001*flim:flim )
%caxis( flim * [ -1 1 ] )
plot( x1(:,k), x2(:,k) )
plot( x1(:,1), x2(:,1) )
plot( x1(1,:), x2(1,:) )
plot( x1(j,:), x2(j,:) )
for i = jf
  plot( x1(i,:), x2(i,:), ':' )
end
shading flat
axis equal
axis off

% slip pane
flim = 4;
axes( 'Units', 'pixels', 'Position', [ 30 300 1240 120 ] );
hsurf(3) = pcolor( x1, x2, x1 );
hold on
hcont = plot( [ 0 1 ], [ 0 1 ] );
text( .71*lf - 25, -20, '0' );
text( .71*lf,      -20, 'Slip' );
text( .71*lf + 25, -20, [ num2str(flim) 'm' ] );
imagesc( .71*lf + [ -25 25 ], -21 + .1 * [ -1 1 ], 0:.001*flim:flim )
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
axis off

% slip rate pane
flim = 4;
axes( 'Units', 'pixels', 'Position', [ 30 180 1240 120 ] );
hsurf(4) = pcolor( x1, x2, x1 );
hold on
hcont(2) = plot( [ 0 1 ], [ 0 1 ] );
text( .71*lf - 25, 4, '0' )
text( .71*lf,      4, 'Slip Rate' )
text( .71*lf + 25, 4, [ num2str(flim) 'm/s' ] )
imagesc( .71*lf + [ -25 25 ], 3 + .1 * [ -1 1 ], 0:.001*flim:flim )
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
axis off

% peak slip rate pane
flim = 4;
axes( 'Units', 'pixels', 'Position', [ 30 0 1240 180 ] );
hsurf(5) = pcolor( x1, x2, x1 );
hold on
text( .71*lf - 25, 4, '0' )
text( .71*lf,      4, 'Peak Slip Rate' )
text( .71*lf + 25, 4, [ num2str(flim) 'm/s' ] )
imagesc( .71*lf + [ -25 25 ], 3 + .1 * [ -1 1 ], 0:.001*flim:flim )
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
axis off

% bottom annotations
htime = text( 0, -22, '0s', 'Hor', 'left' );
sio = imread( 'sio.png' );
igpp = imread( 'igpp.png' );
sdsu = imread( 'sdsu.png' );
image( 53 - [ 1 4    ], [ -22 -19 ], sio )
image( 66 - [ 1 5.5  ], [ -22 -19 ], igpp )
image( 78 - [ 1 2.88 ], [ -22 -19 ], sdsu )
text( 53, -22, 'SIO',  'Hor', 'left' )
text( 66, -22, 'IGPP', 'Hor', 'left' )
text( 78, -22, 'SDSU', 'Hor', 'left' )

% time loop
for it = 200
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
  set( hcont, ...
    'XData', [ c1(1,:); nan; c2(1,:) ], ...
    'YData', [ c1(2,:); nan; c2(2,:) ] )
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  set( hsurf(3), 'CData', s )

  [ msg, s ] = read4d( 'svm', [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  set( hsurf(4), 'CData', s )

  [ msg, s ] = read4d( 'psv', [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  set( hsurf(5), 'CData', s )

  [ msg, s ] = read4d( 'tn', [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  s = squeeze( s );
  s(1:j-1,1:k-1) = .25 * ( ...
    s(1:j-1,1:k-1) + s(2:j,1:k-1) + ...
    s(1:j-1,2:k)   + s(2:j,2:k) );
  set( hsurf(1), 'CData', s )

  [ msg, s ] = read4d( 'tsm', [ i1 it ], [ i2 it ] );
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

