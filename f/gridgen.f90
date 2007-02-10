! Grid generation
module m_gridgen
implicit none
contains

subroutine gridgen
use m_globals
use m_optimize
use m_collective
integer :: i1(3), i2(3), i3(3), i4(3), n(3), i, j, k, l, &
  j1, k1, l1, j2, k2, l2, idoublenode
real :: x0(3), xlim(6), gxlim(6), m(9)
logical :: expand

if ( master ) write( 0, * ) 'Grid generation'

! Single node indexing
idoublenode = 0
i1 = 1  + nnoff
i2 = nn + nnoff
i3 = i1node
i4 = i2node
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ihypo(i) < i3(i) ) then
    if ( ihypo(i) >= i1(i) ) i1(i) = i1(i) + 1
  else
    if ( ihypo(i) <  i2(i) ) i2(i) = i2(i) - 1
    if ( ihypo(i) <= i4(i) ) idoublenode = i
    if ( ihypo(i) <  i4(i) ) i4(i) = i4(i) - 1
  end if
end if
j1 = i3(1); j2 = i4(1)
k1 = i3(2); k2 = i4(2)
l1 = i3(3); l2 = i4(3)

! Read grid files or create basic rectangular mesh
x = 0.
if ( grid /= 'read' ) then
  forall( i=j1:j2 ) x(i,:,:,1) = dx * ( i - i1(1) )
  forall( i=k1:k2 ) x(:,i,:,2) = dx * ( i - i1(2) )
  forall( i=l1:l2 ) x(:,:,i,3) = dx * ( i - i1(3) )
else
  call vectorio( 'r', 'data/x1', x, 1, 1, i1, i2, i3, i4, 0 )
  call vectorio( 'r', 'data/x2', x, 2, 1, i1, i2, i3, i4, 0 )
  call vectorio( 'r', 'data/x3', x, 3, 1, i1, i2, i3, i4, 0 )
end if

! Coordinate system
!l = sum( maxloc( abs( upvector ) ) )
!up = sign( 1., upvector(l) )
!k = modulo( l + 1, 3 ) + 1
!j = 6 - k - l

! Grid expansion
expand = .false.
if ( rexpand > 1. ) then
  i1 = i1 + n1expand
  i2 = i2 - n2expand
  if ( any( i3 < i1 ) .or. any( i2 < i4 ) ) expand = .true.
  do j = i3(1), min( i4(1), i1(1) - 1 )
    i = i1(1) - j
    x(j,:,:,1) = x(j,1,1,1) + &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do j = max( i3(1), i2(1) + 1 ), i4(1)
    i = j - i2(1)
    x(j,:,:,1) = x(j,1,1,1) - &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do k = i3(2), min( i4(2), i1(2) - 1 )
    i = i1(2) - k
    x(:,k,:,2) = x(1,k,1,2) + &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do k = max( i3(2), i2(2) + 1 ), i4(2)
    i = k - i2(2)
    x(:,k,:,2) = x(1,k,1,2) - &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do l = i3(3), min( i4(3), i1(3) - 1 )
    i = i1(3) - l
    x(:,:,l,3) = x(1,1,l,3) + &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do l = max( i3(3), i2(3) + 1 ), i4(3)
    i = l - i2(3)
    x(:,:,l,3) = x(1,1,l,3) - &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
end if

! Affine grid transformation
m = sign( 1., affine(1:9) ) * sqrt( abs( affine(1:9) / affine(10) ) )
w2(:,:,:,1) = m(1) * x(:,:,:,1) + m(2) * x(:,:,:,2) + m(3) * x(:,:,:,3)
w2(:,:,:,2) = m(4) * x(:,:,:,1) + m(5) * x(:,:,:,2) + m(6) * x(:,:,:,3)
w2(:,:,:,3) = m(7) * x(:,:,:,1) + m(8) * x(:,:,:,2) + m(9) * x(:,:,:,3)
x = w2

! Mesh type
select case( grid )
case( 'read' )
case( 'constant' )
case( 'hill' )
case( 'spherical' )
end select

