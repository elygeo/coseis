! allocate arrays
module arrays
implicit none
contains

subroutine allocate_arrays
use globals
integer :: j, k, l

! 3d
j = nm(1)
k = nm(2)
l = nm(3)

! 3d vectors
allocate ( &
    vv(j,k,l,3), &
    uu(j,k,l,3), &
!   z1(j,k,l,3), &
!   z2(j,k,l,3), &
    w1(j,k,l,3), &
    w2(j,k,l,3))

! 3d scalars
allocate ( &
    vc(j,k,l), &
    mr(j,k,l), &
    lam(j,k,l), &
    mu(j,k,l), &
    gam(j,k,l), &
!   qp(j,k,l), &
!   qs(j,k,l), &
    yy(j,k,l), &
    s1(j,k,l), &
    s2(j,k,l))

end subroutine

end module

