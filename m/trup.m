% Rupture time plot

xi = [  -15 : .1 : 15  ];
yi = [ -7.5 : .1 : 7.5 ];
t = faultread( 'trup' )
set( gcf, 'Name', 'Rupture Time' )
v = 0:0.5:7;
[ c, h ] = contour( xi, yi, t, v );
delete( h );
i  = 1;
while i < size( c, 2 )
  n  = c(2,i);
  c(:,i) = nan;
  i  = i + n + 1;
end
h = plot( c(1,:), c(2,:), 'k', 'linewidth', .2 );
axis image;
axis( [ -15 15 -7.5 7.5 ] )
title( 'Rupture Time' )
xlabel( 'X (km)' )
ylabel( 'Y (km)' )
hold on
plot( 0, 0, 'p', 'markeredgecolor', 'k', 'markerfacecolor', 'w', 'markersize', 11 )

