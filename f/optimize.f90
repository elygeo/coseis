! Assign fast operators to rectangular mesh portions
module optimize_m
use globals_m
contains
subroutine optimize

implicit none
real :: tol, test
integer :: i1(3), i2(3), i, j, k, l, j1, k1, l1, j2, k2, l2

! Grid gradient
i1 = i1cell
i2 = i2cell
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
s1 = 0.
test = 0.

! x derivative
w1 = 0.
w1(j1:j2,:,:,:) = abs( x(j1+1:j2+1,:,:,:) - x(j1:j2,:,:,:) )
test = test + sum( abs( w1(j1:j2,:,:,1) - dx ) )
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  s1(j,k,l) = s1(j,k,l) + &
    w1(j,k,l,2) + w1(j,k+1,l+1,2) + w1(j,k+1,l,2) + w1(j,k,l+1,2) + &
    w1(j,k,l,3) + w1(j,k+1,l+1,3) + w1(j,k+1,l,3) + w1(j,k,l+1,3)
end forall

! y derivative
w1 = 0.
w1(:,k1:k2,:,:) = abs( x(:,k1+1:k2+1,:,:) - x(:,k1:k2,:,:) )
test = test + sum( abs( w1(:,k1:k2,:,2) - dx ) )
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  s1(j,k,l) = s1(j,k,l) + &
    w1(j,k,l,3) + w1(j+1,k,l+1,3) + w1(j+1,k,l,3) + w1(j,k,l+1,3) + &
    w1(j,k,l,1) + w1(j+1,k,l+1,1) + w1(j+1,k,l,1) + w1(j,k,l+1,1)
end forall

! z derivative
w1 = 0.
w1(:,:,l1:l2,:) = abs( x(:,:,l1+1:l2+1,:) - x(:,:,l1:l2,:) )
test = test + sum( abs( w1(:,:,l1:l2,3) - dx ) )
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  s1(j,k,l) = s1(j,k,l) + &
    w1(j,k,l,1) + w1(j+1,k+1,l,1) + w1(j+1,k,l,1) + w1(j,k+1,l,1) + &
    w1(j,k,l,2) + w1(j+1,k+1,l,2) + w1(j+1,k,l,2) + w1(j,k+1,l,2)
end forall

tol = 10. * epsilon( dx )

! For constant grid:
! dx/dy = dx/dz = dy/dz = dy/dx = dz/dx = dz/dy = 0
! dx/dx = dy/dy = dz/dz
oper = 'h'

if ( test < tol ) return

! For rectangular grid:
! dx/dy = dx/dz = dy/dz = dy/dx = dz/dx = dz/dy = 0
! Find minimal bounding region of the non-rectangular cells
do i = j1, j2;     i1(1) = i; if ( any( s1(i,:,:) > tol ) ) exit; end do
do i = j2, j1, -1; i2(1) = i; if ( any( s1(i,:,:) > tol ) ) exit; end do
do i = k1, k2;     i1(2) = i; if ( any( s1(:,i,:) > tol ) ) exit; end do
do i = k2, k1, -1; i2(2) = i; if ( any( s1(:,i,:) > tol ) ) exit; end do
do i = l1, l2;     i1(3) = i; if ( any( s1(:,:,i) > tol ) ) exit; end do
do i = l2, l1, -1; i2(3) = i; if ( any( s1(:,:,i) > tol ) ) exit; end do
i1oper(2,:) = i1
i2oper(2,:) = i2 + 1
test = product( i2 - i1 + 2 ) / product( i2cell - i1cell + 2 )

if ( all( i2 > i1 ) .and. test > .8 ) then
  oper = 'g'
else if ( all( i2 <= i1 ) ) then
  oper = 'r'
else
  oper(1) = 'r'
  oper(2) = 'g'
  noper = 2
end if

end subroutine
end module

