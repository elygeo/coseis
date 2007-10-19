! Collective routines - hooks for parallelization
module m_collective
implicit none
contains

! Initialize
subroutine initialize( np0, ip, master )
integer, intent(out) :: np0, ip
logical, intent(out) :: master
np0 = 1
ip = 0
master = .true.
end subroutine

! Finalize
subroutine finalize
end subroutine

! Process rank
subroutine rank( ip3, np )
integer, intent(out) :: ip3(3)
integer, intent(in) :: np(3)
ip3 = np
ip3 = 0
end subroutine

! Set root process
subroutine setroot( ip3root )
integer, intent(in) :: ip3root(3)
integer :: i
i = ip3root(1)
end subroutine

! Broadcast real 1d
subroutine rbroadcast1( r )
real, intent(inout) :: r(:)
r = r
end subroutine

! Barrier
subroutine barrier
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

! Scalar swap halo
subroutine scalarswaphalo( f, n )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: n(3)
return
f(1,1,1) = f(1,1,1) - n(1) + n(1)
end subroutine

! Vector swap halo
subroutine vectorswaphalo( f, n )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: n(3)
return
f(1,1,1,1) = f(1,1,1,1) - n(1) + n(1)
end subroutine

! Time series I/O
subroutine rio1( id, mpio, str, ft, ir, nr )
use m_frio
real, intent(inout) :: ft(:)
integer, intent(in) :: id, mpio, ir, nr
character(*), intent(in) :: str
integer :: i
if ( size( ft ) == 0 .or. id == 0 ) return
if ( size( ft ) > ir .or. ir > nr ) stop 'error in rio1'
call frio1( id, str, ft, ir, nr )
i = mpio
end subroutine

! Scalar field I/O
subroutine rio3( id, mpio, r, str, f, i1, i2, i3, i4, ifill, ir, nr )
use m_frio
real, intent(inout) :: r, f(:,:,:)
integer, intent(in) :: id, mpio, i1(3), i2(3), i3(3), i4(3), ifill(3), ir, nr
character(*), intent(in) :: str
integer :: i
if ( id == 0 ) return
if ( any( i1 /= i3 .or. i2 /= i4 .or. ir > nr ) ) then
  write( 0, * ) 'Error in rio3: ', id, str
  write( 0, * ) i1, i2
  write( 0, * ) i3, i4
  stop
end if
if ( id > 0 .and. all( i1 == i2 ) ) then
  r = f(i1(1),i1(2),i1(3))
  return
end if
call frio3( id, str, f, i1, i2, ifill, ir, nr )
i = i3(1) + i4(1) + mpio
end subroutine

! Vector field component I/O
subroutine rio4( id, mpio, r, str, f, ic, i1, i2, i3, i4, ifill, ir, nr )
use m_frio
real, intent(inout) :: r, f(:,:,:,:)
integer, intent(in) :: id, mpio, ic, i1(3), i2(3), i3(3), i4(3), ifill(3), ir, nr
character(*), intent(in) :: str
integer :: i
if ( id == 0 ) return
if ( any( i1 /= i3 .or. i2 /= i4 .or. ir > nr ) ) then
  write( 0, * ) 'Error in rio4: ', id, str
  write( 0, * ) i1, i2
  write( 0, * ) i3, i4
  stop
end if
if ( id > 0 .and. all( i1 == i2 ) ) then
  r = f(i1(1),i1(2),i1(3),ic)
  return
end if
call frio4( id, str, f, ic, i1, i2, ifill, ir, nr )
i = i3(1) + i4(1) + mpio
end subroutine

end module

