! allocate arrays
module arrays
implicit none
contains

subroutine allocate_arrays
use globals
use process
use utilities
integer :: j, k, l

if (sync) call barrier
if (master) print *, clock(), 'Allocate arrays'

! 3d arrays
j = nm(1)
k = nm(2)
l = nm(3)
allocate ( &
    vv(j,k,l,3), &
    uu(j,k,l,3), &
    w1(j,k,l,3), &
    w2(j,k,l,3), &
    vc(j,k,l), &
    mr(j,k,l), &
    lam(j,k,l), &
    mu(j,k,l), &
    gam(j,k,l), &
    yy(j,k,l), &
    s1(j,k,l), &
    s2(j,k,l) )

end subroutine

end module