! Symmetry
i1 = ( i3 + i4 ) / 2
i2 = ( i3 + i4 + 1 ) / 2
n  = ( i4 - i3 + 1 ) / 2
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
symmetry = max( min( symmetry, 1 ), -1 )
where( i1 /= i2 ) symmetry = 2 * symmetry
if( any( symmetry /= 0 .and. np /= 1 ) ) stop 'np(i) must = 1 for symmetry(i)'
j = symmetry(1)
k = symmetry(2)
l = symmetry(3)
if ( j > 0 ) forall( i=1:n(1) ) x(j1+i,:,:,:) = x(j2-i,:,:,:)
if ( k > 0 ) forall( i=1:n(2) ) x(:,k1+i,:,:) = x(:,k2-i,:,:)
if ( l > 0 ) forall( i=1:n(3) ) x(:,:,l1+i,:) = x(:,:,l2-i,:)
if ( j < 0 ) forall( i=1:n(1) ) x(j1+i,:,:,:) = x(j1,:,:,:)
if ( k < 0 ) forall( i=1:n(2) ) x(:,k1+i,:,:) = x(:,k1,:,:)
if ( l < 0 ) forall( i=1:n(3) ) x(:,:,l1+i,:) = x(:,:,l1,:)
if ( abs( j ) == 1 ) forall( i=1:n(1) ) x(j1+i,:,:,1) = -x(j2-i,:,:,1) + 2 * x(j1,:,:,1)
if ( abs( k ) == 1 ) forall( i=1:n(2) ) x(:,k1+i,:,2) = -x(:,k2-i,:,2) + 2 * x(:,k1,:,2)
if ( abs( l ) == 1 ) forall( i=1:n(3) ) x(:,:,l1+i,3) = -x(:,:,l2-i,3) + 2 * x(:,:,l1,3)
if ( abs( j ) == 2 ) forall( i=1:n(1) ) x(j1+i,:,:,1) = -x(j2-i,:,:,1) + 3 * x(j1,:,:,1) - x(j1-1,:,:,1)
if ( abs( k ) == 2 ) forall( i=1:n(2) ) x(:,k1+i,:,2) = -x(:,k2-i,:,2) + 3 * x(:,k1,:,2) - x(:,k1-1,:,2)
if ( abs( l ) == 2 ) forall( i=1:n(3) ) x(:,:,l1+i,3) = -x(:,:,l2-i,3) + 3 * x(:,:,l1,3) - x(:,:,l1-1,3)

! Boundary conditions
j = ihypo(1)
k = ihypo(2)
l = ihypo(3)
i1 = abs( ibc1 )
i2 = abs( ibc2 )
j1 = i3(1); j2 = i4(1)
k1 = i3(2); k2 = i4(2)
l1 = i3(3); l2 = i4(3)

! Random noise added to mesh
if ( gridnoise > 0. ) then
  call random_number( w2 )
  w2 = gridnoise * ( w2 - .5 )
  if ( i1(1) <= 1 ) w2(j1,:,:,1) = 0.
  if ( i2(1) <= 1 ) w2(j2,:,:,1) = 0.
  if ( i1(2) <= 1 ) w2(:,k1,:,2) = 0.
  if ( i2(2) <= 1 ) w2(:,k2,:,2) = 0.
  if ( i1(3) <= 1 ) w2(:,:,l1,3) = 0.
  if ( i2(3) <= 1 ) w2(:,:,l2,3) = 0.
  select case( idoublenode )
  case( 1 ); w2(j,:,:,1) = 0.
  case( 2 ); w2(:,k,:,2) = 0.
  case( 3 ); w2(:,:,l,3) = 0.
  end select
  x = x + w2
end if

! Free surface BC
if ( i1(1) <= 1 ) forall( i=1:nhalo ) x(j1-i,:,:,:) = x(j1,:,:,:)
if ( i1(2) <= 1 ) forall( i=1:nhalo ) x(:,k1-i,:,:) = x(:,k1,:,:)
if ( i1(3) <= 1 ) forall( i=1:nhalo ) x(:,:,l1-i,:) = x(:,:,l1,:)
if ( i2(1) <= 1 ) forall( i=1:nhalo ) x(j2+i,:,:,:) = x(j2,:,:,:)
if ( i2(2) <= 1 ) forall( i=1:nhalo ) x(:,k2+i,:,:) = x(:,k2,:,:)
if ( i2(3) <= 1 ) forall( i=1:nhalo ) x(:,:,l2+i,:) = x(:,:,l2,:)

