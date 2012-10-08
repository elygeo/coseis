! perfectly matche layer
module pml
implicit none
contains

! initialize pml
subroutine init_pml
use globals
use collective
use utilities
integer :: i1(3), i2(3), i, j, k, l, j1, k1, l1, j2, k2, l2
real :: c1, c2, c3, damp, dampn, dampc, tune, r

if (npml < 1) return
if (sync) call barrier
if (master) print *, clock(), 'Initialize PML'

! pml damping
allocate (dn1(npml), dn2(npml), dc1(npml), dc2(npml))
c1 =  8.0 / 15.0
c2 = -3.0 / 100.0
c3 =  1.0 / 1500.0
tune = 3.5
r = dx(1) * dx(1) + dx(2) * dx(2) + dx(3) * dx(3)
damp = tune * vpml / sqrt(r / 3.0) * (c1 + (c2 + c3 * npml) * npml) / npml ** ppml
do i = 1, npml
    dampn = damp *  i ** ppml
    dampc = damp * (i ** ppml + (i - 1) ** ppml) * 0.5
    dn1(npml-i+1) = -2.0 * dampn       / (2.0 + dt * dampn)
    dc1(npml-i+1) = (2.0 - dt * dampc) / (2.0 + dt * dampc)
    dn2(npml-i+1) =  2.0               / (2.0 + dt * dampn)
    dc2(npml-i+1) =  2.0 * dt          / (2.0 + dt * dampc)
end do

! allocate arrays
j = nm(1)
k = nm(2)
l = nm(3)

! pml nodes
i1 = min(i2node, i1pml) - i1node + 1
i2 = i2node - max(i1node, i2pml) + 1
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
allocate ( &
    p1(j1,k,l,3), &
    p2(j,k1,l,3), &
    p3(j,k,l1,3), &
    p4(j2,k,l,3), &
    p5(j,k2,l,3), &
    p6(j,k,l2,3) &
)
p1 = 0.0
p2 = 0.0
p3 = 0.0
p4 = 0.0
p5 = 0.0
p6 = 0.0

! pml cells
i1 = min(i2cell, i1pml) - i1cell + 1
i2 = i2cell - max(i1cell, i2pml - 1) + 1
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
allocate ( &
    g1(j1,k,l,3), &
    g2(j,k1,l,3), &
    g3(j,k,l1,3), &
    g4(j2,k,l,3), &
    g5(j,k2,l,3), &
    g6(j,k,l2,3) &
)
g1 = 0.0
g2 = 0.0
g3 = 0.0
g4 = 0.0
g5 = 0.0
g6 = 0.0

end subroutine

end module

