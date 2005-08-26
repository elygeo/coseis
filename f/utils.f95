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
implicit none
real, intent(in) :: a(:,:,:)
integer, intent(in) :: i1(3), i2(3)
integer :: i, j, k, l, j1, j2, k1, k2, l1, l2, flat
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
flat = 0
do i = 1, 3
  if ( i1(i) == i2(i) ) flat = i
end do
select case( flat )
case( 0 )
  do l = l1, l2; print *, 'l = ', l
  do j = j1, j2; print *, a(j,k1:k2,l)
  end do
  end do
case( 1 )
  do k = k1, k2; print *, a(j1:j2,k,l1:l2)
  end do
case default
  do j = j1, j2; print *, a(j,k1:k2,l1:l2)
  end do
end select
end subroutine

subroutine print4d( a, i1, i2, ia )
implicit none
real, intent(in) :: a(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), ia
integer :: i, j, k, l, j1, j2, k1, k2, l1, l2, flat
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
flat = 0
do i = 1, 3
  if ( i1(i) == i2(i) ) flat = i
end do
print *, 'i = ', ia
select case( flat )
case( 0 )
  do l = l1, l2; print *, 'l = ', l
  do j = j1, j2; print *, a(j,k1:k2,l,ia)
  end do
  end do
case( 1 )
  do k = k1, k2; print *, a(j1:j2,k,l1:l2,ia)
  end do
case default
  do j = j1, j2; print *, a(j,k1:k2,l1:l2,ia)
  end do
end select
end subroutine

end module

