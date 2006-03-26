% Rupture time plot

[ x, t, xylim ] = trupread;
set( gcf, 'Name', 'Rupture Time' )
v = 0:0.5:7;
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

