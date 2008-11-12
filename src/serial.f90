! Collective routines - serial version
module m_collective
use m_frio
implicit none
integer :: file_null = -1
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
subroutine rank( ip3, ipid, np )
integer, intent(out) :: ip3(3), ipid
integer, intent(in) :: np(3)
ip3 = np
ip3 = 0
ipid = 0
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
subroutine scalar_swap_halo( f, n )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: n(3)
return
f(1,1,1) = f(1,1,1) - n(1) + n(1)
end subroutine

! Vector swap halo
subroutine vector_swap_halo( f, n )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: n(3)
return
f(1,1,1,1) = f(1,1,1,1) - n(1) + n(1)
end subroutine

! 1D input/output
subroutine rio1( fh, f, mode, filename, m, o, mpio )
use m_frio
integer, intent(inout) :: fh
real, intent(inout) :: f(:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: m, o, mpio
real :: ff(1,size(f))
integer :: i
if ( mode == 'w' ) ff(1,:) = f
call frio2( fh, ff, mode, filename, m, o )
if ( mode == 'r' ) f = ff(1,:) 
i = mpio
end subroutine

! 2D input/output
subroutine rio2( fh, f, mode, filename, mm, nn, oo, mpio )
use m_frio
integer, intent(inout) :: fh
real, intent(inout) :: f(:,:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: mm(:), nn(:), oo(:), mpio
integer :: i
if ( any( nn < 1 ) ) return
i = size( oo )
call frio2( fh, f, mode, filename, mm(i), oo(i) )
i = mpio + nn(1)
end subroutine

end module

