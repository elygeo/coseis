! Grid generation
module m_gridgen
implicit none
contains

subroutine gridgen
use m_globals
use m_collective
use m_bc
use m_util
integer :: i1(3), i2(3), i3(3), i4(3), bc(3), &
  i, j, k, l, j1, k1, l1, j2, k2, l2, idoublenode, b, c
real :: x0(3), m(9), tol, r

if ( master ) write( 0, * ) 'Grid generation'

! Read grid
i1 = 1  - nnoff
i2 = nn - nnoff
i3 = i1core
i4 = i2core
if ( grid == 'read' ) then
  i = mpin * 4
  call rio4( -1, i, r, 'data/x1', w1, 1, i1, i2, i3, i4, 1, 1 )
  call rio4( -1, i, r, 'data/x2', w1, 2, i1, i2, i3, i4, 1, 1 )
  call rio4( -1, i, r, 'data/x3', w1, 3, i1, i2, i3, i4, 1, 1 )
end if

! Single node indexing
idoublenode = 0
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

! Remove double nodes for now, or create basic rectangular mesh
if ( grid == 'read' ) then
  j = ihypo(1)
  k = ihypo(2)
  l = ihypo(3)
  select case( idoublenode )
  case( 1 ); w1(j+1:nm(1)-1,:,:,:) = w1(j+2:nm(1),:,:,:)
  case( 2 ); w1(:,k+1:nm(2)-1,:,:) = w1(:,k+2:nm(2),:,:)
  case( 3 ); w1(:,:,l+1:nm(3)-1,:) = w1(:,:,l+2:nm(3),:)
  end select
else
  do i = i3(1), i4(1); w1(i,:,:,1) = dx * ( i - i1(1) ); end do
  do i = i3(2), i4(2); w1(:,i,:,2) = dx * ( i - i1(2) ); end do
  do i = i3(3), i4(3); w1(:,:,i,3) = dx * ( i - i1(3) ); end do
end if

! Grid expansion
if ( rexpand > 1. ) then
  i1 = i1 + n1expand
  i2 = i2 - n2expand
  do j = i3(1), min( i4(1), i1(1) - 1 )
    i = i1(1) - j
    w1(j,:,:,1) = w1(j,:,:,1) + &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do j = max( i3(1), i2(1) + 1 ), i4(1)
    i = j - i2(1)
    w1(j,:,:,1) = w1(j,:,:,1) - &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do k = i3(2), min( i4(2), i1(2) - 1 )
    i = i1(2) - k
    w1(:,k,:,2) = w1(:,k,:,2) + &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do k = max( i3(2), i2(2) + 1 ), i4(2)
    i = k - i2(2)
    w1(:,k,:,2) = w1(:,k,:,2) - &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do l = i3(3), min( i4(3), i1(3) - 1 )
    i = i1(3) - l
    w1(:,:,l,3) = w1(:,:,l,3) + &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
  do l = max( i3(3), i2(3) + 1 ), i4(3)
    i = l - i2(3)
    w1(:,:,l,3) = w1(:,:,l,3) - &
      dx * ( i + 1 - ( rexpand ** ( i + 1 ) - 1 ) / ( rexpand - 1 ) )
  end do
end if

! Affine grid transformation
m = affine
forall( j=1:nm(1), k=1:nm(2), l=1:nm(3) )
  w2(j,k,l,1) = m(1) * w1(j,k,l,1) + m(2) * w1(j,k,l,2) + m(3) * w1(j,k,l,3)
  w2(j,k,l,2) = m(4) * w1(j,k,l,1) + m(5) * w1(j,k,l,2) + m(6) * w1(j,k,l,3)
  w2(j,k,l,3) = m(7) * w1(j,k,l,1) + m(8) * w1(j,k,l,2) + m(9) * w1(j,k,l,3)
end forall
w1 = w2

! Hypocenter
j = ihypo(1)
k = ihypo(2)
l = ihypo(3)

