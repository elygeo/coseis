!------------------------------------------------------------------------------!
! ARRAYS

module arrays_m
contains
subroutine arrays
use globals_m

implicit none

! 3D arrays
i2 = nm
j = i2(1)
k = i2(2)
l = i2(3)
i1 = 0
i2 = 0
where ( bc(1:3) == 1 ) i1 = npml
where ( bc(4:6) == 1 ) i2 = npml
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
allocate( &
  ! 3D static variables
  mr(j,k,l),    & ! mass ratio
  lm(j,k,l),    & ! Lame parameter
  mu(j,k,l),    & ! Lame parameter
  y(j,k,l),     & ! Hourglass constant
  x(j,k,l,3),   & ! node locations
  ! 3D simulation state
  v(j,k,l,3),   & ! velocity
  u(j,k,l,3),   & ! displacement
  ! 3D temporaty storage
  w1(j,k,l,3),  & ! stress, acceleration
  w2(j,k,l,3),  & ! stress
  s1(j,k,l),    &
  s2(j,k,l),    &
  ! PML state
  p1(j1,k,l,3), & ! PML momentum
  p2(j,k1,l,3), & ! PML momentum
  p3(j,k,l1,3), & ! PML momentum
  p4(j2,k,l,3), & ! PML momentum
  p5(j,k2,l,3), & ! PML momentum
  p6(j,k,l2,3), & ! PML momentum
  g1(j1,k,l,3), & ! PML gradient
  g2(j,k1,l,3), & ! PML gradient
  g3(j,k,l1,3), & ! PML gradient
  g4(j2,k,l,3), & ! PML gradient
  g5(j,k2,l,3), & ! PML gradient
  g6(j,k,l2,3)  ) ! PML gradient

! Fault arrays
i2 = nf
j = i2(1)
k = i2(2)
l = i2(3)
allocate( &
  ! Fault static variables
  fs(j,k,l),    & ! coef of sliding friction
  fd(j,k,l),    & ! coef of dynamic friction
  dc(j,k,l),    & ! slip weakening distance
  co(j,k,l),    & ! cohesion
  area(j,k,l),  & ! fault element area
  r(j,k,l),     & ! radius to hypocenter
  nrm(j,k,l,3), & ! fault normal vectors
  t0(j,k,l,3),  & ! initial traction
  ! Fault simulation state
  vs(j,k,l),    & ! slip velocity
  us(j,k,l),    & ! slip
  trup(j,k,l),  & ! rupture time
  ! Fault temporary storage
  t1(j,k,l,3),  & ! stress input, normal taction
  t2(j,k,l,3),  & ! stress input, shear traction
  t3(j,k,l,3),  & ! traction input, total traction
  tn(j,k,l),    & ! normal traction
  ts(j,k,l),    & ! shear traction
  f1(j,k,l),    & ! friction
  f2(j,k,l)     ) ! friction

! Initial state
v  = 0.
u  = 0.
p1 = 0.
p2 = 0.
p3 = 0.
p4 = 0.
p5 = 0.
p6 = 0.
g1 = 0.
g2 = 0.
g3 = 0.
g4 = 0.
g5 = 0.
g6 = 0.
us = 0.
vs = 0.
trup = 0.

end subroutine
end module

