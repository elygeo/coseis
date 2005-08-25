!------------------------------------------------------------------------------!
! GRIDGEN - Grid generation

module gridgen_m
contains
subroutine gridgen
use globals_m

implicit none
real :: theta, scl
real, parameter :: pi = 3.14159

if ( verb > 0 ) print '(a)', 'Grid generation'
downdim = 3
i2 = nl + 2 * nhalo
j = i2(1)
k = i2(2)
l = i2(3)
allocate( &
   s1(j,k,l), &
   s2(j,k,l), &
   w1(j,k,l,3), &
   w2(j,k,l,3), &
    x(j,k,l,3), &
    v(j,k,l,3), &
    u(j,k,l,3) )
x = 0.
forall( i=1:j ) x(i,:,:,1) = i - 1 - offset(1)
forall( i=1:k ) x(:,i,:,2) = i - 1 - offset(2)
forall( i=1:l ) x(:,:,i,3) = i - 1 - offset(3)
if ( nrmdim /= 0 ) then
  i = hypocenter(nrmdim) + 1
  select case( nrmdim )
  case( 1 ); x(i:,:,:,1) = x(i:,:,:,1) - 1
  case( 2 ); x(:,i:,:,2) = x(:,i:,:,2) - 1
  case( 3 ); x(:,:,i:,3) = x(:,:,i:,3) - 1
  end select
end if
hypoloc = hypocenter - 1 - offset
noper = 1
ioper(1,:) = (/ 1, 1, 1, -1, -1, -1 /)
oper(1) = 'h'
select case( grid )
case( 'constant' )
case( 'stretch' )
  oper(1) = 'r'
  x(:,:,:,3) = 2. * x(:,:,:,3)
  hypoloc(3) = 2. * hypoloc(3)
case( 'slant' )
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
end module

