module tscoords_m
use utm_m
contains

! Rotate TeraShake coordinates to UTM
subroutine ts2ll( x, y )
implicit none
real, intent(inout) :: x(:,:,:), y(:,:,:)
real, parameter ::                                                           &
  h   = 1,                                                                   &
  rot = 40,                                                                  &
  x0  = 132679.8125,                                                         &
  y0  = 3824867.,                                                            &
  pi  = 3.14159265
real :: c, s, xx, yy
integer :: j, k, l
c = cos( rot * pi / 180. ) * h
s = sin( rot * pi / 180. ) * h
do l = 1, size( x, 3 )
do k = 1, size( x, 2 )
do j = 1, size( x, 1 )
  xx =  c * x(j,k,l) + s * y(j,k,l)
  yy = -s * x(j,k,l) + c * y(j,k,l)
  x(j,k,l) = xx
  y(j,k,l) = yy
end do
end do
end do
x = x + x0
y = y + y0
call utm2ll( x, y, 11 )
end subroutine

! Rotate UTM to TeraShake coordinates
subroutine ll2ts( x, y )
implicit none
real, intent(inout) :: x(:,:,:), y(:,:,:)
real, parameter ::                                                           &
  h   = 1,                                                                   &
  rot = 40,                                                                  &
  x0  = 132679.8125,                                                         &
  y0  = 3824867.,                                                            &
  pi  = 3.14159265
real :: c, s, xx, yy
integer :: j, k, l
call ll2utm( x, y, 11 )
x = x - x0
y = y - y0
c = cos( rot * pi / 180. ) / h
s = sin( rot * pi / 180. ) / h
do l = 1, size( x, 3 )
do k = 1, size( x, 2 )
do j = 1, size( x, 1 )
  xx = c * x(j,k,l) - s * y(j,k,l)
  yy = s * x(j,k,l) + c * y(j,k,l)
  x(j,k,l) = xx
  y(j,k,l) = yy
end do
end do
end do
end subroutine

end module

