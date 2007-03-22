! Allocate arrays
module m_arrays
implicit none
contains

subroutine arrays
use m_globals
integer :: i1(3), i2(3), j, k, l, j1, k1, l1, j2, k2, l2

i2 = nm
j = i2(1)
k = i2(2)
l = i2(3)

! 3d vectors
allocate(       &
  v(j,k,l,3),   &
  u(j,k,l,3),   &
! z1(j,k,l,3),  &
! z2(j,k,l,3),  &
  w1(j,k,l,3),  &
  w2(j,k,l,3)   )

! 3d scalars
allocate(       &
  mr(j,k,l),    &
  lam(j,k,l),   &
  mu(j,k,l),    &
  gam(j,k,l),   &
! qp(j,k,l),    &
! qs(j,k,l),    &
  y(j,k,l),     &
  pv(j,k,l),    &
  s1(j,k,l),    &
  s2(j,k,l)     )

i1 = 0
i2 = 0
where ( bc1 == 1 ) i1 = npml
where ( bc2 == 1 ) i2 = npml
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

! PML state
allocate(       &
  p1(j1,k,l,3), &
  g1(j1,k,l,3), &
  p2(j,k1,l,3), &
  g2(j,k1,l,3), &
  p3(j,k,l1,3), &
  g3(j,k,l1,3), &
  p4(j2,k,l,3), &
  g4(j2,k,l,3), &
  p5(j,k2,l,3), &
  g5(j,k2,l,3), &
  p6(j,k,l2,3), &
  g6(j,k,l2,3)  )

! PML damping
allocate( dn1(npml), dn2(npml), dc1(npml), dc2(npml) )

if ( ifn /= 0 ) then
  i1 = nm
  i1(ifn) = 1
else
  i1 = 0
end if
j = i1(1)
k = i1(2)
l = i1(3)

! Fault vectors
allocate(        &
  nhat(j,k,l,3), &
  t0(j,k,l,3),   &
  t1(j,k,l,3),   &
  t2(j,k,l,3),   &
  t3(j,k,l,3)    )

! Fault scalars
allocate(       &
  mus(j,k,l),   &
  mud(j,k,l),   &
  dc(j,k,l),    &
  co(j,k,l),    &
  area(j,k,l),  &
  rhypo(j,k,l), &
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

