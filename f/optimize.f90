! Assign fast operators to rectangular mesh portions
module m_optimize
implicit none
contains

subroutine optimize( oper, noper, i1oper, i2oper, w2, s2, x, dx, i1cell, i2cell )
integer, intent(out) :: oper(2), noper, i1oper(2,3), i2oper(2,3)
real, intent(out) :: w2(:,:,:,:), s2(:,:,:)
real, intent(in) :: x(:,:,:,:), dx
integer, intent(in) :: i1cell(3), i2cell(3)
real :: tol, test
integer :: i1(3), i2(3), i, j, k, l, j1, k1, l1, j2, k2, l2

! Grid gradient
i1 = i1cell
i2 = i2cell
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
s2 = 0.
test = 0.

! x derivative
w2 = 0.
w2(j1:j2,:,:,:) = abs( x(j1+1:j2+1,:,:,:) - x(j1:j2,:,:,:) )
test = test + sum( abs( w2(j1:j2,:,:,1) - dx ) )
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  s2(j,k,l) = s2(j,k,l) + &
    w2(j,k,l,2) + w2(j,k+1,l+1,2) + w2(j,k+1,l,2) + w2(j,k,l+1,2) + &
    w2(j,k,l,3) + w2(j,k+1,l+1,3) + w2(j,k+1,l,3) + w2(j,k,l+1,3)
end forall

! y derivative
w2 = 0.
w2(:,k1:k2,:,:) = abs( x(:,k1+1:k2+1,:,:) - x(:,k1:k2,:,:) )
test = test + sum( abs( w2(:,k1:k2,:,2) - dx ) )
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  s2(j,k,l) = s2(j,k,l) + &
    w2(j,k,l,3) + w2(j+1,k,l+1,3) + w2(j+1,k,l,3) + w2(j,k,l+1,3) + &
    w2(j,k,l,1) + w2(j+1,k,l+1,1) + w2(j+1,k,l,1) + w2(j,k,l+1,1)
end forall

! z derivative
w2 = 0.
w2(:,:,l1:l2,:) = abs( x(:,:,l1+1:l2+1,:) - x(:,:,l1:l2,:) )
test = test + sum( abs( w2(:,:,l1:l2,3) - dx ) )
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  s2(j,k,l) = s2(j,k,l) + &
    w2(j,k,l,1) + w2(j+1,k+1,l,1) + w2(j+1,k,l,1) + w2(j,k+1,l,1) + &
    w2(j,k,l,2) + w2(j+1,k+1,l,2) + w2(j+1,k,l,2) + w2(j,k+1,l,2)
end forall

tol = 10. * epsilon( dx )

! For constant grid:
! dx/dy = dx/dz = dy/dz = dy/dx = dz/dx = dz/dy = 0
! dx/dx = dy/dy = dz/dz
oper = 1

if ( test < tol ) return

! For rectangular grid:
! dx/dy = dx/dz = dy/dz = dy/dx = dz/dx = dz/dy = 0
! Find minimal bounding region of the non-rectangular cells
do i = j1, j2;     i1(1) = i; if ( any( s2(i,:,:) > tol ) ) exit; end do
do i = j2, j1, -1; i2(1) = i; if ( any( s2(i,:,:) > tol ) ) exit; end do
do i = k1, k2;     i1(2) = i; if ( any( s2(:,i,:) > tol ) ) exit; end do
do i = k2, k1, -1; i2(2) = i; if ( any( s2(:,i,:) > tol ) ) exit; end do
do i = l1, l2;     i1(3) = i; if ( any( s2(:,:,i) > tol ) ) exit; end do
do i = l2, l1, -1; i2(3) = i; if ( any( s2(:,:,i) > tol ) ) exit; end do
i1oper(2,:) = i1
i2oper(2,:) = i2 + 1
test = product( i2 - i1 + 2 ) / product( i2cell - i1cell + 2 )

if ( all( i2 > i1 ) .and. test > .8 ) then
  oper = 4
else if ( all( i2 <= i1 ) ) then
  oper = 2
else
  oper(1) = 2
  oper(2) = 4
  noper = 2
end if

end subroutine

end module

