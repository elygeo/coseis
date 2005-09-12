!------------------------------------------------------------------------------!
! OPTIMIZE

module optimize_m
contains
subroutine optimize
use globals_m
use dfnc_m

implicit none
real :: tol, misfit

! grid gradient
i1 = i1cell
i2 = i2cell
s1 = 0.
s2 = 0.
do i = 1, 3
  j = mod( i , 3 ) + 1
  k = mod( i + 1, 3 ) + 1
  call dfnc( s1, 'h', x, x, 1., i, i, i1, i2 )
  w1(:,:,:,i) = abs( s1 )
  call dfnc( s1, 'h', x, x, 1., i, j, i1, i2 )
  call dfnc( s2, 'h', x, x, 1., i, k, i1, i2 )
  w2(:,:,:,i) = abs( s1 ) + abs( s2 )
end do

! for equal grid:
! dx/dy = dx/dz = dy/dz = dy/dx = dz/dx = dz/dy = 0
! dx/dx = dy/dy = dz/dz
tol = 10. * epsilon( dx )
misfit = &
  sum( w2 ) + &
  sum( abs( w1(:,:,:,1) - w1(:,:,:,2) ) ) + &
  sum( abs( w1(:,:,:,1) - w1(:,:,:,3) ) )
if ( misfit < tol ) then
  oper(1) = 'h'
  return
else
  oper(1) = 'r'
end if
ioper(1,:) = (/ 1, 1, 1, -1, -1, -1 /)

! rectangular grid. find minimal region where:
! dx/dy = dx/dz = dy/dz = dy/dx = dz/dx = dz/dy = 0
s1 = sum( w2, 4 )
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
do i = j1, j2;     i1(1) = i; if ( any( s1(i,:,:) > tol ) ) exit; end do
do i = j2, j1, -1; i2(1) = i; if ( any( s1(i,:,:) > tol ) ) exit; end do
do i = k1, k2;     i1(2) = i; if ( any( s1(:,i,:) > tol ) ) exit; end do
do i = k2, k1, -1; i2(2) = i; if ( any( s1(:,i,:) > tol ) ) exit; end do
do i = l1, l2;     i1(3) = i; if ( any( s1(:,:,i) > tol ) ) exit; end do
do i = l2, l1, -1; i2(3) = i; if ( any( s1(:,:,i) > tol ) ) exit; end do

! asign operators
if ( product( i2 - i1 + 1 ) > .9 * product( i2cell - i2cell + 1 ) ) then
  oper(1) = 'g'
else if ( all( i2 >= i1 ) ) then
  oper(2) = 'g'
  noper = 2
  ioper(2,:) = (/ i1, i2 + 1 /)
end if

end subroutine
end module