! Continuing BC
if ( i1(1) == 4 ) forall( i=1:nhalo ) x(j1-i,:,:,:) = (i+1) * x(j1,:,:,:) - i * x(j1+1,:,:,:)
if ( i1(2) == 4 ) forall( i=1:nhalo ) x(:,k1-i,:,:) = (i+1) * x(:,k1,:,:) - i * x(:,k1+1,:,:)
if ( i1(3) == 4 ) forall( i=1:nhalo ) x(:,:,l1-i,:) = (i+1) * x(:,:,l1,:) - i * x(:,:,l1+1,:)
if ( i2(1) == 4 ) forall( i=1:nhalo ) x(j2+i,:,:,:) = (i+1) * x(j2,:,:,:) - i * x(j2-1,:,:,:)
if ( i2(2) == 4 ) forall( i=1:nhalo ) x(:,k2+i,:,:) = (i+1) * x(:,k2,:,:) - i * x(:,k2-1,:,:)
if ( i2(3) == 4 ) forall( i=1:nhalo ) x(:,:,l2+i,:) = (i+1) * x(:,:,l2,:) - i * x(:,:,l2-1,:)

! Mirror on cell center BC
if ( i1(1) == 2 ) then
  forall( i=1:nhalo )
    x(j1-i,:,:,1) = 3 * x(j1,:,:,1) - x(j1+1,:,:,1) - x(j1+i-1,:,:,1)
    x(j1-i,:,:,2) = x(j1+i-1,:,:,2)
    x(j1-i,:,:,3) = x(j1+i-1,:,:,3)
  end forall
end if
if ( i1(2) == 2 ) then
  forall( i=1:nhalo )
    x(:,k1-i,:,2) = 3 * x(:,k1,:,2) - x(:,k1+1,:,2) - x(:,k1+i-1,:,2)
    x(:,k1-i,:,3) = x(:,k1+i-1,:,3)
    x(:,k1-i,:,1) = x(:,k1+i-1,:,1)
  end forall
end if
if ( i1(3) == 2 ) then
  forall( i=1:nhalo )
    x(:,:,l1-i,3) = 3 * x(:,:,l1,3) - x(:,:,l1+1,3) - x(:,:,l1+i-1,3)
    x(:,:,l1-i,1) = x(:,:,l1+i-1,1)
    x(:,:,l1-i,2) = x(:,:,l1+i-1,2)
  end forall 
end if 
if ( i2(1) == 2 ) then
  forall( i=1:nhalo )
    x(j2+i,:,:,1) = 3 * x(j2,:,:,1) - x(j2-1,:,:,1) - x(j2-i+1,:,:,1)
    x(j2+i,:,:,2) = x(j2-i+1,:,:,2)
    x(j2+i,:,:,3) = x(j2-i+1,:,:,3)
  end forall 
end if
if ( i2(2) == 2 ) then
  forall( i=1:nhalo )
    x(:,k2+i,:,2) = 3 * x(:,k2,:,2) - x(:,k2-1,:,2) - x(:,k2-i+1,:,2)
    x(:,k2+i,:,3) = x(:,k2-i+1,:,3)
    x(:,k2+i,:,1) = x(:,k2-i+1,:,1)
  end forall
end if
if ( i2(3) == 2 ) then
  forall( i=1:nhalo )
    x(:,:,l2+i,3) = 3 * x(:,:,l2,3) - x(:,:,l2-1,3) - x(:,:,l2-i+1,3)
    x(:,:,l2+i,1) = x(:,:,l2-i+1,1) 
    x(:,:,l2+i,2) = x(:,:,l2-i+1,2) 
  end forall
end if

! Mirror on node BC
if ( i1(1) == 3 ) then
  forall( i=1:nhalo )
    x(j1-i,:,:,1) = 2 * x(j1,:,:,1) - x(j1+i,:,:,1)
    x(j1-i,:,:,2) = x(j1+i,:,:,2)
    x(j1-i,:,:,3) = x(j1+i,:,:,3)
  end forall
