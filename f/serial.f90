! Collective routines - hooks for parallelization
module m_collective
implicit none
contains

! Initialize
subroutine initialize( ipout, np0, master )
integer, intent(out) :: ipout, np0
logical, intent(out) :: master
ipout = 0
np0 = 1
master = .true.
end subroutine

! Finalize
subroutine finalize
end subroutine

! Processor rank
subroutine rank( ipout, ip3, np )
integer, intent(out) :: ipout, ip3(3)
integer, intent(in) :: np(3)
ip3 = np
ip3 = 0
ipout = 0
end subroutine

! Set master processor
subroutine setmaster( ip3master )
integer, intent(in) :: ip3master(3)
integer :: i
i = ip3master(1)
end subroutine

! Broadcast real 1d
subroutine rbroadcast1( r )
real, intent(inout) :: r(:)
r = r
end subroutine

! Reduce integer
subroutine ireduce( ii, i, op, i2d )
integer, intent(out) :: ii
integer, intent(in) :: i, i2d
character(*), intent(in) :: op
character :: a
a = op(1:1)
ii = i2d
ii = i
end subroutine

! Reduce real
subroutine rreduce( rr, r, op, i2d )
real, intent(out) :: rr
real, intent(in) :: r
integer, intent(in) :: i2d
character(*), intent(in) :: op
character :: a
a = op(1:1)
rr = i2d
rr = r
end subroutine

! Reduce real 1d
subroutine rreduce1( rr, r, op, i2d )
real, intent(out) :: rr(:)
real, intent(in) :: r(:)
integer, intent(in) :: i2d
character(*), intent(in) :: op
character :: a
a = op(1:1)
rr = i2d
rr = r
end subroutine

! Reduce real 2d
subroutine rreduce2( rr, r, op, i2d )
real, intent(out) :: rr(:,:)
real, intent(in) :: r(:,:)
integer, intent(in) :: i2d
character(*), intent(in) :: op
character :: a
a = op(1:1)
rr = i2d
rr = r
end subroutine

! Reduce extrema location, real 3d
subroutine reduceloc( rr, ii, r, op, n, noff, i2d )
real, intent(out) :: rr
real, intent(in) :: r(:,:,:)
integer, intent(out) :: ii(3)
integer, intent(in) :: n(3), noff(3), i2d
character(*), intent(in) :: op
character :: a
a = op(1:1)
ii = n + noff + i2d
select case( op )
case( 'min', 'allmin' ); ii = minloc( r );
case( 'max', 'allmax' ); ii = maxloc( r );
case default; stop 'unknown op in reduceloc'
end select
rr = r(ii(1),ii(2),ii(3))
end subroutine

! Vector send
subroutine vectorsend( f, i1, i2, i )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
f(1,1,1,1) = f(1,1,1,1) - i1(1) + i1(1) - i2(1) + i2(1) - i + i
end subroutine

! Vector receive
subroutine vectorrecv( f, i1, i2, i )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
f(1,1,1,1) = f(1,1,1,1) - i1(1) + i1(1) - i2(1) + i2(1) - i + i
end subroutine

! Scalar swap halo
subroutine scalarswaphalo( f, nhalo )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: nhalo
f(1,1,1) = f(1,1,1) - nhalo + nhalo
end subroutine

! Vector swap halo
subroutine vectorswaphalo( f, nhalo )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: nhalo
f(1,1,1,1) = f(1,1,1,1) - nhalo + nhalo
end subroutine

! Scalar field input/output
subroutine scalario( io, str, r, s1, i1, i2, i3, i4, ir, mpio )
use m_util
real, intent(inout) :: r, s1(:,:,:)
integer, intent(in) :: i1(3), i2(3), i3(3), i4(3), ir, mpio
character(*), intent(in) :: io, str
integer :: i
if ( any( i1 /= i3 .or. i2 /= i4 ) ) then
  write( 0, * ) 'Error in scalario: ', str, io
  write( 0, * ) i1, i2
  write( 0, * ) i3, i4
  stop
end if
if ( all( i1 == i2 ) .and. io == 'w' ) then
  r = s1(i1(1),i1(2),i1(3))
  return
end if
call rio3( io, str, s1, i1, i2, ir )
i = i3(1) + i4(1) + mpio
end subroutine

! Vector field component input/output
subroutine vectorio( io, str, r, w1, i1, i2, i3, i4, ic, ir, mpio )
use m_util
real, intent(inout) :: r, w1(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i3(3), i4(3), ic, ir, mpio
character(*), intent(in) :: io, str
integer :: i
if ( any( i1 /= i3 .or. i2 /= i4 ) ) then
  write( 0, * ) 'Error in vectorio: ', str, io
  write( 0, * ) i1, i2
  write( 0, * ) i3, i4
  stop
end if
if ( all( i1 == i2 ) .and. io == 'w' ) then
  r = w1(i1(1),i1(2),i1(3),ic)
  return
end if
call rio4( io, str, w1, i1, i2, ic, ir )
i = i3(1) + i4(1) + mpio
end subroutine

end module

