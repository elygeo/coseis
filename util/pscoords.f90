! Routines for converting between lon/lat and PetaShake coordinates
! Geoffrey Ely, gely@ucsd.edu, 10/6/2006
module m_pscoords
use m_utm
contains

! Rotate PetaShake coordinates to UTM and un-project to lon/lat
subroutine ps2ll( x, i1, i2 )
implicit none
real, intent(inout) :: x(:,:,:,:)
integer, intent(in) :: i1, i2
real, parameter ::    &
  h   = 1,            &
  rot = 40,           &
  o1  = 936.9375,     &
  o2  = 3942428.5,    &
  pi  = 3.14159265
real :: c, s, x1, x2
integer :: j, k, l
c = cos( rot * pi / 180. ) * h
s = sin( rot * pi / 180. ) * h
do l = 1, size( x, 3 )
do k = 1, size( x, 2 )
do j = 1, size( x, 1 )
  x1 =  c * x(j,k,l,i1) + s * x(j,k,l,i2)
  x2 = -s * x(j,k,l,i1) + c * x(j,k,l,i2)
  x(j,k,l,i1) = x1
  x(j,k,l,i2) = x2
end do
end do
end do
x(:,:,:,i1) = x(:,:,:,i1) + o1
x(:,:,:,i2) = x(:,:,:,i2) + o2
call utm2ll( x, i1, i2, 11 )
end subroutine

! Project lon/lat to UTM and rotate to PetaShake coordinates
subroutine ll2ps( x, i1, i2 )
implicit none
real, intent(inout) :: x(:,:,:,:)
integer, intent(in) :: i1, i2
real, parameter ::    &
  h   = 1,            &
  rot = 40,           &
  o1  = 936.9375,     &
  o2  = 3942428.5,    &
  pi  = 3.14159265
real :: c, s, x1, x2
integer :: j, k, l
call ll2utm( x, i1, i2, 11 )
x(:,:,:,i1) = x(:,:,:,i1) - o1
x(:,:,:,i2) = x(:,:,:,i2) - o2
c = cos( rot * pi / 180. ) / h
s = sin( rot * pi / 180. ) / h
do l = 1, size( x, 3 )
do k = 1, size( x, 2 )
do j = 1, size( x, 1 )
  x1 = c * x(j,k,l,i1) - s * x(j,k,l,i2)
  x2 = s * x(j,k,l,i1) + c * x(j,k,l,i2)
  x(j,k,l,i1) = x1
  x(j,k,l,i2) = x2
end do
end do
end do
end subroutine

end module

