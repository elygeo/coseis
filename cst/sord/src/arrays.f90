! allocate arrays
module m_arrays
implicit none
contains

subroutine arrays
use m_globals
integer :: i1(3), i2(3), j, k, l, j1, k1, l1, j2, k2, l2

! 3d
j = nm(1)
k = nm(2)
l = nm(3)

! 3d vectors
allocate(         &
    vv(j,k,l,3),  &
    uu(j,k,l,3),  &
!   z1(j,k,l,3),  &
!   z2(j,k,l,3),  &
    w1(j,k,l,3),  &
    w2(j,k,l,3)   )

! 3d scalars
allocate(         &
    vc(j,k,l),    &
    mr(j,k,l),    &
    lam(j,k,l),   &
    mu(j,k,l),    &
    gam(j,k,l),   &
!   qp(j,k,l),    &
!   qs(j,k,l),    &
    yy(j,k,l),    &
    s1(j,k,l),    &
    s2(j,k,l)     )

! pml nodes
i1 = min( i2node, i1pml ) - i1node + 1
i2 = i2node - max( i1node, i2pml ) + 1
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
allocate(         &
    p1(j1,k,l,3), &
    p2(j,k1,l,3), &
    p3(j,k,l1,3), &
    p4(j2,k,l,3), &
    p5(j,k2,l,3), &
    p6(j,k,l2,3)  )

! pml cells
i1 = min( i2cell, i1pml ) - i1cell + 1
i2 = i2cell - max( i1cell, i2pml - 1 ) + 1
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
allocate(         &
    g1(j1,k,l,3), &
    g2(j,k1,l,3), &
    g3(j,k,l1,3), &
    g4(j2,k,l,3), &
    g5(j,k2,l,3), &
    g6(j,k,l2,3)  )

! pml damping
allocate( dn1(npml), dn2(npml), dc1(npml), dc2(npml) )

! rupture
if ( ifn /= 0 ) then
    i1 = nm
    i1(ifn) = 1
else
    i1 = 0
end if
j = i1(1)
k = i1(2)
l = i1(3)

! rupture vectors
allocate(          &
    !ts0(j,k,l,3),  & ! [ZS]
    !tp(j,k,l,3),   & ! [ZS]
    nhat(j,k,l,3), &
    t0(j,k,l,3),   &
    t1(j,k,l,3),   &
    t2(j,k,l,3),   &
    t3(j,k,l,3)    )

! rupture scalars
allocate(         &
    !af(j,k,l),    & ! [ZS]
    !bf(j,k,l),    & ! [ZS]
    !v0(j,k,l),    & ! [ZS]
    !f0(j,k,l),    & ! [ZS]
    !ll(j,k,l),    & ! [ZS]
    !fw(j,k,l),    & ! [ZS]
    !vw(j,k,l),    & ! [ZS]
    !psi(j,k,l),   & ! [ZS]
    !svtrl(j,k,l), & ! [ZS]
    !svold(j,k,l), & ! [ZS]
    !sv0(j,k,l),   & ! [ZS]
    mus(j,k,l),   &
    mud(j,k,l),   &
    dc(j,k,l),    &
    co(j,k,l),    &
    area(j,k,l),  &
    rhypo(j,k,l), &
    lamf(j,k,l),  &
    muf(j,k,l),   &
    sl(j,k,l),    &
    psv(j,k,l),   &
    trup(j,k,l),  &
    tarr(j,k,l),  &
    tn(j,k,l),    &
    ts(j,k,l),    &
    f1(j,k,l),    &
    f2(j,k,l)     )

end subroutine

end module

