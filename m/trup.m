% Rupture time plot

meta
i1 = [ 1 1 1 nt ];
i2 = [ nn    nt ];
i = abs( faultnormal );
i1(i) = ihypo(i);
i2(i) = ihypo(i);
[ msg, x ] = read4d( 'x', i1, i2 );
x = mirror( x, bc1, bc2, 1 );
x = squeeze( x );
[ msg, t ] = read4d( 'trup', i1, i2 );
t = mirror( t, bc1, bc2, 0 );
t = squeeze( t );
set( gcf, 'name', 'rupture time' )
v = 0:0.5:7;
[ c, h ] = contour( x(:,:,1), x(:,:,2), t, v );
delete( h );
i  = 1;
while i < size( c, 2 )
  n  = c(2,i);
  c(:,i) = nan;
  i  = i + n + 1;
end
h = plot( c(1,:), c(2,:), 'linewidth', .2 );
axis equal;
axis ij
%axis( xylim )
title( 'rupture time' )
xlabel( 'x (km)' )
ylabel( 'y (km)' )
hold on
plot( 0, 0, 'p', 'markeredgecolor', 'k', 'markerfacecolor', 'w', 'markersize', 11 )

