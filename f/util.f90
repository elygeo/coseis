! Misc utilities
module m_util
implicit none
contains

subroutine zone( i1, i2, nn, nnoff, ihypo, faultnormal )
integer, intent(inout) :: i1(3), i2(3)
integer, intent(in) :: nn(3), nnoff(3), ihypo(3), faultnormal
integer :: i, nshift(3)
logical :: m0(3), m1(3), m2(3), m3(3), m4(3)
nshift = 0
i = abs( faultnormal )
if ( i /= 0 ) nshift(i) = 1
m0 = i1 == 0 .and. i2 == 0
m1 = i1 == 0 .and. i2 /= 0
m2 = i1 /= 0 .and. i2 == 0
m3 = i1 < 0
m4 = i2 < 0
where ( m0 ) i1 = ihypo + nnoff
where ( m0 ) i2 = ihypo + nnoff + nshift
where ( m1 ) i1 = ihypo + nnoff + nshift
where ( m2 ) i2 = ihypo + nnoff
where ( m3 ) i1 = i1 + nn + 1
where ( m4 ) i2 = i2 + nn + 1
i1 = max( i1, 1 )
i2 = min( i2, nn )
i1 = i1 - nnoff
i2 = i2 - nnoff
end subroutine

subroutine cube( s, x, i1, i2, x1, x2, r )
real, intent(inout) :: s(:,:,:)
real, intent(in) :: x(:,:,:,:), x1(3), x2(3), r
integer, intent(in) :: i1(3), i2(3)
integer :: j, k, l
do l = i1(3), i2(3)
do k = i1(2), i2(2)
do j = i1(1), i2(1)
if( x(j,k,l,1) >= x1(1) .and. x(j,k,l,1) <= x2(1) .and. &
    x(j,k,l,2) >= x1(2) .and. x(j,k,l,2) <= x2(2) .and. &
    x(j,k,l,3) >= x1(3) .and. x(j,k,l,3) <= x2(3) ) s(j,k,l) = r
end do
end do
end do
end subroutine

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

subroutine scalaraverage( fa, f, i1, i2, d )
real, intent(out) :: fa(:,:,:)
real, intent(in) :: f(:,:,:)
integer, intent(in) :: i1(3), i2(3), d
integer :: n(3), j, k, l
n = (/ size(f,1), size(f,2), size(f,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in scalaraverage'
do l = i1(3), i2(3)
do k = i1(2), i2(2)
do j = i1(1), i2(1)
  fa(j,k,l) = 0.125 * &
  ( f(j,k,l) + f(j+d,k+d,l+d) &
  + f(j,k+d,l+d) + f(j+d,k,l) &
  + f(j+d,k,l+d) + f(j,k+d,l) &
  + f(j+d,k+d,l) + f(j,k,l+d) )
end do
end do
end do
call scalarsethalo( fa, 0., i1, i2 )
end subroutine

subroutine vectoraverage( fa, f, i1, i2, d )
real, intent(out) :: fa(:,:,:,:)
real, intent(in) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), d
integer :: n(3), i, j, k, l
n = (/ size(f,1), size(f,2), size(f,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in vectoraverage'
do i = 1, 3
do l = i1(3), i2(3)
do k = i1(2), i2(2)
do j = i1(1), i2(1)
  fa(j,k,l,i) = 0.125 * &
  ( f(j,k,l,i) + f(j+d,k+d,l+d,i) &
  + f(j,k+d,l+d,i) + f(j+d,k,l,i) &
  + f(j+d,k,l+d,i) + f(j,k+d,l,i) &
  + f(j+d,k+d,l,i) + f(j,k,l+d,i) )
end do
end do
end do
end do
call vectorsethalo( fa, 0., i1, i2 )
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

subroutine vectornorm( s, f, i1, i2 )
real, intent(out) :: s(:,:,:)
real, intent(in) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3)
integer :: n(3), j, k, l
n = (/ size(s,1), size(s,2), size(s,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in vectornorm'
do l = i1(3), i2(3)
do k = i1(2), i2(2)
do j = i1(1), i2(1)
  s(j,k,l) = &
  f(j,k,l,1) * f(j,k,l,1) + &
  f(j,k,l,2) * f(j,k,l,2) + &
  f(j,k,l,3) * f(j,k,l,3)
end do
end do
end do
end subroutine

subroutine tensornorm( s, w1, w2, i1, i2 )
real, intent(out) :: s(:,:,:)
real, intent(in) :: w1(:,:,:,:), w2(:,:,:,:)
integer, intent(in) :: i1(3), i2(3)
integer :: n(3), j, k, l
n = (/ size(s,1), size(s,2), size(s,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in tensornorm'
do l = i1(3), i2(3)
do k = i1(2), i2(2)
do j = i1(1), i2(1)
  s(j,k,l) = &
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

subroutine scalarsethalo( f, r, i1, i2 )
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

subroutine vectorsethalo( f, r, i1, i2 )
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

! Erase comments and MATLAB characters, parse string for the first token 
subroutine strtok( str, tok )
character(*), intent(inout) :: str
character(*), intent(out) :: tok
integer :: i
i = index( str, '%' )         ! find start of comment
if ( i > 0 ) str(i:) = ' '    ! erase comment if present
do
  i = scan( str, "{}=[]',;" ) ! find next MATLAB character
  if ( i == 0 ) exit          ! move on if none found
  str(i:i) = ' '              ! erase character
end do
tok = ''
i = verify( str, ' ' )        ! find first non space
if ( i == 0 ) return          ! return if all blank
str = str(i:)                 ! strip leading spaces
i = scan( str, ' ' )          ! find space delimiter
if ( i == 0 ) then            ! only one word
  tok = str                   ! tok get word
  str = ''                    ! empty str
else                          ! more than one word
  tok = str(:i-1)             ! tok gets fist word
  str = str(i+1:)             ! str gets remainder
  i = verify( str, ' ' )      ! find first non space
  if ( i == 0 ) return        ! return if all blank
  str = str(i:)               ! strip leading spaces
end if
end subroutine
  
end module

