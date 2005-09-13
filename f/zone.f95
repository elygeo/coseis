!------------------------------------------------------------------------------!
! ZONE

module zone_m
contains
subroutine zone( i1, i2, izone, nn, offset, i0, inrm )

implicit none
integer, intent(out) :: i1(3), i2(3)
integer, intent(in) :: izone(6), nn(3), offset(3), i0(3), inrm
integer :: shift(3)
logical :: m0(3), m1(3), m2(3), m3(3), m4(3)

i1 = izone(1:3)
i2 = izone(4:6)
shift = 0
if ( inrm /= 0 ) shift(inrm) = 1
m0 = i1 == 0 .and. i2 == 0
m1 = i1 == 0 .and. i2 /= 0
m2 = i1 /= 0 .and. i2 == 0
m3 = i1 < 0
m4 = i2 < 0
where ( m0 ) i1 = i0 - offset
where ( m0 ) i2 = i0 - offset + shift
where ( m1 ) i1 = i0 - offset + shift
where ( m2 ) i2 = i0 - offset
where ( m3 ) i1 = i1 + nn + 1
where ( m4 ) i2 = i2 + nn + 1
i1 = max( i1, 1 )
i2 = min( i2, nn )
i1 = i1 + offset
i2 = i2 + offset

end subroutine
end module

