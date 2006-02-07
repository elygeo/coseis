! Grid generation
module gridgen_m
use optimize_m
use collectiveio_m
use zone_m
contains
subroutine gridgen

implicit none
real :: theta, scl
integer :: i1(3), i2(3), i1l(3), i2l(3), &
  i, j, k, l, j1, k1, l1, j2, k2, l2, idoublenode, up(1)
real :: x1, x2, m(9)
logical :: expand

if ( master ) then
  open( 9, file='log', position='append' )
  write( 9, * ) 'Grid generation'
  close( 9 )
end if

! Single node indexing
idoublenode = 0
i1 = 1  + nnoff
i2 = nn + nnoff
i1l = i1node
i2l = i2node
if ( ifn /= 0 ) then
  i = ihypo(ifn)
  if ( i < i1l(ifn) ) then
    if ( i >= i1(ifn) ) i1(ifn) = i1(ifn) + 1
  else
    if ( i <  i2(ifn) ) i2(ifn) = i2(ifn) - 1
    if ( i <= i2l(ifn) ) idoublenode = ifn
    if ( i <  i2l(ifn) ) i2l(ifn) = i2l(ifn) - 1
  end if
end if
j1 = i1l(1); j2 = i2l(1)
k1 = i1l(2); k2 = i2l(2)
l1 = i1l(3); l2 = i2l(3)

! Read grid files or create basic rectangular mesh
x = 0.
if ( grid /= 'read' ) then
  forall( i=j1:j2 ) x(i,:,:,1) = dx * ( i - i1(1) )
  forall( i=k1:k2 ) x(:,i,:,2) = dx * ( i - i1(2) )
  forall( i=l1:l2 ) x(:,:,i,3) = dx * ( i - i1(3) )
else
  call iovector( 'r', 'data/x1', x, 1, i1, i2, i1l, i2l, 0 )
  call iovector( 'r', 'data/x2', x, 2, i1, i2, i1l, i2l, 0 )
  call iovector( 'r', 'data/x3', x, 3, i1, i2, i1l, i2l, 0 )
end if

! Coordinate system
l = sum( maxloc( abs( upvector ) ) )
up = sign( 1., upvector(l) )
k = modulo( l + 1, 3 ) + 1
j = 6 - k - l

! Grid expansion
expand = .false.
if ( rexpand > 1. ) then
  i1 = i1 + n1expand
  i2 = i2 - n2expand
  if ( any( i1l < i1 ) .or. any( i2 < i2l ) ) expand = .true.
  do j = i1l(1), min( i2l(1), i1(1) - 1 )
    i = i1(1) - j
    x(j,:,:,1) = x(j,1,1,1) + &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do j = max( i1l(1), i2(1) + 1 ), i2l(1)
    i = j - i2(1)
    x(j,:,:,1) = x(j,1,1,1) - &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do k = i1l(2), min( i2l(2), i1(2) - 1 )
    i = i1(2) - k
    x(:,k,:,2) = x(1,k,1,2) + &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do k = max( i1l(2), i2(2) + 1 ), i2l(2)
    i = k - i2(2)
    x(:,k,:,2) = x(1,k,1,2) - &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do l = i1l(3), min( i2l(3), i1(3) - 1 )
    i = i1(3) - l
    x(:,:,l,3) = x(1,1,l,3) + &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do l = max( i1l(3), i2(3) + 1 ), i2l(3)
    i = l - i2(3)
    x(:,:,l,3) = x(1,1,l,3) - &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
end if

! Grid transformation
m = sqrt( gridtrans(1:9) / gridtrans(10) )
w1(:,:,:,1) = m(1) * x(:,:,:,1) + m(2) * x(:,:,:,2) + m(3) * x(:,:,:,3)
w1(:,:,:,2) = m(4) * x(:,:,:,1) + m(5) * x(:,:,:,2) + m(6) * x(:,:,:,3)
w1(:,:,:,3) = m(7) * x(:,:,:,1) + m(8) * x(:,:,:,2) + m(9) * x(:,:,:,3)
x = w1

! Mesh type
select case( grid )
case( 'read' )
case( 'constant' )
case( 'hill' )
case( 'spherical' )
case default; stop 'grid'
end select

