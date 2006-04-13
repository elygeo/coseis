! Grid generation
module gridgen_m
implicit none
contains

subroutine gridgen
use globals_m
use optimize_m
use collectiveio_m
use zone_m
integer :: i1(3), i2(3), i1l(3), i2l(3), n(3), &
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
  call vectorio( 'r', 'data/x1', x, 1, 1, i1, i2, i1l, i2l, 0 )
  call vectorio( 'r', 'data/x2', x, 2, 1, i1, i2, i1l, i2l, 0 )
  call vectorio( 'r', 'data/x3', x, 3, 1, i1, i2, i1l, i2l, 0 )
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

! Affine grid transformation
m = sign( 1., affine(1:9) ) * sqrt( abs( affine(1:9) / affine(10) ) )
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
end select

! Symmetry
i1 = ( i1l + i2l ) / 2
i2 = ( i1l + i2l + 1 ) / 2
n  = ( i2l - i1l + 1 ) / 2
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
j1 = i1l(1); j2 = i2l(1)
k1 = i1l(2); k2 = i2l(2)
l1 = i1l(3); l2 = i2l(3)

! Random noise added to mesh
if ( gridnoise > 0. ) then
  call random_number( w1 )
  w1 = gridnoise * ( w1 - .5 )
  if ( i1(1) <= 1 ) w1(j1,:,:,1) = 0.
  if ( i2(1) <= 1 ) w1(j2,:,:,1) = 0.
  if ( i1(2) <= 1 ) w1(:,k1,:,2) = 0.
  if ( i2(2) <= 1 ) w1(:,k2,:,2) = 0.
  if ( i1(3) <= 1 ) w1(:,:,l1,3) = 0.
  if ( i2(3) <= 1 ) w1(:,:,l2,3) = 0.
  select case( idoublenode )
  case( 1 ); w1(j,:,:,1) = 0.
  case( 2 ); w1(:,k,:,2) = 0.
  case( 3 ); w1(:,:,l,3) = 0.
  end select
  x = x + w1
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

! Assign fast operators to rectangular mesh portions
noper = 1
i1oper(1,:) = i1cell
i2oper(1,:) = i2cell + 1
call optimize

! Hypocenter location
if ( all( xhypo < 0. ) ) then
  if ( master ) xhypo = x(j,k,l,:)
  call broadcast( xhypo )
end if

! Origin
if ( origin == 0 ) then
  x(:,:,:,1) = x(:,:,:,1) - xhypo(1)
  x(:,:,:,2) = x(:,:,:,2) - xhypo(2)
  x(:,:,:,3) = x(:,:,:,3) - xhypo(3)
  xhypo = 0.
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
call pmax( rmax )

end subroutine

end module