! Random noise added to mesh, leave boundaries flat, bc=3 means zero normal component
if ( gridnoise > 0. ) then
  call random_number( w2 )
  w2 = gridnoise * ( w2 - .5 )
  bc = 3
  call vectorbc( w2, bc, bc, i1bc, i2bc )
  select case( idoublenode )
  case( 1 ); w2(j,:,:,1) = 0.
  case( 2 ); w2(:,k,:,2) = 0.
  case( 3 ); w2(:,:,l,3) = 0.
  end select
  w1 = w1 + w2
end if

! Create fault double nodes
select case( idoublenode )
case( 1 ); w1(j+1:nm(1),:,:,:) = w1(j:nm(1)-1,:,:,:)
case( 2 ); w1(:,k+1:nm(2),:,:) = w1(:,k:nm(2)-1,:,:)
case( 3 ); w1(:,:,l+1:nm(3),:) = w1(:,:,l:nm(3)-1,:)
end select

! Fill halo, bc=4 means copy into halo, need this for nhat
bc = 4
i1 = i1bc - 1
i2 = i2bc + 1
call vectorswaphalo( w1, nhalo )
call vectorbc( w1, bc, bc, i1, i2 )

! Find cell centers
call vectoraverage( w2, w1, i1cell, i2cell, 1 )
call vectorsethalo( w2, huge(r), i1cell, i2cell )

! Hypocenter location
select case( abs( fixhypo ) )
case( 1 )
  if ( master ) x0 = w1(j,k,l,:)
  call rbroadcast1( x0 )
case( 2 )
  if ( master ) x0 = w2(j,k,l,:)
  call rbroadcast1( x0 )
end select
if ( fixhypo > 0 ) then
  xhypo = x0
elseif ( fixhypo < 0 ) then
  forall( j=1:nm(1), k=1:nm(2), l=1:nm(3) )
    w1(j,k,l,1) = w1(j,k,l,1) - x0(1) + xhypo(1)
    w1(j,k,l,2) = w1(j,k,l,2) - x0(2) + xhypo(2)
    w1(j,k,l,3) = w1(j,k,l,3) - x0(3) + xhypo(3)
    w2(j,k,l,1) = w2(j,k,l,1) - x0(1) + xhypo(1)
    w2(j,k,l,2) = w2(j,k,l,2) - x0(2) + xhypo(2)
    w2(j,k,l,3) = w2(j,k,l,3) - x0(3) + xhypo(3)
  end forall
end if

! Orthogonality test
if ( oplevel == 0 ) then
  oplevel = 6
  tol = 10. * epsilon( dx )
  j1 = i1cell(1); j2 = i2cell(1)
  k1 = i1cell(2); k2 = i2cell(2)
  l1 = i1cell(3); l2 = i2cell(3)
  if ( &
  sum( abs( w1(j1+1:j2+1,:,:,2) - w1(j1:j2,:,:,2) ) ) < tol .and. &
  sum( abs( w1(j1+1:j2+1,:,:,3) - w1(j1:j2,:,:,3) ) ) < tol .and. &
  sum( abs( w1(:,k1+1:k2+1,:,3) - w1(:,k1:k2,:,3) ) ) < tol .and. &
  sum( abs( w1(:,k1+1:k2+1,:,1) - w1(:,k1:k2,:,1) ) ) < tol .and. &
  sum( abs( w1(:,:,l1+1:l2+1,1) - w1(:,:,l1:l2,1) ) ) < tol .and. &
  sum( abs( w1(:,:,l1+1:l2+1,2) - w1(:,:,l1:l2,2) ) ) < tol ) oplevel = 2
end if

! Operators
select case( oplevel )
case( 1 )
case( 2 )
  allocate( dx1(nm(1)), dx2(nm(2)), dx3(nm(3)) )
  do i = 1, nm(1)-1; dx1(i) = .5 * ( w1(i+1,3,3,1) - w1(i,3,3,1) ); end do
  do i = 1, nm(2)-1; dx2(i) = .5 * ( w1(3,i+1,3,2) - w1(3,i,3,2) ); end do
  do i = 1, nm(3)-1; dx3(i) = .5 * ( w1(3,3,i+1,3) - w1(3,3,i,3) ); end do
