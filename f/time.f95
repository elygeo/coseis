!------------------------------------------------------------------------------!
! TIME

module time_m
contains
subroutine time
use globals_m

implicit none
integer :: i, j, k, l, i1(3), i2(3)

! Time integration
t = t + dt
v = v + dt * w1
u = u + dt * v

! Fault time integration
if ( ifn /= 0 ) then
  i1 = 1
  i2 = nm
  i1(ifn) = ifault
  i2(ifn) = ifault
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  i1(ifn) = ifault + 1
  i2(ifn) = ifault + 1
  j3 = i1(1); j4 = i2(1)
  k3 = i1(2); k4 = i2(2)
  l3 = i1(3); l4 = i2(3)
  sl = sl + dt * sv
end if

end subroutine
end module

