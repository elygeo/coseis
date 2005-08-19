!------------------------------------------------------------------------------!
! UTILS

module utils
contains
subroutine zoneselect( i1, i2, zone, n, hypocenter, nrmdim )

implicit none
integer, intent(in) :: zone(6), n(3), hypocenter(3), nrmdim
integer, intent(out) :: i1(3), i2(3)
integer :: shift(3) = 0

i1 = zone(1:3)
i2 = zone(4:6)
if ( nrmdim /= 0 ) shift(nrmdim) = 1
where ( i1 == 0 ) i1 = hypocenter + shift
where ( i2 == 0 ) i2 = max( hypocenter, i1 )
where ( i1 <= 0 ) i1 = i1 + n + 1
where ( i2 <= 0 ) i1 = i2 + n + 1

end subroutine
end module

