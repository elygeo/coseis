!------------------------------------------------------------------------------!
! SETUP

module setup_m
contains
subroutine setup
use globals_m

implicit none

ip = 0

! Setup indices
nhalo = 1
offset = nhalo
where( hypocenter == 0 ) hypocenter = nn / 2 + mod( nn, 2 )
hypocenter = hypocenter + offset
if( nrmdim /= 0 ) nn(nrmdim) = nn(nrmdim) + 1
nm = nn + 2 * nhalo
i1node = nhalo + 1
i2node = nhalo + nn
i1cell = nhalo + 1
i2cell = nhalo + nn - 1
i1nodepml = i1node
i2nodepml = i2node
i1cellpml = i1cell
i2cellpml = i2cell
where ( bc(1:3) == 1 ) i1nodepml = i1node + npml
where ( bc(4:6) == 1 ) i2nodepml = i2node - npml
where ( bc(1:3) == 1 ) i1cellpml = i1cell + npml
where ( bc(4:6) == 1 ) i2cellpml = i2cell - npml

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
  x(j,k,l,3), &
  v(j,k,l,3), &
  u(j,k,l,3), &
  w1(j,k,l,3), &
  w2(j,k,l,3), &
  rho(j,k,l), &
  lam(j,k,l), &
  mu(j,k,l), &
  y(j,k,l), &
  s1(j,k,l), &
  s2(j,k,l), &
  p1(j1,k,l,3), &
  p2(j,k1,l,3), &
  p3(j,k,l1,3), &
  p4(j2,k,l,3), &
  p5(j,k2,l,3), &
  p6(j,k,l2,3), &
  g1(j1,k,l,3), &
  g2(j,k1,l,3), &
  g3(j,k,l1,3), &
  g4(j2,k,l,3), &
  g5(j,k2,l,3), &
  g6(j,k,l2,3), &
  dn1(npml), &
  dn2(npml), &
  dc1(npml), &
  dc2(npml) )

! Fault arrays
if ( nrmdim /= 0 ) then
  i2 = nm
  i2(nrmdim) = 1
else
  i2 = 0
end if
j = i2(1)
k = i2(2)
l = i2(3)
allocate( &
  nrm(j,k,l,3), &
  t0(j,k,l,3), &
  t1(j,k,l,3), &
  t2(j,k,l,3), &
  t3(j,k,l,3), &
  uslip(j,k,l), &
  vslip(j,k,l), &
  trup(j,k,l), &
  area(j,k,l), &
  fs(j,k,l), &
  fd(j,k,l), &
  dc(j,k,l), &
  co(j,k,l), &
  r(j,k,l), &
  f1(j,k,l), &
  f2(j,k,l), &
  tn(j,k,l), &
  ts(j,k,l) )

! Initial values
v = 0.
u = 0.
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
uslip = 0.
vslip = 0.
trup = 0.

end subroutine
end module