case( 3:5 )
  allocate( xx(nm(1),nm(2),nm(3),3) )
  xx = w1
case( 6 )
  allocate( bb(nm(1),nm(2),nm(3),8,3) )
  do i = 1, 3
    b = modulo( i, 3 ) + 1
    c = modulo( i + 1, 3 ) + 1
    forall( j=1:nm(1)-1, k=1:nm(2)-1, l=1:nm(3)-1 )
      bb(j,k,l,1,i) = 1. / 12. * &
        ((w1(j+1,k,l,b)-w1(j,k+1,l+1,b))*(w1(j+1,k+1,l,c)-w1(j+1,k,l+1,c))+w1(j,k+1,l+1,b)*(w1(j,k,l+1,c)-w1(j,k+1,l,c)) &
        +(w1(j,k+1,l,b)-w1(j+1,k,l+1,b))*(w1(j,k+1,l+1,c)-w1(j+1,k+1,l,c))+w1(j+1,k,l+1,b)*(w1(j+1,k,l,c)-w1(j,k,l+1,c)) &
        +(w1(j,k,l+1,b)-w1(j+1,k+1,l,b))*(w1(j+1,k,l+1,c)-w1(j,k+1,l+1,c))+w1(j+1,k+1,l,b)*(w1(j,k+1,l,c)-w1(j+1,k,l,c)))
      bb(j,k,l,2,i) = 1. / 12. * &
        ((w1(j+1,k+1,l+1,b)-w1(j,k,l,b))*(w1(j+1,k,l+1,c)-w1(j+1,k+1,l,c))+w1(j,k,l,b)*(w1(j,k+1,l,c)-w1(j,k,l+1,c)) &
        +(w1(j,k+1,l,b)-w1(j+1,k,l+1,b))*(w1(j+1,k+1,l,c)-w1(j,k,l,c))+w1(j+1,k,l+1,b)*(w1(j,k,l+1,c)-w1(j+1,k+1,l+1,c)) &
        +(w1(j,k,l+1,b)-w1(j+1,k+1,l,b))*(w1(j,k,l,c)-w1(j+1,k,l+1,c))+w1(j+1,k+1,l,b)*(w1(j+1,k+1,l+1,c)-w1(j,k+1,l,c)))
      bb(j,k,l,3,i) = 1. / 12. * &
        ((w1(j+1,k+1,l+1,b)-w1(j,k,l,b))*(w1(j+1,k+1,l,c)-w1(j,k+1,l+1,c))+w1(j,k,l,b)*(w1(j,k,l+1,c)-w1(j+1,k,l,c)) &
        +(w1(j+1,k,l,b)-w1(j,k+1,l+1,b))*(w1(j,k,l,c)-w1(j+1,k+1,l,c))+w1(j,k+1,l+1,b)*(w1(j+1,k+1,l+1,c)-w1(j,k,l+1,c)) &
        +(w1(j,k,l+1,b)-w1(j+1,k+1,l,b))*(w1(j,k+1,l+1,c)-w1(j,k,l,c))+w1(j+1,k+1,l,b)*(w1(j+1,k,l,c)-w1(j+1,k+1,l+1,c)))
      bb(j,k,l,4,i) = 1. / 12. * &
        ((w1(j+1,k+1,l+1,b)-w1(j,k,l,b))*(w1(j,k+1,l+1,c)-w1(j+1,k,l+1,c))+w1(j,k,l,b)*(w1(j+1,k,l,c)-w1(j,k+1,l,c)) &
        +(w1(j+1,k,l,b)-w1(j,k+1,l+1,b))*(w1(j+1,k,l+1,c)-w1(j,k,l,c))+w1(j,k+1,l+1,b)*(w1(j,k+1,l,c)-w1(j+1,k+1,l+1,c)) &
        +(w1(j,k+1,l,b)-w1(j+1,k,l+1,b))*(w1(j,k,l,c)-w1(j,k+1,l+1,c))+w1(j+1,k,l+1,b)*(w1(j+1,k+1,l+1,c)-w1(j+1,k,l,c)))
      bb(j,k,l,5,i) = 1. / 12. * &
        ((w1(j,k+1,l+1,b)-w1(j+1,k,l,b))*(w1(j,k+1,l,c)-w1(j,k,l+1,c))+w1(j+1,k,l,b)*(w1(j+1,k,l+1,c)-w1(j+1,k+1,l,c)) &
        +(w1(j+1,k,l+1,b)-w1(j,k+1,l,b))*(w1(j,k,l+1,c)-w1(j+1,k,l,c))+w1(j,k+1,l,b)*(w1(j+1,k+1,l,c)-w1(j,k+1,l+1,c)) &
        +(w1(j+1,k+1,l,b)-w1(j,k,l+1,b))*(w1(j+1,k,l,c)-w1(j,k+1,l,c))+w1(j,k,l+1,b)*(w1(j,k+1,l+1,c)-w1(j+1,k,l+1,c)))
      bb(j,k,l,6,i) = 1. / 12. * &
        ((w1(j,k,l,b)-w1(j+1,k+1,l+1,b))*(w1(j,k,l+1,c)-w1(j,k+1,l,c))+w1(j+1,k+1,l+1,b)*(w1(j+1,k+1,l,c)-w1(j+1,k,l+1,c)) &
        +(w1(j+1,k,l+1,b)-w1(j,k+1,l,b))*(w1(j+1,k+1,l+1,c)-w1(j,k,l+1,c))+w1(j,k+1,l,b)*(w1(j,k,l,c)-w1(j+1,k+1,l,c)) &
        +(w1(j+1,k+1,l,b)-w1(j,k,l+1,b))*(w1(j,k+1,l,c)-w1(j+1,k+1,l+1,c))+w1(j,k,l+1,b)*(w1(j+1,k,l+1,c)-w1(j,k,l,c)))
      bb(j,k,l,7,i) = 1. / 12. * &
        ((w1(j,k,l,b)-w1(j+1,k+1,l+1,b))*(w1(j+1,k,l,c)-w1(j,k,l+1,c))+w1(j+1,k+1,l+1,b)*(w1(j,k+1,l+1,c)-w1(j+1,k+1,l,c)) &
        +(w1(j,k+1,l+1,b)-w1(j+1,k,l,b))*(w1(j,k,l+1,c)-w1(j+1,k+1,l+1,c))+w1(j+1,k,l,b)*(w1(j+1,k+1,l,c)-w1(j,k,l,c)) &
        +(w1(j+1,k+1,l,b)-w1(j,k,l+1,b))*(w1(j+1,k+1,l+1,c)-w1(j+1,k,l,c))+w1(j,k,l+1,b)*(w1(j,k,l,c)-w1(j,k+1,l+1,c)))
      bb(j,k,l,8,i) = 1. / 12. * &
        ((w1(j,k,l,b)-w1(j+1,k+1,l+1,b))*(w1(j,k+1,l,c)-w1(j+1,k,l,c))+w1(j+1,k+1,l+1,b)*(w1(j+1,k,l+1,c)-w1(j,k+1,l+1,c)) &
        +(w1(j,k+1,l+1,b)-w1(j+1,k,l,b))*(w1(j+1,k+1,l+1,c)-w1(j,k+1,l,c))+w1(j+1,k,l,b)*(w1(j,k,l,c)-w1(j+1,k,l+1,c)) &
        +(w1(j+1,k,l+1,b)-w1(j,k+1,l,b))*(w1(j+1,k,l,c)-w1(j+1,k+1,l+1,c))+w1(j,k+1,l,b)*(w1(j,k+1,l+1,c)-w1(j,k,l,c)))
    end forall
  end do
case default; stop 'illegal operator'
end select

end subroutine

end module

