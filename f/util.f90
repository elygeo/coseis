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
where ( m0 ) i2 = ihypo + nnoff
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
integer :: j, k, l
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
integer :: i, j, k, l
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
integer :: j, k, l
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
integer :: j, k, l
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
integer :: i, j, k, l
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
integer :: n(3)
n = (/ size(f,1), size(f,2), size(f,3) /)
if ( n(1) > 1 ) f(:i1(1)-1,:,:) = r
if ( n(2) > 1 ) f(:,:i1(2)-1,:) = r
if ( n(3) > 1 ) f(:,:,:i1(3)-1) = r
if ( n(1) > 1 ) f(i2(1)+1:,:,:) = r
if ( n(2) > 1 ) f(:,i2(2)+1:,:) = r
if ( n(3) > 1 ) f(:,:,i2(3)+1:) = r
end subroutine

subroutine vectorsethalo( f, r, i1, i2 )
real, intent(inout) :: f(:,:,:,:)
real, intent(in) :: r
integer, intent(in) :: i1(3), i2(3)
integer :: n(3)
n = (/ size(f,1), size(f,2), size(f,3) /)
if ( n(1) > 1 ) f(:i1(1)-1,:,:,:) = r
if ( n(2) > 1 ) f(:,:i1(2)-1,:,:) = r
if ( n(3) > 1 ) f(:,:,:i1(3)-1,:) = r
if ( n(1) > 1 ) f(i2(1)+1:,:,:,:) = r
if ( n(2) > 1 ) f(:,i2(2)+1:,:,:) = r
if ( n(3) > 1 ) f(:,:,i2(3)+1:,:) = r
end subroutine

! Timer
real function timer( i )
integer, intent(in) :: i
integer, save :: clock0, clockrate, clockmax
integer(8), save :: timers(4)
integer :: clock1
if ( i == 0 ) then
  call system_clock( clock0, clockrate, clockmax )
  timer = 0
  timers = 0
else
  call system_clock( clock1 )
  timers = timers - clock0 + clock1
  if ( clock0 > clock1 ) timers = timers + clockmax
  clock0 = clock1
  timer = real( timers(i) ) / real( clockrate )
  timers(:i) = 0
end if
end function

! Write real binary timeseries
subroutine rwrite( str, val, ir )
character(*), intent(in) :: str
real, intent(in) :: val
integer, intent(in) :: ir
integer :: i
inquire( iolength=i ) val
if ( ir == 1 ) then
  open( 1, file=str, recl=i, form='unformatted', access='direct', status='new' )
else
  open( 1, file=str, recl=i, form='unformatted', access='direct', status='old' )
end if
write( 1, rec=ir ) val
close( 1 )
end subroutine
  
! Write buffered real binary timeseries
subroutine rwrite1( str, val, ir )
character(*), intent(in) :: str
real, intent(in) :: val(:)
integer, intent(in), optional :: ir
integer :: i, n, i0
n = size( val, 1 )
i0 = 0
if ( present( ir ) ) i0 = ir - n
if ( i0 < 0 ) then
  write ( 0, * )  'Error in rwrite1 ', trim( str ), ir, n
  stop
end if
if ( modulo( i0, n ) == 0 ) then
  inquire( iolength=i ) val
  if ( i0 == 0 ) then
    open( 1, file=str, recl=i, form='unformatted', access='direct', status='new' )
  else
    open( 1, file=str, recl=i, form='unformatted', access='direct', status='old' )
  end if
  i = i0 / n + 1
  write( 1, rec=i ) val
  close( 1 )
else
  inquire( iolength=i ) val(1)
  if ( i0 == 0 ) then
    open( 1, file=str, recl=i, form='unformatted', access='direct', status='new' )
  else
    open( 1, file=str, recl=i, form='unformatted', access='direct', status='old' )
  end if
  do i = 1, n
    write( 1, rec=i0+i ) val(i)
  end do
  close( 1 )
end if
end subroutine

! Scalar I/O
subroutine rio3( id, str, s1, i1, i2, ir )
real, intent(inout) :: s1(:,:,:)
integer, intent(in) :: id, i1(3), i2(3), ir
character(*), intent(in) :: str
integer :: nb, io, j1, k1, l1, j2, k2, l2
if ( id == 0 .or. ir < 1 .or. any( i1 > i2 ) ) return
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=nb ) s1(j1:j2,k1:k2,l1:l2)
if ( id > 0 .and. ir == 1 ) then
  open( 1, file=str, recl=nb, iostat=io, form='unformatted', access='direct', status='new' )
else
  open( 1, file=str, recl=nb, iostat=io, form='unformatted', access='direct', status='old' ) 
end if
if ( io /= 0 ) then
  write( 0, * ) 'Error opening file: ', trim( str )
  stop 
end if
if ( id < 0 ) then
  read(  1, rec=ir ) s1(j1:j2,k1:k2,l1:l2)
else
  write( 1, rec=ir ) s1(j1:j2,k1:k2,l1:l2)
end if
close( 1 )
end subroutine

! Vector I/O
subroutine rio4( id, str, w1, ic, i1, i2, ir )
real, intent(inout) :: w1(:,:,:,:)
integer, intent(in) :: id, ic, i1(3), i2(3), ir
character(*), intent(in) :: str
integer :: nb, io, j1, k1, l1, j2, k2, l2
if ( id == 0 .or. ir < 1 .or. any( i1 > i2 ) ) return
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=nb ) w1(j1:j2,k1:k2,l1:l2,ic)
if ( id > 0 .and. ir == 1 ) then
  open( 1, file=str, recl=nb, iostat=io, form='unformatted', access='direct', status='new' )
else
  open( 1, file=str, recl=nb, iostat=io, form='unformatted', access='direct', status='old' ) 
end if
if ( io /= 0 ) then
  write( 0, * ) 'Error opening file: ', trim( str )
  stop 
end if
if ( id < 0 ) then
  read(  1, rec=ir ) w1(j1:j2,k1:k2,l1:l2,ic)
else
  write( 1, rec=ir ) w1(j1:j2,k1:k2,l1:l2,ic)
end if
close( 1 )
end subroutine
  
end module

