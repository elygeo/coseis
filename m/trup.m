% Rupture time plot

set( gcf, 'Name', 'Rupture Time' )
v = 0:0.5:7;
meta
currentstep
for i = 1 : length( out ) + 1
  if strcmp( out{i}{2}, 'trup' ), break, end
end
it = it - mod( it, out{i}{3} );
i1 = [ out{i}{4:6} it ];
i2 = [ out{i}{7:9} it ];
l = abs( faultnormal );
j = max( 1, 3 - l );
k = 6 - j - l;
i1(l) = ihypo(l);
i2(l) = ihypo(l);
[ msg, t ] = read4d( 'trup', i1, i2 );
t = squeeze( t );
%t = squeeze( t ) + 1.5 * dt;
i1(4) = 1;
i2(4) = 1;
[ msg, x ] = read4d( 'x', i1, i2 );
x = squeeze( x(:,:,:,[j k]) ) / 1000.;
n = size( t );
j2 = n(1);
k2 = n(2);
xylim = [ -15 15 -7.5 7.5 ];
if ( abs( bc2(j) ) == 3 )
  t(j2+1:2*j2-1,:)   = t(j2-1:-1:1,:);
  x(j2+1:2*j2-1,:,2) = x(j2-1:-1:1,:,2);
  x(j2+1:2*j2-1,:,1) = 2 * x(j2,k2,1) - x(j2-1:-1:1,:,1);
  xylim(2) = 0;
end
if ( abs( bc2(k) ) == 3 )
  t(:,k2+1:2*k2-1)   = t(:,k2-1:-1:1);
  x(:,k2+1:2*k2-1,1) = x(:,k2-1:-1:1,1);
  x(:,k2+1:2*k2-1,2) = 2 * x(j2,k2,2) - x(:,k2-1:-1:1,2);
  xylim(4) = 0;
end
[ c, h ] = contour( x(:,:,1), x(:,:,2), t, v );
delete( h );
i  = 1;
while i < size( c, 2 )
  n  = c(2,i);
  c(:,i) = NaN;
  i  = i + n + 1;
end
h = plot( c(1,:), c(2,:), 'Linewidth', .2 );
axis equal;
axis ij
axis( xylim )
title( 'Rupture Time' )
xlabel( 'X (km)' )
ylabel( 'Y (km)' )
hold on
plot( 0, 0, 'p', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'MarkerSize', 11 )

