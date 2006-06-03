function [ x, y, f ] = fautlread( field )

meta
i1 = [ 1 1 1 nt ];
i2 = [ nn    nt ];
i = abs( faultnormal );
i1(i) = ihypo(i);
i2(i) = ihypo(i);
bc1(i) = 0;
bc2(i) = 0;
[ msg, x ] = read4d( 'x', i1, i2 );
[ msg, f ] = read4d( field, i1, i2 );
x = mirror( x, bc1, bc2, 1 );
f = mirror( f, bc1, bc2, 0 );
jk = 1:3;
jk(i) = [];
y = squeeze( x(:,:,:,:,jk(2)) );
x = squeeze( x(:,:,:,:,jk(1)) );
f = squeeze( f );
i = x > -15001 & x < 15001 & ...
    y > -7501  & y < 7501;
n = [ 30000 15000 ] ./ dx;
if fixhypo == 1, n = n + 1; end
f = reshape( f(i), n );
x = .001 * reshape( x(i), n );
y = .001 * reshape( y(i), n );

