%------------------------------------------------------------------------------%
% OUTLINEVIZ

lines = volumes;
lineviz
houtline = hand;
i = halo1 + 1;
xg = double( squeeze( x(i(1),i(2),i(3),:) + xscl * u(i(1),i(2),i(3),:) ) );
xg = [ xg xg + xmax / 16 xg + xmax / 15 ];
j = [ 4 1 1 1 1 ];
k = [ 2 2 5 2 2 ];
l = [ 3 3 3 3 6 ];
houtline(2) = plot3( xg(j), xg(k), xg(l) );
j = [ 7 1 1 ];
k = [ 2 8 2 ];
l = [ 3 3 9 ];
houtline(3:5) = text( xg(j), xg(k), xg(l), ['xyz']', 'Ver', 'middle' );
set( houtline, 'Tag', 'outline' )

