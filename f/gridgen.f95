!------------------------------------------------------------------------------!
! GRIDGEN - Grid generation

module gridgen_m
contains
subroutine gridgen
use globals_m
use utils_m

implicit none
real :: theta, scl
real, parameter :: pi = 3.14159

if ( verb > 0 ) print '(a)', 'Grid generation'
x = 0.
downdim = 3
i2 = nl + 2 * nhalo
j = i2(1)
k = i2(2)
l = i2(3)
forall( i=1:j ) x(i,:,:,1)  = i - 1 - offset(1)
forall( i=1:k ) x(:,i,:,2)  = i - 1 - offset(2)
forall( i=1:l ) x(:,:,i,3)  = i - 1 - offset(3)
forall( i=1:2 ) xh(i,:,:,1) = i - 2 - offset(1) + hypocenter(1)
forall( i=1:2 ) xh(:,i,:,2) = i - 2 - offset(2) + hypocenter(2)
forall( i=1:2 ) xh(:,:,i,3) = i - 2 - offset(3) + hypocenter(3)
if ( nrmdim /= 0 ) then
  i = hypocenter(nrmdim) + 1
  select case( nrmdim )
  case( 1 ); x(i:,:,:,1) = x(i:,:,:,1) - 1
  case( 2 ); x(:,i:,:,2) = x(:,i:,:,2) - 1
  case( 3 ); x(:,:,i:,3) = x(:,:,i:,3) - 1
  end select
end if
noper = 1
ioper(1,:) = (/ 1, 1, 1, -1, -1, -1 /)
oper(1) = 'h'
select case( grid )
case( 'constant' )
case( 'stretch' )
  oper(1) = 'r'
  x(:,:,:,3)  = 2. * x(:,:,:,3)
  xh(:,:,:,3) = 2. * xh(:,:,:,3)
case( 'slant' )
  oper(1) = 'g'
  theta = 20. * pi / 180.
  scl = sqrt( cos( theta ) ** 2. + ( 1. - sin( theta ) ) ** 2. )
  scl = sqrt( 2. ) / scl
  x(:,:,:,1)  = x(:,:,:,1)  - x(:,:,:,3)  * sin( theta );
  xh(:,:,:,1) = xh(:,:,:,1) - xh(:,:,:,3) * sin( theta );
  x(:,:,:,3)  = x(:,:,:,3)  * cos( theta );
  xh(:,:,:,3) = xh(:,:,:,3) * cos( theta );
  x(:,:,:,1)  = x(:,:,:,1)  * scl;
  xh(:,:,:,1) = xh(:,:,:,1) * scl;
  x(:,:,:,3)  = x(:,:,:,3)  * scl;
  xh(:,:,:,3) = xh(:,:,:,3) * scl;
case default; stop 'bad grid name'
end select
x  = x * dx
xh = xh * dx

end subroutine
end module

