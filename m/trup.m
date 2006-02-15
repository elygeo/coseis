
figure
set( gcf, ...
  'Name', 'Rupture Time', ...
  'DefaultLineLinewidth', .001 );
v = 0:0.5:12;

cwd = pwd;
srcdir
cd dalguer

if 1
  n = [ 601 301 ];
  dx = .05;
  fid = fopen( 'DFM005paper' );
  t = fscanf( fid,'%g', n )';
  fclose( fid );
  x = dx * ( 0:n(1)-1 );  x = x - .5 * x(end);
  y = dx * ( 0:n(2)-1 );  y = y - .5 * y(end);
  [ c, h ] = contour( x, y, t, v, 'k:', 'LineWidth', .1 );
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

if 1
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
i1 = [ 21 21 21 900 ];
i2 = [ -1 -1 -1 900 ];
meta
i = abs( faultnormal );
i1(i) = ihypo(i);
i2(i) = ihypo(i);
[ t, msg ] = read4d( 'trup', i1, i2 );
t = squeeze( t' ) + dt;
%t = [ t  t(:,end:-1:1) ];
%t = [ t; t(end:-1:1,:) ];
t = [ t  t(:,end-1:-1:1) ];
t = [ t; t(end-1:-1:1,:) ];
x = dx / 1000 * ( 0:size(t,2)-1 );  x = x - .5 * x(end);
y = dx / 1000 * ( 0:size(t,1)-1 );  y = y - .5 * y(end);
[ c, h ] = contour( x, y, t, v );
%clabel( c, h )
delete( h );
i  = 1;
while i < size( c, 2 )
  n  = c(2,i);
  c(:,i) = NaN;
  i  = i + n + 1;
end
plot( c(1,:), c(2,:), 'r' )

axis equal;
axis ij
axis( [ -15 15 -7.5 7.5 ] )
plot( 0, 0, 'p', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'MarkerSize', 11 )
title( 'Rupture Time' )
hold on

drawnow
%print -depsc2 trup

