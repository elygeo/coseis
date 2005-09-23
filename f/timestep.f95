!------------------------------------------------------------------------------!
! TIMESTEP

module timestep_m
contains
subroutine timestep
use globals_m

implicit none
integer :: i, j, k, l, i1(3), j1, k1, l1, i2(3), j2, k2, l2

! Time integration
it = it + 1
t  = t  + dt
v  = v  + dt * w1
u  = u  + dt * v

! Fault time integration
if ( ifn /= 0 ) then
  i1 = 1
  i2 = nm
  i1(ifn) = ihypo(ifn)
  i2(ifn) = ihypo(ifn)
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  i1(ifn) = ihypo(ifn) + 1
  i2(ifn) = ihypo(ifn) + 1
  j3 = i1(1); j4 = i2(1)
  k3 = i1(2); k4 = i2(2)
  l3 = i1(3); l4 = i2(3)
  t1 = v(j3:j4,k3:k4,l3:l4,:) - v(j1:j2,k1:k2,l1:l2,:)
  sv = sqrt( sum( t1 * t1, 4 ) )
  sl = sl + dt * sv
  where ( trup == 0. .and. sv > truptol ) trup = t
end if

end subroutine
end module

