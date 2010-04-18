! miscellaneous utilities
module m_util
implicit none
contains

! array reciprocal
subroutine invert( f )
real, intent(inout) :: f(:,:,:)
integer :: n(3), j, k, l
n = (/ size(f,1), size(f,2), size(f,3) /)
do l = 1, n(3)
do k = 1, n(2)
do j = 1, n(1)
    if ( f(j,k,l) /= 0.0 ) f(j,k,l) = 1.0 / f(j,k,l)
end do
end do
end do
end subroutine

! squared distance to x0
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

! average of local eight values
subroutine average( f2, f1, i1, i2, d )
real, intent(out) :: f2(:,:,:)
real, intent(in) :: f1(:,:,:)
integer, intent(in) :: i1(3), i2(3), d
integer :: n(3), j, k, l
n = (/ size(f1,1), size(f1,2), size(f1,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in average'
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
call set_halo( f2, 0.0, i1, i2 )
end subroutine

! set array to real value outside specified region
subroutine set_halo( f, r, i1, i2 )
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

! L2 vector norm
subroutine vector_norm( f, w, i1, i2, di )
real, intent(out) :: f(:,:,:)
real, intent(in) :: w(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), di(3)
integer :: n(3), j, k, l
n = (/ size(f,1), size(f,2), size(f,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in vector_norm'
do l = i1(3), i2(3), di(3)
do k = i1(2), i2(2), di(2)
do j = i1(1), i2(1), di(1)
    f(j,k,l) = &
    w(j,k,l,1) * w(j,k,l,1) + &
    w(j,k,l,2) * w(j,k,l,2) + &
    w(j,k,l,3) * w(j,k,l,3)
end do
end do
end do
end subroutine

! Frobenius tensor norm - much faster than L2 norm for tensors
subroutine tensor_norm( f, w1, w2, i1, i2, di )
real, intent(out) :: f(:,:,:)
real, intent(in) :: w1(:,:,:,:), w2(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), di(3)
integer :: n(3), j, k, l
n = (/ size(f,1), size(f,2), size(f,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in tensor_norm'
do l = i1(3), i2(3), di(3)
do k = i1(2), i2(2), di(2)
do j = i1(1), i2(1), di(1)
    f(j,k,l) = &
    w1(j,k,l,1) * w1(j,k,l,1) + &
    w1(j,k,l,2) * w1(j,k,l,2) + &
    w1(j,k,l,3) * w1(j,k,l,3) + &
    ( w2(j,k,l,1) * w2(j,k,l,1) &
    + w2(j,k,l,2) * w2(j,k,l,2) &
    + w2(j,k,l,3) * w2(j,k,l,3) ) * 2.
end do
end do
end do
end subroutine

! in-place linear interpolation
subroutine interpolate( f, i3, i4, di )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: i3(3), i4(3), di(3)
integer :: i1(3), i2(3), n(3), i, j, k, l, d
real :: h1, h2
n = (/ size(f,1), size(f,2), size(f,3) /)
i1 = i3
i2 = i4
where( i1 < 1 ) i1 = i1 + (-i1 / di + 1) * di
where( i2 > n ) i2 = i1 + (n - i1) / di * di
d = di(1)
do i = 1, d - 1
    h1 = 1.0 / d * i
    h2 = 1.0 / d * ( d - i )
    do l = i1(3), i2(3), di(3)
    do k = i1(2), i2(2), di(2)
    do j = i1(1), i2(1) - d, d
        f(j+i,k,l) = h1 * f(j,k,l) + h2 * f(j+d,k,l)
    end do
    end do
    end do
end do
d = di(2)
do i = 1, d - 1
    h1 = 1.0 / d * i
    h2 = 1.0 / d * ( d - i )
    do l = i1(3), i2(3), di(1)
    do k = i1(2), i2(2) - d, d
    do j = i1(1), i2(1)
        f(j,k+i,l) = h1 * f(j,k,l) + h2 * f(j,k+d,l)
    end do
    end do
    end do
end do
d = di(3)
do i = 1, d - 1
    h1 = 1.0 / d * i
    h2 = 1.0 / d * ( d - i )
    do l = i1(3), i2(3) - d, d
    do k = i1(2), i2(2)
    do j = i1(1), i2(1)
        f(j,k,l+i) = h1 * f(j,k,l) + h2 * f(j,k,l+d)
    end do
    end do
    end do
end do
end subroutine

! time function
real function time_function( tfunc, tm, dt, period )
character(*), intent(in) :: tfunc
real, intent(in) :: tm, dt, period
real, parameter :: pi = 3.14159265
real :: t
time_function = 0.0
select case( tfunc )
case( 'const'  )
    time_function = 1.0
case( 'delta'  )
    if ( abs( tm ) < 0.25 * dt ) time_function = 1.0
case( 'brune' )
    time_function = -exp( -tm / period ) / period * (tm + period) + 1.0
case( 'dbrune' )
    time_function =  exp( -tm / period ) / period ** 2.0 * tm
case( 'ddbrune' )
    time_function = -exp( -tm / period ) / period ** 3.0 * (tm - period)
case( 'gaussian' )
    t = ( tm - 4.0 * period ) / period
    time_function = exp( -0.5 * t * t ) / ( period * sqrt( 2.0 * pi ) )
case( 'dgaussian', 'ricker1' )
    t = tm - period
    time_function = t * exp( -2.0 * (pi * t / period) ** 2.0 )
case( 'ddgaussian', 'ricker2' )
    t = ( pi * (tm - period) / period ) ** 2.0
    time_function = (1.0 - 2.0 * t) * exp( -t )
case default
    write( 0, * ) 'invalid time func: ', trim( tfunc )
    stop
end select
end function

! timer
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