! Random noise added to mesh
if ( gridnoise > 0. ) then
  call random_number( w1 )
  w1 = gridnoise * ( w1 - .5 )
  if ( ibc1(1) <= 1 ) w1(j1,:,:,1) = 0.
  if ( ibc2(1) <= 1 ) w1(j2,:,:,1) = 0.
  if ( ibc1(2) <= 1 ) w1(:,k1,:,2) = 0.
  if ( ibc2(2) <= 1 ) w1(:,k2,:,2) = 0.
  if ( ibc1(3) <= 1 ) w1(:,:,l1,3) = 0.
  if ( ibc2(3) <= 1 ) w1(:,:,l2,3) = 0.
  select case( idoublenode )
  case( 1 ); i = ihypo(1); w1(i,:,:,1) = 0.
  case( 2 ); i = ihypo(2); w1(:,i,:,2) = 0.
  case( 3 ); i = ihypo(3); w1(:,:,i,3) = 0.
  end select
  x = x + w1
end if

! Halo
do i = 1, nhalo
  if ( ibc1(1) == 2 ) then
    x(j1-i,:,:,:) = x(j1+i,:,:,:)
    x(j1-i,:,:,1) = 2 * x(j1,:,:,1) - x(j1+i,:,:,1)
  else
    x(j1-i,:,:,:) = ( i + 1 ) * x(j1,:,:,:) - i * x(j1+1,:,:,:)
  end if
  if ( ibc2(1) == 2 ) then
    x(j2+i,:,:,:) = x(j2-i,:,:,:)
    x(j2+i,:,:,1) = 2 * x(j2,:,:,1) - x(j2-i,:,:,1)
  else
    x(j2+i,:,:,:) = ( i + 1 ) * x(j2,:,:,:) - i * x(j2-1,:,:,:)
  end if
  if ( ibc1(2) == 2 ) then
    x(:,k1-i,:,:) = x(:,k1+i,:,:)
    x(:,k1-i,:,2) = 2 * x(:,k1,:,2) - x(:,k1+i,:,2)
  else
    x(:,k1-i,:,:) = ( i + 1 ) * x(:,k1,:,:) - i * x(:,k1+1,:,:)
  end if
  if ( ibc2(2) == 2 ) then
    x(:,k2+i,:,:) = x(:,k2-i,:,:)
    x(:,k2+i,:,2) = 2 * x(:,k2,:,2) - x(:,k2-i,:,2)
  else
    x(:,k2+i,:,:) = ( i + 1 ) * x(:,k2,:,:) - i * x(:,k2-1,:,:)
  end if
  if ( ibc1(3) == 2 ) then
    x(:,:,l1-i,:) = x(:,:,l1+i,:)
    x(:,:,l1-i,3) = 2 * x(:,:,l1,3) - x(:,:,l1+i,3)
  else
    x(:,:,l1-i,:) = ( i + 1 ) * x(:,:,l1,:) - i * x(:,:,l1+1,:)
  end if
  if ( ibc2(3) == 2 ) then
    x(:,:,l2+i,:) = x(:,:,l2-i,:)
    x(:,:,l2+i,3) = 2 * x(:,:,l2,3) - x(:,:,l2-i,3)
  else
    x(:,:,l2+i,:) = ( i + 1 ) * x(:,:,l2,:) - i * x(:,:,l2-1,:)
  end if
end do
call swaphalovector( x, nhalo )

! Create fault double nodes
select case( idoublenode )
case( 1 ); j = ihypo(1); x(j+1:j2+1,:,:,:) = x(j:j2,:,:,:)
case( 2 ); k = ihypo(2); x(:,k+1:k2+1,:,:) = x(:,k:k2,:,:)
case( 3 ); l = ihypo(3); x(:,:,l+1:l2+1,:) = x(:,:,l:l2,:)
end select

! Assign fast operators to rectangular mesh portions
noper = 1
i1oper(1,:) = i1cell
i2oper(1,:) = i2cell + 1
call optimize

! Hypocenter location
if ( all( xhypo < 0. ) ) then
  if ( master ) then
    j = ihypo(1)
    k = ihypo(2)
    l = ihypo(3)
    xhypo = x(j,k,l,:)
  end if
  call broadcast( xhypo )
end if

! Grid Dimensions
do i = 1,3
  x1 = minval( x(:,:,:,i) )
  x2 = maxval( x(:,:,:,i) )
  call pmin( x1 )
  call pmax( x2 )
  xcenter(i) = ( x1 + x2 ) / 2.
  w1(:,:,:,i) = x(:,:,:,i) - xcenter(i);
end do
s1 = sum( w1 * w1, 4 );
rmax = sqrt( maxval( s1 ) )

end subroutine
end module

