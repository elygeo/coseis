clear all

syms x1 x2 x3 s1 s2 s3 f t v p real

n = [
  sin(f) * cos(t)
  sin(f) * sin(t)
  cos(f)
]

disp( 'tensor' )

dndf = simple( jacobian( n, f ) )
dndt = simple( jacobian( n, t ) )

disp( 'vector' )

r = ( v * cos(f) ) ^ p
x = r * n
dxdf = simple( jacobian( x, f ) );
dxdt = simple( jacobian( x, t ) );
vn = simple( cross( dxdf, dxdt ) );
vn = simple( vn / vn(1) * cos(t) )
vnr = [ 1 1 1-p/(p+1)/cos(f)^2 ]' .* [ x1 x2 x3 ]'
vnr2 = vn ./ x;
vnr2 = vnr2 / vnr2(1) .* [ x1 x2 x3 ]';
check = simple( expand( vnr - vnr2 ) )

