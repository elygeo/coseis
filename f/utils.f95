!------------------------------------------------------------------------------!
! UTILS

module utils_m
contains

subroutine zoneselect( i1, i2, zone, ng, offset, hypocenter, nrmdim )
implicit none
integer, intent(out) :: i1(3), i2(3)
integer, intent(in) :: zone(6), ng(3), offset(3), hypocenter(3), nrmdim
integer :: shift(3) = 0
i1 = zone(1:3)
i2 = zone(4:6)
if ( nrmdim /= 0 ) shift(nrmdim) = 1
where ( i1 == 0 ) i1 = hypocenter + shift
where ( i2 == 0 ) i2 = max( hypocenter, i1 )
where ( i1 <= 0 ) i1 = i1 + ng + 1
where ( i2 <= 0 ) i2 = i2 + ng + 1
i1 = i1 + offset
i2 = i2 + offset
end subroutine

subroutine print3d( a, i1, i2 )
real, intent(in) :: a(:,:,:)
integer, intent(in) :: i1(3), i2(3)
integer :: j, k, l, j1, j2, k1, k2, l1, l2
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
if ( j1 /= j2 ) then
  do l = l1, l2; print *, l
  do k = k1, k2; print *, a(j1:j2,k,l)
  end do
  end do
else
  do l = l1, l2; print *, a(j1,k1:k2,l)
  end do
end if
end subroutine

subroutine print4d( a, i1, i2, i )
real, intent(in) :: a(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
integer :: j, k, l, j1, j2, k1, k2, l1, l2
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
if ( j1 /= j2 ) then
  do l = l1, l2; print *, l
  do k = k1, k2; print *, a(j1:j2,k,l,i)
  end do
  end do
else
  do l = l1, l2; print *, a(j1,k1:k2,l,i)
  end do
end if
end subroutine

end module

