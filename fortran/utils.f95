!------------------------------------------------------------------------------!
! UTILS

module utils
contains
subroutine zoneselect( i1, i2, zone, ng, hypocenter, nrmdim )

implicit none
integer, intent(out) :: i1(3), i2(3)
integer, intent(in) :: zone(6), ng(3), hypocenter(3), nrmdim
integer :: shift(3) = 0

i1 = zone(1:3)
i2 = zone(4:6)
if ( nrmdim /= 0 ) shift(nrmdim) = 1
where ( i1 == 0 ) i1 = hypocenter + shift
where ( i2 == 0 ) i2 = max( hypocenter, i1 )
where ( i1 <= 0 ) i1 = i1 + ng + 1
where ( i2 <= 0 ) i2 = i2 + ng + 1

end subroutine
end module

