! Grid generation
module gridgen_m
use optimize_m
use collectiveio_m
use zone_m
contains
subroutine gridgen

implicit none
real :: theta, scl
integer :: i1(3), i2(3), i1l(3), i2l(3), n(3), noff(3), &
  i, j, k, l, j1, k1, l1, j2, k2, l2, idoublenode, up(1)
real :: x1, x2, lj, lk, ll
logical :: expand

if ( master ) then
  open( 9, file='log', position='append' )
  write( 9, * ) 'Grid generation'
  close( 9 )
end if

! Single node indexing
n = nn
noff = nnoff
idoublenode = 0
i1l = i1node
i2l = i2node
if ( ifn /= 0 ) then
  n(ifn) = n(ifn) - 1
  if ( ihypo(ifn) < i1l(ifn) ) then
    noff(ifn) = noff(ifn) + 1
  else if ( ihypo(ifn) < i2l(ifn) ) then
    i2l(ifn) = i2l(ifn) - 1
    idoublenode = ifn
  end if
end if
j1 = i1l(1); j2 = i2l(1)
k1 = i1l(2); k2 = i2l(2)
l1 = i1l(3); l2 = i2l(3)
i1 = 1 + noff
i2 = n + noff

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

! Dimensions
lj = dx * ( n(1) - 1 )
lk = dx * ( n(2) - 1 )
ll = dx * ( n(3) - 1 )

! Coordinate system
l = sum( maxloc( abs( upvector ) ) )
up = sign( 1., upvector(l) )
k = modulo( l + 1, 3 ) + 1
j = 6 - k - l

! Grid expansion
expand = .false.
if ( rexpand > 1. ) then
  i1 = 1 + noff + n1expand
  i2 = n + noff - n2expand
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

! Mesh type
select case( grid )
case( 'read' )
  oper = 'o'
case( 'constant' )
  oper = 'h'
  if ( expand ) oper = 'r'
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
  oper = 'g'
  call random_number( w1 )
  w1 = .2 * ( w1 - .5 )
  if( edge1(1) ) x(j1,:,:,1) = 0.
  if( edge2(1) ) x(j2,:,:,1) = 0.
  if( edge1(2) ) x(:,k1,:,2) = 0.
  if( edge2(2) ) x(:,k2,:,2) = 0.
  if( edge1(3) ) x(:,:,l1,3) = 0.
  if( edge2(3) ) x(:,:,l2,3) = 0.
  select case( idoublenode )
  case( 1 ); i = ihypo(1); w1(i,:,:,1) = 0.
  case( 2 ); i = ihypo(2); w1(:,i,:,2) = 0.
  case( 3 ); i = ihypo(3); w1(:,:,i,3) = 0.
  end select
  x = x + w1
case( 'spherical' )
case default; stop 'grid'
end select

! Fill in halo
call swaphalovector( x, nhalo )
do i = 1, nhalo
  if( edge1(1) ) x(j1-i,:,:,:) = x(j1,:,:,:)
  if( edge2(1) ) x(j2+i,:,:,:) = x(j2,:,:,:)
  if( edge1(2) ) x(:,k1-i,:,:) = x(:,k1,:,:)
  if( edge2(2) ) x(:,k2+i,:,:) = x(:,k2,:,:)
  if( edge1(3) ) x(:,:,l1-i,:) = x(:,:,l1,:)
  if( edge2(3) ) x(:,:,l2+i,:) = x(:,:,l2,:)
end do

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
if ( oper(1) == 'o' ) call optimize

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

