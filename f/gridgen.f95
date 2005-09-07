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
noper = 1
ioper(1,:) = (/ 1, 1, 1, -1, -1, -1 /)

i1 = i1cell
i2 = i2cell + 1
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

if ( griddir /= '' ) then
  oper(1) = 'g'
  call bread( 'x1', griddir, i1, i2 )
  call bread( 'x2', griddir, i1, i2 )
  call bread( 'x3', griddir, i1, i2 )
else
  forall( i=j1:j2 ) x(i,:,:,1)  = i - 1 - offset(1)
  forall( i=k1:k2 ) x(:,i,:,2)  = i - 1 - offset(2)
  forall( i=l1:l2 ) x(:,:,i,3)  = i - 1 - offset(3)
  if ( nrmdim /= 0 ) then
    i = hypocenter(nrmdim) + 1
    select case( nrmdim )
    case( 1 ); x(i:,:,:,1) = x(i:,:,:,1) - 1
    case( 2 ); x(:,i:,:,2) = x(:,i:,:,2) - 1
    case( 3 ); x(:,:,i:,3) = x(:,:,i:,3) - 1
    end select
  end if
  select case( grid )
  case( 'constant' )
    oper(1) = 'h'
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
end if

! Dulicate Edge nodes into halo
j1 = i2(1); j2 = i2(1) - 1
k1 = i2(2); k2 = i2(2) - 1
l1 = i2(3); l2 = i2(3) - 1
if( bc(1) == 0 ) x(1,:,: ,:) = x(2,:,: ,:)
if( bc(4) == 0 ) x(j1,:,:,:) = x(j2,:,:,:)
if( bc(2) == 0 ) x(:,1,: ,:) = x(:,2,: ,:)
if( bc(5) == 0 ) x(:,k1,:,:) = x(:,k2,:,:)
if( bc(3) == 0 ) x(:,:,1 ,:) = x(:,:,2 ,:)
if( bc(6) == 0 ) x(:,:,l1,:) = x(:,:,l2,:)

! Test for hypocenter
i1 = hypocenter
if ( all( i1 >= i1node .and. i1 <= i2node ) ) then
  hypop = .true.
  j = i1(1)
  k = i1(2)
  l = i1(3)
  xhypo(1) = x(j,k,l,1);
  xhypo(2) = x(j,k,l,2);
  xhypo(3) = x(j,k,l,3);
end if

end subroutine
end module

