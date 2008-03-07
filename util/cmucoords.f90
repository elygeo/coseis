! CMU meters to lon/lat, bilinear interpolation
module m_cmucoords
contains
subroutine cmu2ll( x, i1, i2 )
implicit none
real, intent(inout) :: x(:,:,:,:)
integer, intent(in) :: i1, i2
real, parameter :: &
  c1(2) = (/ -121.0     , 34.5      /), &
  c2(2) = (/ -116.032285, 31.082920 /), &
  c3(2) = (/ -118.951292, 36.621696 /), &
  c4(2) = (/ -113.943965, 33.122341 /)
real :: x1, x2, h1, h2, h3, h4
integer :: j, k, l
do l = 1, size( x, 3 )
do k = 1, size( x, 2 )
do j = 1, size( x, 1 )
  x1 = x(j,k,l,i1) / 600000.
  x2 = x(j,k,l,i2) / 300000.
  h1 = ( 1. - x1 ) * ( 1. - x2 )
  h2 = x1 * ( 1. - x2 )
  h3 = ( 1. - x1 ) * x2
  h4 = x1 * x2
  x(j,k,l,i1) = h1 * c1(1) + h2 * c2(1) + h3 * c3(1) + h4 * c4(1)
  x(j,k,l,i2) = h1 * c1(2) + h2 * c2(2) + h3 * c3(2) + h4 * c4(2)
end do
end do
end do
end subroutine
end module

