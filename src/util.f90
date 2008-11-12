! Miscellaneous utilities
module m_util
implicit none
contains

subroutine invert( f )
real, intent(inout) :: f(:,:,:)
integer :: n(3), j, k, l
n = (/ size(f,1), size(f,2), size(f,3) /)
do l = 1, n(3)
do k = 1, n(2)
do j = 1, n(1)
  if ( f(j,k,l) /= 0. ) f(j,k,l) = 1. / f(j,k,l)
end do
end do
end do
end subroutine

subroutine scalar_average( f2, f1, i1, i2, d )
real, intent(out) :: f2(:,:,:)
real, intent(in) :: f1(:,:,:)
integer, intent(in) :: i1(3), i2(3), d
integer :: n(3), j, k, l
n = (/ size(f1,1), size(f1,2), size(f1,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in scalar_average'
do l = i1(3), i2(3)
do k = i1(2), i2(2)
do j = i1(1), i2(1)
  f2(j,k,l) = 0.125 * &
  ( f1(j,k,l) + f1(j+d,k+d,l+d) &
  + f1(j,k+d,l+d) + f1(j+d,k,l) &
  + f1(j+d,k,l+d) + f1(j,k+d,l) &
  + f1(j+d,k+d,l) + f1(j,k,l+d) )
end do
end do
end do
call scalar_set_halo( f2, 0., i1, i2 )
end subroutine

subroutine vector_average( f2, f1, i1, i2, d )
real, intent(out) :: f2(:,:,:,:)
real, intent(in) :: f1(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), d
integer :: n(3), i, j, k, l
n = (/ size(f1,1), size(f1,2), size(f1,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in vector_average'
do i = 1, 3
do l = i1(3), i2(3)
do k = i1(2), i2(2)
do j = i1(1), i2(1)
  f2(j,k,l,i) = 0.125 * &
  ( f1(j,k,l,i) + f1(j+d,k+d,l+d,i) &
  + f1(j,k+d,l+d,i) + f1(j+d,k,l,i) &
  + f1(j+d,k,l+d,i) + f1(j,k+d,l,i) &
  + f1(j+d,k+d,l,i) + f1(j,k,l+d,i) )
end do
end do
end do
end do
call vector_set_halo( f2, 0., i1, i2 )
end subroutine

subroutine radius( r, x, x0, i1, i2 )
real, intent(out) :: r(:,:,:)
real, intent(in) :: x(:,:,:,:), x0(3)
integer, intent(in) :: i1(3), i2(3)
integer :: n(3), j, k, l
n = (/ size(r,1), size(r,2), size(r,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in radius'
do l = i1(3), i2(3)
do k = i1(2), i2(2)
do j = i1(1), i2(1)
  r(j,k,l) = &
  ( x(j,k,l,1) - x0(1) ) * ( x(j,k,l,1) - x0(1) ) + &
  ( x(j,k,l,2) - x0(2) ) * ( x(j,k,l,2) - x0(2) ) + &
  ( x(j,k,l,3) - x0(3) ) * ( x(j,k,l,3) - x0(3) )
end do
end do
end do
end subroutine

subroutine vector_norm( s, f, i1, i2, di )
real, intent(out) :: s(:,:,:)
real, intent(in) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), di(3)
integer :: n(3), j, k, l
n = (/ size(s,1), size(s,2), size(s,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in vector_norm'
do l = i1(3), i2(3), di(3)
do k = i1(2), i2(2), di(2)
do j = i1(1), i2(1), di(1)
  s(j,k,l) = &
  f(j,k,l,1) * f(j,k,l,1) + &
  f(j,k,l,2) * f(j,k,l,2) + &
  f(j,k,l,3) * f(j,k,l,3)
end do
end do
end do
end subroutine

subroutine tensor_norm( s, f1, f2, i1, i2, di )
real, intent(out) :: s(:,:,:)
real, intent(in) :: f1(:,:,:,:), f2(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), di(3)
integer :: n(3), j, k, l
n = (/ size(s,1), size(s,2), size(s,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in tensor_norm'
do l = i1(3), i2(3), di(3)
do k = i1(2), i2(2), di(2)
do j = i1(1), i2(1), di(1)
  s(j,k,l) = &
  f1(j,k,l,1) * f1(j,k,l,1) + &
  f1(j,k,l,2) * f1(j,k,l,2) + &
  f1(j,k,l,3) * f1(j,k,l,3) + &
  ( f2(j,k,l,1) * f2(j,k,l,1) &
  + f2(j,k,l,2) * f2(j,k,l,2) &
  + f2(j,k,l,3) * f2(j,k,l,3) ) * 2.
end do
end do
end do
end subroutine

subroutine scalar_set_halo( f, r, i1, i2 )
real, intent(inout) :: f(:,:,:)
real, intent(in) :: r
integer, intent(in) :: i1(3), i2(3)
integer :: n(3), i3(3), i4(3)
n = (/ size(f,1), size(f,2), size(f,3) /)
i3 = min( i1, n + 1 )
i4 = max( i2, 0 )
if ( n(1) > 1 ) f(:i3(1)-1,:,:) = r
if ( n(2) > 1 ) f(:,:i3(2)-1,:) = r
if ( n(3) > 1 ) f(:,:,:i3(3)-1) = r
if ( n(1) > 1 ) f(i4(1)+1:,:,:) = r
if ( n(2) > 1 ) f(:,i4(2)+1:,:) = r
if ( n(3) > 1 ) f(:,:,i4(3)+1:) = r
end subroutine

subroutine vector_set_halo( f, r, i1, i2 )
real, intent(inout) :: f(:,:,:,:)
real, intent(in) :: r
integer, intent(in) :: i1(3), i2(3)
integer :: n(3), i3(3), i4(3)
n = (/ size(f,1), size(f,2), size(f,3) /)
i3 = min( i1, n + 1 )
i4 = max( i2, 0 )
if ( n(1) > 1 ) f(:i3(1)-1,:,:,:) = r
if ( n(2) > 1 ) f(:,:i3(2)-1,:,:) = r
if ( n(3) > 1 ) f(:,:,:i3(3)-1,:) = r
if ( n(1) > 1 ) f(i4(1)+1:,:,:,:) = r
if ( n(2) > 1 ) f(:,i4(2)+1:,:,:) = r
if ( n(3) > 1 ) f(:,:,i4(3)+1:,:) = r
end subroutine

! Time function
real function time_function( tfunc, tm, dt, period )
character(*), intent(in) :: tfunc
real, intent(in) :: tm, dt, period
real, parameter :: pi = 3.14159
real :: t
time_function = 0.
select case( tfunc )
case( 'const'  )
  time_function = 1.
case( 'delta'  )
  if ( abs( tm ) < 0.25 * dt ) time_function = 1.
case( 'brune' )
  time_function = exp( -tm / period ) * tm / ( period * period )
case( 'ricker1' )
  t = tm - period
  time_function = t * exp( -2. * ( pi * t / period ) ** 2. )
case( 'ricker2' )
  t = ( pi * ( tm - period ) / period ) ** 2.
  time_function = ( 1. - 2. * t ) * exp( -t )
case default
  write( 0, * ) 'invalid time func: ', trim( tfunc )
  stop
end select
end function

! Timer
real function timer( i )
integer, intent(in) :: i
integer, save :: clock0, clockrate, clockmax
integer(8), save :: timers(8)
integer :: clock1
if ( i == 0 ) then
  call system_clock( clock0, clockrate, clockmax )
  timer = 0
  timers = 0
else
  call system_clock( clock1 )
  timers = timers + clock1 - clock0
  if ( clock0 > clock1 ) timers = timers + clockmax
  clock0 = clock1
  timer = real( timers(i) ) / real( clockrate )
  timers(:i) = 0
end if
end function

end module

