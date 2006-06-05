function [ xx, ff ] = fautlread( field )

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
i = find( x(:,:,:,:,jk(1)) > -15001 & x(:,:,:,:,jk(1)) < 15001 & ...
          x(:,:,:,:,jk(2)) > -7501  & x(:,:,:,:,jk(2)) < 7501 );
n = [ 30000 15000 ] ./ dx;
if fixhypo == 1, n = n + 1; end
nn = size( x );
nn = prod( nn(1:3) );
for ii = 1:3
  xx(:,:,ii) = .001 * reshape( x(i+nn*ii-nn), n );
end
for ii = 1:size( f, 5 )
  ff(:,:,ii) = reshape( f(i+nn*ii-nn), n );
end