end if
if ( i1(2) == 3 ) then
  forall( i=1:nhalo )
    x(:,k1-i,:,2) = 2 * x(:,k1,:,2) - x(:,k1+i,:,2)
    x(:,k1-i,:,3) = x(:,k1+i,:,3)
    x(:,k1-i,:,1) = x(:,k1+i,:,1)
  end forall
end if
if ( i1(3) == 3 ) then
  forall( i=1:nhalo )
    x(:,:,l1-i,3) = 2 * x(:,:,l1,3) - x(:,:,l1+i,3)
    x(:,:,l1-i,1) = x(:,:,l1+i,1)
    x(:,:,l1-i,2) = x(:,:,l1+i,2)
  end forall
end if
if ( i2(1) == 3 ) then
  forall( i=1:nhalo )
    x(j2+i,:,:,1) = 2 * x(j2,:,:,1) - x(j2-i,:,:,1)
    x(j2+i,:,:,2) = x(j2-i,:,:,2)
    x(j2+i,:,:,3) = x(j2-i,:,:,3)
  end forall
end if
if ( i2(2) == 3 ) then
  forall( i=1:nhalo )
    x(:,k2+i,:,2) = 2 * x(:,k2,:,2) - x(:,k2-i,:,2)
    x(:,k2+i,:,3) = x(:,k2-i,:,3)
    x(:,k2+i,:,1) = x(:,k2-i,:,1)
  end forall
end if
if ( i2(3) == 3 ) then
  forall( i=1:nhalo )
    x(:,:,l2+i,3) = 2 * x(:,:,l2,3) - x(:,:,l2-i,3)
    x(:,:,l2+i,1) = x(:,:,l2-i,1)
    x(:,:,l2+i,2) = x(:,:,l2-i,2)
  end forall
end if

! Create fault double nodes
select case( idoublenode )
case( 1 ); x(j+1:nm(1),:,:,:) = x(j:nm(1)-1,:,:,:)
case( 2 ); x(:,k+1:nm(2),:,:) = x(:,k:nm(2)-1,:,:)
case( 3 ); x(:,:,l+1:nm(3),:) = x(:,:,l:nm(3)-1,:)
end select
call vectorswaphalo( x, nhalo )

! Hypocenter location
select case( abs( fixhypo ) )
case( 1 )
  if ( master ) x0 = x(j,k,l,:)
  call rbroadcast1( x0 )
case( 2 )
  if ( master ) x0 = 0.125 * &
    ( x(j,k,l,:) + x(j+1,k+1,l+1,:) &
    + x(j+1,k,l,:) + x(j,k+1,l+1,:) &
    + x(j,k+1,l,:) + x(j+1,k,l+1,:) &
    + x(j,k,l+1,:) + x(j+1,k+1,l,:) )
  call rbroadcast1( x0 )
end select
if ( fixhypo > 0 ) then
  xhypo = x0
elseif ( fixhyp < 0 ) then
  x(:,:,:,1) = x(:,:,:,1) - x0(1) + xhypo(1)
  x(:,:,:,2) = x(:,:,:,2) - x0(2) + xhypo(2)
  x(:,:,:,3) = x(:,:,:,3) - x0(3) + xhypo(3)
end if

! Grid Dimensions
do i = 1,3
  s2 = x(:,:,:,i)
  xlim(i) = minval( s2 )
  xlim(i+3) = -maxval( s2 )
end do
call rreduce1( gxlim, xlim, 'min', 0 )
xcenter = .5 * ( gxlim(1:3) - gxlim(4:6) )
do i = 1,3
  w2(:,:,:,i) = x(:,:,:,i) - xcenter(i);
end do
s2 = sum( w2 * w2, 4 );
call rreduce( rmax, sqrt( maxval( s2 ) ), 'max', 0 )

! Assign fast operators to rectangular mesh portions
noper = 1
i1oper(1,:) = i1cell
i2oper(1,:) = i2cell + 1
if ( oplevel <= 1 ) then
  oper = 1
else
  call optimize( oper, i1oper, i2oper, w2, s2, x, dx, i1cell, i2cell )
  where( oper > oplevel ) oper = oplevel
  if ( oper(1) /= oper(2) ) noper = 2
end if

end subroutine

end module

