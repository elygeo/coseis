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
integer :: i, j, k, l, i1(3), j1, k1, l1, i2(3), j2, k2, l2, up
real :: lj, lk, ll

if ( ip == 0 ) print '(a)', 'Grid generation'

! Indices
i1 = i1cell
i2 = i2cell + 1
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1oper(1,:) = i1
i2oper(1,:) = i2

! Read grid files or creat basic rectangular mesh
x = 0.
if ( grid == 'read' ) then
  call bread4( 'data/x1', x, i1, i2, 1 )
  call bread4( 'data/x2', x, i1, i2, 2 )
  call bread4( 'data/x3', x, i1, i2, 3 )
  call optimize
else
  forall( i=j1:j2 ) x(i,:,:,1) = dx * ( i - 1 - noff(1) )
  forall( i=k1:k2 ) x(:,i,:,2) = dx * ( i - 1 - noff(2) )
  forall( i=l1:l2 ) x(:,:,i,3) = dx * ( i - 1 - noff(3) )
  if ( ifn /= 0 ) then
    i = ihypo(ifn) + 1
    select case( ifn )
    case( 1 ); x(i+1:j2,:,:,:) = x(i:j2-1,:,:,:)
    case( 2 ); x(:,i+1:k2,:,:) = x(:,i:k2-1,:,:)
    case( 3 ); x(:,:,i+1:l2,:) = x(:,:,i:l2-1,:)
    end select
  end if
  noper = 1
  i1oper(1,:) = i1cell
  i2oper(1,:) = i2cell + 1
end if

! Coordinate system
l  = abs( upward )
up = sign( 1, upward )
if ( ifn == 0 .or. ifn == l ) then
  k = mod( l + 1, 3 ) + 1
else
  k = ifn
end if
j = 6 - k - l

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
  ! note: does not work for domain decomposition
  ! would have to swap edge values
  oper = 'g'
  call random_number( w1 )
  w1 = .2 * ( w1 - .5 )
  w1(j1,:,:,1) = 0.; w1(j2,:,:,1) = 0.
  w1(:,k1,:,2) = 0.; w1(:,k2,:,2) = 0.
  w1(:,:,l1,3) = 0.; w1(:,:,l2,3) = 0.
  j = ihypo(1)
  k = ihypo(2)
  l = ihypo(3)
  select case( ifn )
  case( 1 ); w1(j,:,:,1) = 0.; w1(j+1,:,:,1) = 0.
  case( 2 ); w1(:,k,:,2) = 0.; w1(:,k+1,:,2) = 0.
  case( 3 ); w1(:,:,k,3) = 0.; w1(:,:,k+1,3) = 0.
  end select
  x = x + w1
case( 'spherical' )
case default; stop 'grid'
end select

! Duplicate edge nodes into halo, but not for decomp edges
if( ip3(1) == 0         ) x(j1-1,:,:,:) = x(j1,:,:,:)
if( ip3(1) == np(1) - 1 ) x(j2+1,:,:,:) = x(j2,:,:,:)
if( ip3(2) == 0         ) x(:,j1-1,:,:) = x(:,j1,:,:)
if( ip3(2) == np(2) - 1 ) x(:,k2+1,:,:) = x(:,k2,:,:)
if( ip3(3) == 0         ) x(:,:,j1-1,:) = x(:,:,j1,:)
if( ip3(3) == np(3) - 1 ) x(:,:,l2+1,:) = x(:,:,l2,:)

! Find hypocenter node, FIXME do this before splitting nodes!
do i = 1, 3
  w1(:,:,:,i) = w1(:,:,:,i) - xhypo(i)
end do
s1 = sqrt( sum( w1 * w1, 4 ) )
ihypo  = minloc( s1 );
if ( ifn ) ihypo(ifn) = ifault

! FIXME split nodes here

! Input zones
if ( nin > nz ) stop 'too many input zone, make nz bigger'
do i = 1, nin
  call zone( i1in(i,:), i2in(i,:), nn, noff, ihypo, ifn )
end do

! Output zones
if ( nout > nz ) stop 'too many output zones, make nz bigger'
do i = 1, nout
  call zone( i1out(i,:), i2out(i,:), nn, noff, ihypo, ifn )
end do

! Locked nodes
if ( nlock > nz ) stop 'too many lock zones, make nz bigger'
do i = 1, nlock
  call zone( i1lock(i,:), i2lock(i,:), nn, noff, ihypo, ifn )
end do


end subroutine
end module

