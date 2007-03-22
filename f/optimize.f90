! Optimize for rectangular mesh
module m_optimize
implicit none
contains

subroutine optimize( oplevel, i1, i2, x, dx )
integer, intent(inout) :: oplevel
integer, intent(in) :: i1(3), i2(3)
real, intent(in) :: x(:,:,:,:), dx
real :: tol
integer :: j1, k1, l1, j2, k2, l2

j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
tol = 10. * epsilon( dx )

! Rectangular test
! dx/dy = dx/dz = dy/dz = dy/dx = dz/dx = dz/dy = 0
if ( sum( abs( x(j1+1:j2+1,:,:,2) - x(j1:j2,:,:,2) ) ) > tol ) return
if ( sum( abs( x(j1+1:j2+1,:,:,3) - x(j1:j2,:,:,3) ) ) > tol ) return
if ( sum( abs( x(:,k1+1:k2+1,:,3) - x(:,k1:k2,:,3) ) ) > tol ) return
if ( sum( abs( x(:,k1+1:k2+1,:,1) - x(:,k1:k2,:,1) ) ) > tol ) return
if ( sum( abs( x(:,:,l1+1:l2+1,1) - x(:,:,l1:l2,1) ) ) > tol ) return
if ( sum( abs( x(:,:,l1+1:l2+1,2) - x(:,:,l1:l2,2) ) ) > tol ) return
oplevel = 2

! Constant grid test
! dx/dx = dy/dy = dz/dz = h
if ( sum( abs( x(j1+1:j2+1,:,:,1) - x(j1:j2,:,:,1) - dx ) ) > tol ) return
if ( sum( abs( x(:,k1+1:k2+1,:,2) - x(:,k1:k2,:,2) - dx ) ) > tol ) return
if ( sum( abs( x(:,:,l1+1:l2+1,3) - x(:,:,l1:l2,3) - dx ) ) > tol ) return
oplevel = 1

end subroutine

end module

