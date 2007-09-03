! Routines for converting between lon/lat and TeraShake coordinates
module m_tscoords
use m_utm
contains

! Rotate TeraShake coordinates to UTM and un-project to lon/lat
subroutine ts2ll( x, i1, i2 )
implicit none
real, intent(inout) :: x(:,:,:,:)
integer, intent(in) :: i1, i2
real, parameter ::    &
  h   = 1,            &
  rot = 40,           &
  o1  = 132679.8125,  &
  o2  = 3824867.,     &
  pi  = 3.14159265
real :: c, s, x1, x2
integer :: j, k, l
c = cos( rot * pi / 180. ) * h
s = sin( rot * pi / 180. ) * h
do l = 1, size( x, 3 )
do k = 1, size( x, 2 )
do j = 1, size( x, 1 )
  x1 = x(j,k,l,i1)
  x2 = x(j,k,l,i2)
  x(j,k,l,i1) =  c * x1 + s * x2 + o1
  x(j,k,l,i2) = -s * x1 + c * x2 + o2
end do
end do
end do
call utm2ll( x, i1, i2, 11 )
end subroutine

! Project lon/lat to UTM and rotate to TeraShake coordinates
subroutine ll2ts( x, i1, i2 )
implicit none
real, intent(inout) :: x(:,:,:,:)
integer, intent(in) :: i1, i2
real, parameter ::    &
  h   = 1,            &
  rot = 40,           &
  o1  = 132679.8125,  &
  o2  = 3824867.,     &
  pi  = 3.14159265
real :: c, s, x1, x2
integer :: j, k, l
call ll2utm( x, i1, i2, 11 )
c = cos( rot * pi / 180. ) / h
s = sin( rot * pi / 180. ) / h
do l = 1, size( x, 3 )
do k = 1, size( x, 2 )
do j = 1, size( x, 1 )
  x1 = x(j,k,l,i1) - o1
  x2 = x(j,k,l,i2) - o2
  x(j,k,l,i1) = c * x1 - s * x2
  x(j,k,l,i2) = s * x1 + c * x2
end do
end do
end do
end subroutine

end module

