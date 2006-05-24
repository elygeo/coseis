function [ f ] = fautlread( field )

meta
i1 = [ 1 1 1 nt ];
i2 = [ nn    nt ];
i = abs( faultnormal );
i1(i) = ihypo(i);
i2(i) = ihypo(i);
[ msg, f ] = read4d( field, i1, i2 );
[ msg, x ] = read4d( 'x', i1, i2 );
f = mirror( f, bc1, bc2, 0 );
x = mirror( x, bc1, bc2, 1 );
f = squeeze( f );
x = squeeze( x );
i = x(:,:,1) > -15001 & x(:,:,1) < 15001 & ...
    x(:,:,2) > -7501  & x(:,:,2) < 7501;
n = [ 30000 15000 ] ./ dx + 1;
f = reshape( f(i), n );

