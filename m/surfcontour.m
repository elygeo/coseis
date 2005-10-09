% Surface contouring

function h = ssurfcontour( xg, c, v )

x = xg(:,:,1);
y = xg(:,:,2);
z = xg(:,:,3);
[ xi, yi ] = ndgrid( 1:size(x,1), 1:size(x,2) );
[ c, h ]   = contour( xi, yi, c, [ v v ], '-k' );
delete( h );
i  = 1;
ci = [];
while i < size( c, 2 )
  n  = c(2,i);
  ci = [ ci; i + 1 i + n ];
  i  = i + n + 1;
end
xx = [];
yy = [];
zz = [];
for i = 1:size( ci, 1 )
  cx = c(1,ci(i,1):ci(i,2))';
  cy = c(2,ci(i,1):ci(i,2))';
  j0 = floor( cx );
  k0 = floor( cy );
  j1 = ceil( cx );
  k1 = ceil( cy );
  dx = cx - j0;
  dy = cy - k0;
  k0 = ( k0 - 1 ) * size( x, 1 );
  k1 = ( k1 - 1 ) * size( x, 1 );

  xx = [ xx; NaN; ...
       ( x(j0+k1) + dx .* ( x(j1+k1) - x(j0+k1) ) ) .* dy + ...
       ( x(j0+k0) + dx .* ( x(j1+k0) - x(j0+k0) ) ) .* ( 1 - dy ) ];

  yy = [ yy; NaN; ...
       ( y(j0+k1) + dx .* ( y(j1+k1) - y(j0+k1) ) ) .* dy + ...
       ( y(j0+k0) + dx .* ( y(j1+k0) - y(j0+k0) ) ) .* ( 1 - dy ) ];

  zz = [ zz; NaN; ...
       ( z(j0+k1) + dx .* ( z(j1+k1) - z(j0+k1) ) ) .* dy + ...
       ( z(j0+k0) + dx .* ( z(j1+k0) - z(j0+k0) ) ) .* ( 1 - dy ) ];
end
h = plot3( xx, yy, zz, '-' );

