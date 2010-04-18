! collective routines - serial version
module m_collective
use m_fio
implicit none
integer, parameter :: file_null = fio_file_null
contains

! initialize
subroutine initialize( np0, ip )
integer, intent(out) :: np0, ip
ip = 0
np0 = 1
end subroutine

! finalize
subroutine finalize
end subroutine

! process rank
subroutine rank( ip3, ipid, nproc3 )
integer, intent(out) :: ip3(3), ipid
integer, intent(in) :: nproc3(3)
ip3 = nproc3
ip3 = 0
ipid = 0
end subroutine

! barrier
subroutine barrier
end subroutine

! broadcast real 1d
subroutine rbroadcast1( f1, coords )
real, intent(inout) :: f1(:)
integer, intent(in) :: coords(3)
integer :: i
f1 = f1
i = coords(1)
end subroutine

! broadcast real 4d
subroutine rbroadcast4( f4, coords )
real, intent(inout) :: f4(:,:,:,:)
integer, intent(in) :: coords(3)
integer :: i
f4 = f4
i = coords(1)
end subroutine

! reduce integer
subroutine ireduce( i0out, i0, op, coords )
integer, intent(out) :: i0out
integer, intent(in) :: i0, coords(3)
character(*), intent(in) :: op
character :: a
a = op(1:1)
i0out = coords(1)
i0out = i0
end subroutine

! reduce real 1d
subroutine rreduce1( f1out, f1, op, coords )
real, intent(out) :: f1out(:)
real, intent(in) :: f1(:)
character(*), intent(in) :: op
integer, intent(in) :: coords(3)
character :: a
a = op(1:1)
f1out = coords(1)
f1out = f1
end subroutine

! reduce real 2d
subroutine rreduce2( f2out, f2, op, coords )
real, intent(out) :: f2out(:,:)
real, intent(in) :: f2(:,:)
character(*), intent(in) :: op
integer, intent(in) :: coords(3)
character :: a
a = op(1:1)
f2out = coords(1)
f2out = f2
end subroutine

! scalar swap halo
subroutine scalar_swap_halo( f3, n )
real, intent(inout) :: f3(:,:,:)
integer, intent(in) :: n(3)
return
f3(1,1,1) = f3(1,1,1) - n(1) + n(1)
end subroutine

! vector swap halo
subroutine vector_swap_halo( f4, n )
real, intent(inout) :: f4(:,:,:,:)
integer, intent(in) :: n(3)
return
f4(1,1,1,1) = f4(1,1,1,1) - n(1) + n(1)
end subroutine

! 2d real input/output
subroutine rio2( fh, f2, mode, filename, mm, nn, oo, mpio, verb )
use m_fio
integer, intent(inout) :: fh
real, intent(inout) :: f2(:,:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: mm(:), nn(:), oo(:), mpio
logical, intent(in) :: verb
integer :: i
if ( any( nn < 1 ) ) return
i = size( oo )
call frio2( fh, f2, mode, filename, mm(i), oo(i), verb )
i = mpio + nn(1)
end subroutine

! 2d integer input/output
subroutine iio2( fh, f2, mode, filename, mm, nn, oo, mpio, verb )
use m_fio
integer, intent(inout) :: fh
integer, intent(inout) :: f2(:,:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: mm(:), nn(:), oo(:), mpio
logical, intent(in) :: verb
integer :: i
if ( any( nn < 1 ) ) return
i = size( oo )
call fiio2( fh, f2, mode, filename, mm(i), oo(i), verb )
i = mpio + nn(1)
end subroutine

! 1d real input/output
subroutine rio1( fh, f1, mode, filename, m, o, mpio, verb )
use m_fio
integer, intent(inout) :: fh
real, intent(inout) :: f1(:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: m, o, mpio
logical, intent(in) :: verb
real :: f2(1,size(f1))
integer :: i
if ( mode == 'w' ) f2(1,:) = f1
call frio2( fh, f2, mode, filename, m, o, verb )
if ( mode == 'r' ) f1 = f2(1,:)
i = mpio
end subroutine

! 1d integer input/output
subroutine iio1( fh, f1, mode, filename, m, o, mpio, verb )
use m_fio
integer, intent(inout) :: fh
integer, intent(inout) :: f1(:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: m, o, mpio
logical, intent(in) :: verb
integer :: f2(1,size(f1))
integer :: i
if ( mode == 'w' ) f2(1,:) = f1
call fiio2( fh, f2, mode, filename, m, o, verb )
if ( mode == 'r' ) f1 = f2(1,:)
i = mpio
end subroutine

end module

