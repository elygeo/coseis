!------------------------------------------------------------------------------!
! GRIDGEN - Grid generation

subroutine gridgen

use globals
implicit none
real :: theta, scl
real, parameter :: pi = 3.14159

if ( verb > 0 ) print '(a)', 'Grid generation'
downdim = 3
i1 = i1node - nhalo
i2 = i2node + nhalo
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
print *, i1, i2
allocate( &
   s1(j1:j2,k1:k2,l1:l2), &
   s2(j1:j2,k1:k2,l1:l2), &
    x(j1:j2,k1:k2,l1:l2,3), &
    v(j1:j2,k1:k2,l1:l2,3), &
    u(j1:j2,k1:k2,l1:l2,3), &
   w1(j1:j2,k1:k2,l1:l2,3), &
   w2(j1:j2,k1:k2,l1:l2,3) &
 )
x = 0.
forall( i=j1:j2 ) x(i,:,:,1) = i - 1
forall( i=k1:k2 ) x(:,i,:,2) = i - 1
forall( i=l1:l2 ) x(:,:,i,3) = i - 1
i = hypocenter(nrmdim) + 1
selectcase( nrmdim )
case( 1 ); x(i:,:,:,1) = x(i:,:,:,1) - 1
case( 2 ); x(:,i:,:,2) = x(:,i:,:,2) - 1
case( 3 ); x(:,:,i:,3) = x(:,:,i:,3) - 1
end select
hypoloc = hypocenter
noper = 1
ioper(1,:) = (/ 1, 1, 1, -1, -1, -1 /)
oper(1) = 'h'
selectcase( grid )
case('constant')
case('stretch')
  oper(1) = 'r'
  x(:,:,:,3) = 2. * x(:,:,:,3)
  hypoloc(3) = 2. * hypoloc(3)
case('slant')
  oper(1) = 'g'
  theta = 20. * pi / 180.
  scl = sqrt( cos( theta ) ** 2. + ( 1. - sin( theta ) ) ** 2. )
  scl = sqrt( 2. ) / scl
  x(:,:,:,1) = x(:,:,:,1) - x(:,:,:,3) * sin( theta );
  x(:,:,:,3) = x(:,:,:,3) * cos( theta );
  x(:,:,:,1) = x(:,:,:,1) * scl;
  x(:,:,:,3) = x(:,:,:,3) * scl;
  hypoloc(1) = hypoloc(1) - hypoloc(3) * sin( theta );
  hypoloc(3) = hypoloc(3) * cos( theta );
  hypoloc(1) = hypoloc(1) * scl;
  hypoloc(3) = hypoloc(3) * scl;
case default; stop 'bad grid name'
end select
x = x * dx
hypoloc = hypoloc * dx

end subroutine

