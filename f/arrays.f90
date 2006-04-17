! Allocate arrays
module arrays_m
implicit none
contains

subroutine arrays
use globals_m
use tictoc_m
integer :: i1(3), i2(3), j, k, l, j1, k1, l1, j2, k2, l2

if ( master ) call toc( 'Allocate arrays' )

i2 = nm
j = i2(1)
k = i2(2)
l = i2(3)

! 3D vectors
allocate(       &
  x(j,k,l,3),   &
  v(j,k,l,3),   &
  u(j,k,l,3),   &
  w1(j,k,l,3),  &
  w2(j,k,l,3)   )

! 3D scalars
allocate(       &
  mr(j,k,l),    &
  lam(j,k,l),   &
  mu(j,k,l),    &
  y(j,k,l),     &
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

if ( ifn > 0 ) then
  i2 = nm
  i2(ifn) = 1
else
  i2 = 0
end if
j = i2(1)
k = i2(2)
l = i2(3)

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
  svm(j,k,l),   &
  sl(j,k,l),    &
  trup(j,k,l),  &
  tarr(j,k,l),  &
  tn(j,k,l),    &
  ts(j,k,l),    &
  f1(j,k,l),    &
  f2(j,k,l)     )

! Initial state
t     =  0.
v     =  0.
u     =  0.
svm   =  0.
sl    =  0.
trup  =  1e9
tarr  =  0.
p1    =  0.
p2    =  0.
p3    =  0.
p4    =  0.
p5    =  0.
p6    =  0.
g1    =  0.
g2    =  0.
g3    =  0.
g4    =  0.
g5    =  0.
g6    =  0.

end subroutine

end module

