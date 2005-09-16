!------------------------------------------------------------------------------!
! GRIDGEN - Grid generation

module gridgen_m
contains
subroutine gridgen
use globals_m
use binio_m
use optimize_m

implicit none
real :: theta, scl
real, parameter :: pi = 3.14159
integer :: i, j, k, l, j1, k1, l1, j2, k2, l2, up
real :: lj, lk, ll

if ( ip == 0 ) print '(a)', 'Grid generation'

! Test if hypocenter is located on this processor and save location
do i = 1, 3
  w1(:,:,:,i) = w1(:,:,:,i) - x0(i)
end do
s1 = sqrt( sum( w1 * w1, 4 ) )
i0 = int( x0 / dx + .5 ) + 1 - noff
if ( all( i1 >= i1node .and. i1 <= i2node ) ) hypop = .true.

i1 = i1cell
i2 = i2cell + 1
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

! Read grid files or creat basic rectangular mesh
x = 0.
if ( grid = 'read' ) then
  call bread4( 'data/x1', x, i1, i2, 1 )
  call bread4( 'data/x2', x, i1, i2, 2 )
  call bread4( 'data/x3', x, i1, i2, 3 )
  call optimize
else
  forall( i=j1:j2 ) x(i,:,:,1) = dx * ( i - 1 - noff(1) )
  forall( i=k1:k2 ) x(:,i,:,2) = dx * ( i - 1 - noff(2) )
  forall( i=l1:l2 ) x(:,:,i,3) = dx * ( i - 1 - noff(3) )
  if ( ifn /= 0 ) then
    i = i0(ifn) + 1
    select case( ifn )
    case( 1 ); x(i+1:j2,:,:,1) = x(i:,:,:,1) - dx
    case( 2 ); x(:,i+1:k2,:,2) = x(:,i:,:,2) - dx
    case( 3 ); x(:,:,i+1:l2,3) = x(:,:,i:,3) - dx
    end select
  end if
  noper = 1
  i1oper(1,:) = i1cell
  i2oper(1,:) = i2cell + 1
end if

! Coordinate system
l = maxloc( abs( upvector ) )
if ( ifn == 0 .or. ifn == l )
  k = mod( l + 1, 3 ) + 1
else
  k = ifn
end if
j = 6 - k - l
up = sign( 1, upvector(l) )

! Dimensions
lj = x(j2,k2,l2,j)
lk = x(j2,k2,l2,k)
ll = x(j2,k2,l2,l)

! Mesh models
select case( grid )
case( 'read' )
case( 'constant' )
  oper = 'h'
case( 'stretch' )
  oper = 'r'
  x(:,:,:,l) = 2. * x(:,:,:,l)
case( 'slant' )
  oper = 'g'
  theta = 20. * pi / 180.
  scl = sqrt( cos( theta ) ** 2. + ( 1. - sin( theta ) ) ** 2. )
  scl = sqrt( 2. ) / scl
  x(:,:,:,j) = x(:,:,:,j) - x(:,:,:,l) * sin( theta );
  x(:,:,:,l) = x(:,:,:,l) * cos( theta );
  x(:,:,:,j) = x(:,:,:,j) * scl;
  x(:,:,:,l) = x(:,:,:,l) * scl;
case( 'rand' )
  call random_number( w1 )
  w1 = .2 * ( w1 - .5 )
  w1(2,:,:,1) = 0.; w1(j2,:,:,1) = 0.
  w1(:,2,:,2) = 0.; w1(:,k2,:,2) = 0.
  w1(:,:,2,3) = 0.; w1(:,:,l2,3) = 0.
  j = i0(1)
  k = i0(2)
  l = i0(3)
  select case( ifn )
  case( 1 ); w1(j,:,:,1) = 0.; w1(j+1,:,:,1) = 0.
  case( 2 ); w1(:,k,:,2) = 0.; w1(:,k+1,:,2) = 0.
  case( 3 ); w1(:,:,k,3) = 0.; w1(:,:,k+1,3) = 0.
  end select
  x = x + w1
case( 'spherical' )
case default; stop 'grid'
end select

! Duplicate edge nodes into halo
i2 = i2node
j1 = i2(1) + 1; j2 = i2(1)
k1 = i2(2) + 1; k2 = i2(2)
l1 = i2(3) + 1; l2 = i2(3)
if( bc(1) == 0 ) x(1,:,: ,:) = x(2,:,: ,:)
if( bc(4) == 0 ) x(j1,:,:,:) = x(j2,:,:,:)
if( bc(2) == 0 ) x(:,1,: ,:) = x(:,2,: ,:)
if( bc(5) == 0 ) x(:,k1,:,:) = x(:,k2,:,:)
if( bc(3) == 0 ) x(:,:,1 ,:) = x(:,:,2 ,:)
if( bc(6) == 0 ) x(:,:,l1,:) = x(:,:,l2,:)

end subroutine
end module

