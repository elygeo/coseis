!------------------------------------------------------------------------------!
! LOCKNODES

module locknodes_m
contains
subroutine locknodes
use globals_m

implicit none
integer :: i, j, k, l, i1(3), j1, k1, l1, i2(3), j2, k2, l2, iz

do iz = 1, nlock
  i1 = max( i1lock(iz,), i2node )
  i2 = min( i2lock(iz,), i2node )
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  i1 = lock(iz,:)
  do i = 1, 3
    if ( i1(i) == 1 ) forall( j=j1:j2, k=k1:k2, l=l1:l2 ) w1(j,k,l,i) = 0.
  end do
end do

end subroutine
end module

