! Collective routines - serial version
module m_collective
use m_frio
implicit none
integer, parameter :: file_null = frio_file_null
contains

! Initialize
subroutine initialize( np0, ip )
integer, intent(out) :: np0, ip
np0 = 1
ip = 0
end subroutine

! Finalize
subroutine finalize
end subroutine

! Process rank
subroutine rank( ip3, ipid, np3in )
integer, intent(out) :: ip3(3), ipid
integer, intent(in) :: np3in(3)
ip3 = np3in
ip3 = 0
ipid = 0
end subroutine

! Barrier
subroutine barrier
end subroutine

! Broadcast real 1d
subroutine rbroadcast1( r, coords )
real, intent(inout) :: r(:)
integer, intent(in) :: coords(3)
integer :: i
r = r
i = coords(1)
end subroutine

! Broadcast real 4d
subroutine rbroadcast4( r, coords )
real, intent(inout) :: r(:,:,:,:)
integer, intent(in) :: coords(3)
integer :: i
r = r
i = coords(1)
end subroutine

! Reduce integer
subroutine ireduce( ii, i, op, coords )
integer, intent(out) :: ii
integer, intent(in) :: i, coords(3)
character(*), intent(in) :: op
character :: a
a = op(1:1)
ii = coords(1)
ii = i
end subroutine

! Reduce real 1d
subroutine rreduce1( rr, r, op, coords )
real, intent(out) :: rr(:)
real, intent(in) :: r(:)
integer, intent(in) :: coords(3)
character(*), intent(in) :: op
character :: a
a = op(1:1)
rr = coords(1)
rr = r
end subroutine

! Reduce real 2d
subroutine rreduce2( rr, r, op, coords )
real, intent(out) :: rr(:,:)
real, intent(in) :: r(:,:)
integer, intent(in) :: coords(3)
character(*), intent(in) :: op
character :: a
a = op(1:1)
rr = coords(1)
rr = r
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
subroutine rio1( fh, f, mode, filename, m, o, mpio, verb )
use m_frio
integer, intent(inout) :: fh
real, intent(inout) :: f(:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: m, o, mpio
logical, intent(in) :: verb
real :: ff(1,size(f))
integer :: i
if ( mode == 'w' ) ff(1,:) = f
call frio2( fh, ff, mode, filename, m, o, verb )
if ( mode == 'r' ) f = ff(1,:) 
i = mpio
end subroutine

! 2D input/output
subroutine rio2( fh, f, mode, filename, mm, nn, oo, mpio, verb )
use m_frio
integer, intent(inout) :: fh
real, intent(inout) :: f(:,:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: mm(:), nn(:), oo(:), mpio
logical, intent(in) :: verb
integer :: i
if ( any( nn < 1 ) ) return
i = size( oo )
call frio2( fh, f, mode, filename, mm(i), oo(i), verb )
i = mpio + nn(1)
end subroutine

end module

