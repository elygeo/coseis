
figure
set( gcf, ...
  'Name', 'Rupture Time', ...
  'DefaultLineLinewidth', .001 );
v = 0:0.5:7;

cwd = pwd;
srcdir
cd dalguer

if 0
  n = [ 601 301 ];
  dx = .05;
  fid = fopen( 'DFM005paper' );
  t = fscanf( fid,'%g', n )';
  fclose( fid );
  x = dx * ( 0:n(1)-1 );  x = x - .5 * x(end);
  y = dx * ( 0:n(2)-1 );  y = y - .5 * y(end);
  [ c, h ] = contour( x, y, t, v );
  delete( h );
  i  = 1;
  while i < size( c, 2 )
    n  = c(2,i);
    c(:,i) = NaN;
    i  = i + n + 1;
  end
  plot( c(1,:), c(2,:), 'b', 'LineWidth', .01 )
  hold on
end

if 1
  n = [ 301 151 ];
  dx = .1;
  fid = fopen( 'DFM01paper' );
  t = fscanf( fid,'%g', n )';
  fclose( fid );
  x = dx * ( 0:n(1)-1 );  x = x - .5 * x(end);
  y = dx * ( 0:n(2)-1 );  y = y - .5 * y(end);
  [ c, h ] = contour( x, y, t, v );
  delete( h );
  i  = 1;
  while i < size( c, 2 )
    n  = c(2,i);
    c(:,i) = NaN;
    i  = i + n + 1;
  end
  plot( c(1,:), c(2,:), 'k', 'LineWidth', .01 )
  hold on
end

if 0
  n = [ 300 150 ];
  dx = .1;
  fid = fopen( 'BI01paper' );
  t = fscanf( fid,'%g', n )';
  fclose( fid );
  x = dx * ( 0:n(1)-1 );  x = x - .5 * x(end);
  y = dx * ( 0:n(2)-1 );  y = y - .5 * y(end);
  [ c, h ] = contour( x, y, t, v );
  delete( h );
  i  = 1;
  while i < size( c, 2 )
    n  = c(2,i);
    c(:,i) = NaN;
    i  = i + n + 1;
  end
  plot( c(1,:), c(2,:), 'g', 'LineWidth', .01 )
  hold on
end

cd( cwd )
i1 = [  1  1  1 800 ];
i2 = [ -1 -1 -1 800 ];
meta
l = abs( faultnormal );
j = max( 1, 3 - l );
k = 6 - j - l;
i1(l) = ihypo(l);
i2(l) = ihypo(l);
[ t, msg ] = read4d( 'trup', i1, i2 );
t = squeeze( t ) + dt;
i1(4) = 1;
i2(4) = 1;
[ x, msg ] = read4d( 'x', i1, i2 );
x = squeeze( x(:,:,:,[j k]) ) / 1000.;
bc = abs( bc2([j k]) );
n = size( t );
j = 1:n(1);
k = 1:n(2);
switch bc(1)
case 2; j = [ 1:n(1) n(1):-1:1 ];
case 3; j = [ 1:n(1) n(1)-1:-1:1 ];
end
switch bc(2)
case 2; k = [ 1:n(2) n(2):-1:1 ];
case 3; k = [ 1:n(2) n(2)-1:-1:1 ];
end
bc1
bc2
bc
[ c, h ] = contour( x(j,k,1), x(j,k,2), t(j,k), v );
set( h, 'Visible', 'off' )
i  = 1;
while i < size( c, 2 )
  n  = c(2,i);
  c(:,i) = NaN;
  i  = i + n + 1;
end
plot( c(1,:), c(2,:), 'r' )
clabel( c, h )
%delete( h );

axis equal;
axis ij
axis( [ -15 15 -7.5 7.5 ] )
plot( 0, 0, 'p', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'MarkerSize', 11 )
title( 'Rupture Time' )
hold on

drawnow
%print -depsc2 trup

