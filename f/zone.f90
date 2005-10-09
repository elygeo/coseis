! Zone selection
module zone_m
contains
subroutine zone( i1, i2, nn, nnoff, ihypo, ifn )

implicit none
integer, intent(inout) :: i1(3), i2(3)
integer, intent(in) :: nn(3), nnoff(3), ihypo(3), ifn
integer :: nshift(3)
logical :: m0(3), m1(3), m2(3), m3(3), m4(3)

nshift = 0
if ( ifn /= 0 ) nshift(ifn) = 1

m0 = i1 == 0 .and. i2 == 0
m1 = i1 == 0 .and. i2 /= 0
m2 = i1 /= 0 .and. i2 == 0
m3 = i1 < 0
m4 = i2 < 0

where ( m0 ) i1 = ihypo - nnoff
where ( m0 ) i2 = ihypo - nnoff + nshift
where ( m1 ) i1 = ihypo - nnoff + nshift
where ( m2 ) i2 = ihypo - nnoff
where ( m3 ) i1 = i1 + nn + 1
where ( m4 ) i2 = i2 + nn + 1

i1 = max( i1, 1 )
i2 = min( i2, nn )

i1 = i1 + nnoff
i2 = i2 + nnoff

end subroutine
end module

