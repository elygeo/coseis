% Modulate Colormap

function cmapmod( n, lim )

cmap = colormap;
h = 1 / ( size( cmap, 1 ) - 1 );
w1 = lim * cos( pi * 2 * n * ( 0:h:1 )' );
w1 = 1 - max( w1, 0 );
w2 = 1 + min( w1, 0 );
for i = 1:3
  cmap(:,i) = ( 1 - w2 .* ( 1 - w1 .* cmap(:,i) ) );
end
colormap( cmap )

