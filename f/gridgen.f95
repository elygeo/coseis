!------------------------------------------------------------------------------!
! GRIDGEN - Grid generation

module gridgen_m
contains
subroutine gridgen
use globals_m

implicit none
real :: theta, scl
real, parameter :: pi = 3.14159

if ( ip == 0 ) print '(a)', 'Grid generation'
x = 0.
downdim = 3

if ( griddir == '' ) then
  i2 = nm
  j = i2(1)
  k = i2(2)
  l = i2(3)
  forall( i=1:j ) x(i,:,:,1)  = i - 1 - offset(1)
  forall( i=1:k ) x(:,i,:,2)  = i - 1 - offset(2)
  forall( i=1:l ) x(:,:,i,3)  = i - 1 - offset(3)
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
    x(:,:,:,3) = 2. * x(:,:,:,3)
  case( 'slant' )
    oper(1) = 'g'
    theta = 20. * pi / 180.
    scl = sqrt( cos( theta ) ** 2. + ( 1. - sin( theta ) ) ** 2. )
    scl = sqrt( 2. ) / scl
    x(:,:,:,1) = x(:,:,:,1) - x(:,:,:,3) * sin( theta );
    x(:,:,:,3) = x(:,:,:,3) * cos( theta );
    x(:,:,:,1) = x(:,:,:,1) * scl;
    x(:,:,:,3) = x(:,:,:,3) * scl;
  case default; stop 'grid'
  end select
  x = x * dx
else
  ! TODO extent to halo
  i1 = i1node
  i2 = i2node
  call bread( 'x', fricdir // '/x1', i1, i2, 0 )
  call bread( 'x', fricdir // '/x2', i1, i2, 0 )
  call bread( 'x', fricdir // '/x3', i1, i2, 0 )
end if

i1 = hypocenter
if ( all( i1 >= i1node .and. i1 <= i2node ) ) then
  j = i1(1)
  k = i1(2)
  l = i1(3)
  xhypo(1) = x(j,k,l,1);
  xhypo(2) = x(j,k,l,2);
  xhypo(3) = x(j,k,l,3);
end if

end subroutine
end module

