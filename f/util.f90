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
integer :: j1, k1, l1, j2, k2, l2
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
where( x(j1:j2,k1:k2,l1:l2,1) >= x1(1) &
 .and. x(j1:j2,k1:k2,l1:l2,2) >= x1(2) &
 .and. x(j1:j2,k1:k2,l1:l2,3) >= x1(3) &
 .and. x(j1:j2,k1:k2,l1:l2,1) <= x2(1) &
 .and. x(j1:j2,k1:k2,l1:l2,2) <= x2(2) &
 .and. x(j1:j2,k1:k2,l1:l2,3) <= x2(3) ) s = r
end subroutine

subroutine scalaraverage( fa, f, i1, i2, d )
real, intent(out) :: fa(:,:,:)
real, intent(in) :: f(:,:,:)
integer, intent(in) :: i1(3), i2(3), d
integer :: j, k, l, n(3)
n = (/ size(f,1), size(f,2), size(f,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in scalaraverage'
forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
  fa(j,k,l) = 0.125 * &
  ( f(j,k,l) + f(j+d,k+d,l+d) &
  + f(j,k+d,l+d) + f(j+d,k,l) &
  + f(j+d,k,l+d) + f(j,k+d,l) &
  + f(j+d,k+d,l) + f(j,k,l+d) )
end forall
call scalarsethalo( fa, 0., i1, i2 )
end subroutine

subroutine vectoraverage( fa, f, i1, i2, d )
real, intent(out) :: fa(:,:,:,:)
real, intent(in) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), d
integer :: i, j, k, l, n(3)
n = (/ size(f,1), size(f,2), size(f,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in vectoraverage'
forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3), i=1:3 )
  fa(j,k,l,i) = 0.125 * &
  ( f(j,k,l,i) + f(j+d,k+d,l+d,i) &
  + f(j,k+d,l+d,i) + f(j+d,k,l,i) &
  + f(j+d,k,l+d,i) + f(j,k+d,l,i) &
  + f(j+d,k+d,l,i) + f(j,k,l+d,i) )
end forall
call vectorsethalo( fa, 0., i1, i2 )
end subroutine

subroutine radius( r, x, x0, i1, i2 )
real, intent(out) :: r(:,:,:)
real, intent(in) :: x(:,:,:,:), x0(3)
integer, intent(in) :: i1(3), i2(3)
integer :: j, k, l, n(3)
n = (/ size(r,1), size(r,2), size(r,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in radius'
forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
  r(j,k,l) = &
  ( x(j,k,l,1) - x0(1) ) * ( x(j,k,l,1) - x0(1) ) + &
  ( x(j,k,l,2) - x0(2) ) * ( x(j,k,l,2) - x0(2) ) + &
  ( x(j,k,l,3) - x0(3) ) * ( x(j,k,l,3) - x0(3) )
end forall
end subroutine

subroutine vectornorm( s, f, i1, i2 )
real, intent(out) :: s(:,:,:)
real, intent(in) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3)
integer :: j, k, l, n(3)
n = (/ size(s,1), size(s,2), size(s,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in vectornorm'
forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
  s(j,k,l) = &
  f(j,k,l,1) * f(j,k,l,1) + &
  f(j,k,l,2) * f(j,k,l,2) + &
  f(j,k,l,3) * f(j,k,l,3)
end forall
end subroutine

subroutine tensornorm( s, w1, w2, i1, i2 )
real, intent(out) :: s(:,:,:)
real, intent(in) :: w1(:,:,:,:), w2(:,:,:,:)
integer, intent(in) :: i1(3), i2(3)
integer :: j, k, l, n(3)
n = (/ size(s,1), size(s,2), size(s,3) /)
if ( any( i1 < 1 .or. i2 > n ) ) stop 'error in tensornorm'
forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
  s(j,k,l) = &
  w1(j,k,l,1) * w1(j,k,l,1) + &
  w1(j,k,l,2) * w1(j,k,l,2) + &
  w1(j,k,l,3) * w1(j,k,l,3) + &
  ( w2(j,k,l,1) * w2(j,k,l,1) &
  + w2(j,k,l,2) * w2(j,k,l,2) &
  + w2(j,k,l,3) * w2(j,k,l,3) ) * 2.
end forall
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

! Timeseries I/O
subroutine frio1( id, str, ft, ir, nr )
real, intent(inout) :: ft(:)
integer, intent(in) :: id, ir, nr
character(*), intent(in) :: str
integer :: fh, n, i0, nb, io, i
n = size( ft )
if ( n == 0 ) return
i0 = ir - n
if ( i0 < 0 ) then
  write ( 0, * )  'Error in rio1 ', trim( str ), ir, n
  stop
end if
fh = id + 65536
if ( modulo( i0, n ) == 0 ) then
  inquire( iolength=nb ) ft
  if ( id < 0 .or. i0 > 0 ) then
    open( fh, file=str, recl=nb, iostat=io, form='unformatted', access='direct', status='old' )
  else
    open( fh, file=str, recl=nb, iostat=io, form='unformatted', access='direct', status='new' )
  end if
  if ( io /= 0 ) then
    if ( io /= 0 ) write( 0, * ) 'Error: opening file: ', trim( str )
    stop
  end if
  i = i0 / n + 1
  if ( id < 0 ) then
    read( fh, rec=i ) ft
  else
    write( fh, rec=i ) ft
  end if
else
  inquire( iolength=nb ) ft(1)
  if ( id < 0 .or. i0 > 0 ) then
    open( fh, file=str, recl=nb, iostat=io, form='unformatted', access='direct', status='old' )
  else
    open( fh, file=str, recl=nb, iostat=io, form='unformatted', access='direct', status='new' )
  end if
  if ( io /= 0 ) then
    if ( io /= 0 ) write( 0, * ) 'Error: opening file: ', trim( str )
    stop
  end if
  if ( id < 0 ) then
    do i = 1, n; read( fh, rec=i0+i ) ft(i); end do
  else
    do i = 1, n; write( fh, rec=i0+i ) ft(i); end do
  end if
end if
if ( ir == nr ) close( fh )
end subroutine

! Scalar I/O
subroutine frio3( id, str, s1, i1, i2, ir, nr )
real, intent(inout) :: s1(:,:,:)
integer, intent(in) :: id, i1(3), i2(3), ir, nr
character(*), intent(in) :: str
integer :: fh, nb, io, j1, k1, l1, j2, k2, l2
if ( id == 0 .or. ir < 1 .or. any( i1 > i2 ) ) return
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
fh = id + 65536
inquire( iolength=nb ) s1(j1:j2,k1:k2,l1:l2)
if ( id < 0 .or. ir > 1 ) then
  open( fh, file=str, recl=nb, iostat=io, form='unformatted', access='direct', status='old' ) 
else
  open( fh, file=str, recl=nb, iostat=io, form='unformatted', access='direct', status='new' )
end if
if ( io /= 0 ) then
  if ( io /= 0 ) write( 0, * ) 'Error: opening file: ', trim( str )
  stop
end if
if ( id < 0 ) then
  read(  fh, rec=ir ) s1(j1:j2,k1:k2,l1:l2)
else
  write( fh, rec=ir ) s1(j1:j2,k1:k2,l1:l2)
end if
if ( ir == nr ) close( fh )
end subroutine

! Vector I/O
subroutine frio4( id, str, w1, ic, i1, i2, ir, nr )
real, intent(inout) :: w1(:,:,:,:)
integer, intent(in) :: id, ic, i1(3), i2(3), ir, nr
character(*), intent(in) :: str
integer :: fh, nb, io, j1, k1, l1, j2, k2, l2
if ( id == 0 .or. ir < 1 .or. any( i1 > i2 ) ) return
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
fh = id + 65536
inquire( iolength=nb ) w1(j1:j2,k1:k2,l1:l2,ic)
if ( id < 0 .or. ir > 1 ) then
  open( fh, file=str, recl=nb, iostat=io, form='unformatted', access='direct', status='old' ) 
else
  open( fh, file=str, recl=nb, iostat=io, form='unformatted', access='direct', status='new' )
end if
if ( io /= 0 ) then
  if ( io /= 0 ) write( 0, * ) 'Error: opening file: ', trim( str )
  stop
end if
if ( id < 0 ) then
  read(  fh, rec=ir ) w1(j1:j2,k1:k2,l1:l2,ic)
else
  write( fh, rec=ir ) w1(j1:j2,k1:k2,l1:l2,ic)
end if
if ( ir == nr ) close( fh )
end subroutine
  
end module

