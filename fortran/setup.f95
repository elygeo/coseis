!------------------------------------------------------------------------------!
! SETUP

subroutine setup
use globals
integer :: i, i1(3), i2(3), j1, j2, k1, k2, l1, l2
real :: theta, scl

if ( any( hypocenter == 0 ) ) hypocenter = npg / 2 + mod( npg, 2 )
if ( nrmdim /= 0 ) npg(nrmdim) = npg(nrmdim) + 1
halo = 1
edge = (/ 1, 1, 1, 1, 1, 1 /)
where ( edge == 0 ) bc = 0
i1 = i1p - halo
i2 = i2p + halo
j1 = i1(1); k1 = i1(2); l1 = i1(3)
j2 = i2(1); k2 = i2(2); l2 = i2(3)
allocate( &
    x(j1:j2,k1:k2,l1:l2,3), &
    u(j1:j2,k1:k2,l1:l2,3), &
    v(j1:j2,k1:k2,l1:l2,3), &
   w1(j1:j2,k1:k2,l1:l2,3), &
   w2(j1:j2,k1:k2,l1:l2,3), &
   s1(j1:j2,k1:k2,l1:l2), &
   s2(j1:j2,k1:k2,l1:l2), &
  rho(j1:j2,k1:k2,l1:l2), &
  lam(j1:j2,k1:k2,l1:l2), &
  miu(j1:j2,k1:k2,l1:l2), &
   yc(j1:j2,k1:k2,l1:l2), &
   yn(j1:j2,k1:k2,l1:l2) )
x   = 0.
u   = 0.
v   = 0.
s1  = 0.
s2  = 0.
w1  = 0.
w2  = 0.
rho = 0.
lam = 0.
miu = 0.
yc  = 0.
yn  = 0.

if ( ipe == 0 ) print '(a)', 'Grid generation'
forall( i=j1+1:j2-1 ) x(i,:,:,1) = i - 2
forall( i=k1+1:k2-1 ) x(:,i,:,2) = i - 2
forall( i=l1+1:l2-1 ) x(:,:,i,3) = i - 2
if ( edge(1) == 1 ) x(j1,:,:,:) = x(j1+1,:,:,:)
if ( edge(2) == 1 ) x(:,k1,:,:) = x(:,k1+1,:,:)
if ( edge(3) == 1 ) x(:,:,l1,:) = x(:,:,l1+1,:)
if ( edge(4) == 1 ) x(j2,:,:,:) = x(j2-1,:,:,:)
if ( edge(5) == 1 ) x(:,k2,:,:) = x(:,k2-1,:,:)
if ( edge(6) == 1 ) x(:,:,l2,:) = x(:,:,l2-1,:)
i = hypocenter(nrmdim)
selectcase( nrmdim )
case( 1 ); x(i:,:,:,1) = x(i:,:,:,1) - 1
case( 2 ); x(:,i:,:,2) = x(:,i:,:,2) - 1
case( 3 ); x(:,:,i:,3) = x(:,:,i:,3) - 1
end select
nop = 1
selectcase( grid )
case 'constant'
  op(1) = 'h'
case 'stretch'
  op(1) = 'r'
  x(:,:,:,3) = 2 * x(:,:,:,3)
case 'slant'
  op(1) = 'g'
  theta = 20. * pi / 180.
  scl = sqrt( cos( theta ) ^ 2. + ( 1. - sin( theta ) ) ^ 2. )
  scl = sqrt( 2. ) / scl
  x(:,:,:,1) = x(:,:,:,1) - x(:,:,:,3) * sin( theta );
  x(:,:,:,3) = x(:,:,:,3) * cos( theta );
  x(:,:,:,1) = x(:,:,:,1) * scl;
  x(:,:,:,3) = x(:,:,:,3) * scl;
case default; stop 'Error: grid'
end select
x = x * dx
i1 = hypocenter
hypoloc = x(i1(1),i2(2),i3(3)) ! TODO: make MPI SAFE

end subroutine

