! Collective routines - MPI version
module m_collective
use mpi
implicit none
integer, parameter :: file_null = mpi_file_null
integer, private :: np3(3), comm1d(3), comm2d(3), comm3d
contains

! Initialize
subroutine initialize( np0, ip )
use mpi
integer, intent(out) :: np0, ip
integer :: e
call mpi_init( e )
call mpi_comm_size( mpi_comm_world, np0, e  )
call mpi_comm_rank( mpi_comm_world, ip, e  )
end subroutine

! Finalize
subroutine finalize
use mpi
integer :: e
call mpi_finalize( e )
end subroutine

! Process rank
subroutine rank( ip3, ipid, np3in )
use mpi
integer, intent(out) :: ip3(3), ipid
integer, intent(in) :: np3in(3)
integer :: ip, i, e
logical :: hat(3), period(3) = .false.
np3 = np3in
call mpi_cart_create( mpi_comm_world, 3, np3, period, .true., comm3d, e )
if ( comm3d == mpi_comm_null ) then
    call mpi_comm_rank( mpi_comm_world, ip, e  )
    write( 0, * ) ip, ' unused process'
    call mpi_finalize( e )
    stop
end if
call mpi_comm_rank( comm3d, ip, e  )
call mpi_cart_coords( comm3d, ip, 3, ip3, e )
ipid = ip3(1) + np3(1) * ( ip3(2) + np3(2) * ip3(3) )
do i = 1, 3
    hat = .false.
    hat(i) = .true.
    call mpi_cart_sub( comm3d, hat, comm1d(i), e )
    hat = .true.
    hat(i) = .false.
    call mpi_cart_sub( comm3d, hat, comm2d(i), e )
end do
end subroutine

! Find communicator and rank from Cartesian coordinates.
! Exclude dimensions with coordinate < 0.
subroutine commrank( comm, rank, coords )
use mpi
integer, intent(out) :: comm, rank
integer, intent(in) :: coords(3)
integer :: coords1(1), coords2(2), ii(1), i, n, e
n = count( coords >= 0 )
if ( n == 3 ) then
    comm = comm3d
    call mpi_cart_rank( comm, coords, rank, e )
elseif ( n == 2 ) then
    ii = minloc( coords )
    i = ii(1)
    comm = comm2d(i)
    coords2 = (/ coords(:i-1), coords(i+1:) /)
    call mpi_cart_rank( comm, coords2, rank, e )
elseif ( n == 1 ) then
    ii = maxloc( coords )
    i = ii(1)
    comm = comm1d(i)
    coords1 = coords(i:i)
    call mpi_cart_rank( comm, coords1, rank, e )
else
    write ( 0, * ) 'Problem in commrank: ', coords
    stop
end if
end subroutine

! Barrier
subroutine barrier
use mpi
integer :: e
call mpi_barrier( comm3d, e )
end subroutine

! Broadcast real 1d
subroutine rbroadcast1( r, coords )
use mpi
real, intent(inout) :: r(:)
integer, intent(in) :: coords(3)
integer :: comm, root, i, e
i = size(r)
call commrank( comm, root, coords )
call mpi_bcast( r(1), i, mpi_real, root, comm, e )
end subroutine

! Broadcast real 4d
subroutine rbroadcast4( r, coords )
use mpi
real, intent(inout) :: r(:,:,:,:)
integer, intent(in) :: coords(3)
integer :: comm, root, i, e
i = size(r)
call commrank( comm, root, coords )
call mpi_bcast( r(1,1,1,1), i, mpi_real, root, comm, e )
end subroutine

! Reduce integer
subroutine ireduce( ii, i, op, coords )
use mpi
integer, intent(out) :: ii
integer, intent(in) :: i, coords(3)
character(*), intent(in) :: op
integer :: iop, comm, root, e
select case( op )
case( 'min', 'allmin' ); iop = mpi_min
case( 'max', 'allmax' ); iop = mpi_max
case( 'sum', 'allsum' ); iop = mpi_sum
case default
stop 'Problem in ireduce'
end select
call commrank( comm, root, coords )
if ( op(1:3) == 'all' ) then
    call mpi_allreduce( i, ii, 1, mpi_integer, iop, comm, e )
else
    call mpi_reduce( i, ii, 1, mpi_integer, iop, root, comm, e )
end if
end subroutine

! Reduce real 1d
subroutine rreduce1( rr, r, op, coords )
use mpi
real, intent(out) :: rr(:)
real, intent(in) :: r(:)
integer, intent(in) :: coords(3)
character(*), intent(in) :: op
integer :: iop, comm, root, e, i
select case( op )
case( 'min', 'allmin' ); iop = mpi_min
case( 'max', 'allmax' ); iop = mpi_max
case( 'sum', 'allsum' ); iop = mpi_sum
case default
stop 'problem in rreduce1'
end select
call commrank( comm, root, coords )
i = size(r)
if ( op(1:3) == 'all' ) then
    call mpi_allreduce( r(1), rr(1), i, mpi_real, iop, comm, e )
else
    call mpi_reduce( r(1), rr(1), i, mpi_real, iop, root, comm, e )
end if
end subroutine

! Reduce real 2d
subroutine rreduce2( rr, r, op, coords )
use mpi
real, intent(out) :: rr(:,:)
real, intent(in) :: r(:,:)
integer, intent(in) :: coords(3)
character(*), intent(in) :: op
integer :: iop, comm, root, e, i
select case( op )
case( 'min', 'allmin' ); iop = mpi_min
case( 'max', 'allmax' ); iop = mpi_max
case( 'sum', 'allsum' ); iop = mpi_sum
case default
stop 'problem in rreduce2'
end select
call commrank( comm, root, coords )
i = size(r)
if ( op(1:3) == 'all' ) then
    call mpi_allreduce( r(1,1), rr(1,1), i, mpi_real, iop, comm, e )
else
    call mpi_reduce( r(1,1), rr(1,1), i, mpi_real, iop, root, comm, e )
end if
end subroutine

! Scalar swap halo
subroutine scalar_swap_halo( f, nh )
use mpi
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: nh(3)
integer :: i, e, prev, next, nm(3), n(3), isend(3), irecv(3), tsend, trecv, comm
nm = (/ size(f,1), size(f,2), size(f,3) /)
do i = 1, 3
if ( np3(i) > 1 .and. nm(i) > 1 ) then
    comm = comm3d
    call mpi_cart_shift( comm, i-1, 1, prev, next, e )
    n = nm
    n(i) = nh(i)
    isend = 0
    irecv = 0
    isend(i) = nm(i) - 2 * nh(i)
    call mpi_type_create_subarray( 3, nm, n, isend, mpi_order_fortran, mpi_real, tsend, e )
    call mpi_type_create_subarray( 3, nm, n, irecv, mpi_order_fortran, mpi_real, trecv, e )
    call mpi_type_commit( tsend, e )
    call mpi_type_commit( trecv, e )
    call mpi_sendrecv( f(1,1,1), 1, tsend, next, 0, f(1,1,1), 1, trecv, prev, 0, comm, mpi_status_ignore, e )
    call mpi_type_free( tsend, e )
    call mpi_type_free( trecv, e )
    isend(i) = nh(i)
    irecv(i) = nm(i) - nh(i)
    call mpi_type_create_subarray( 3, nm, n, isend, mpi_order_fortran, mpi_real, tsend, e )
    call mpi_type_create_subarray( 3, nm, n, irecv, mpi_order_fortran, mpi_real, trecv, e )
    call mpi_type_commit( tsend, e )
    call mpi_type_commit( trecv, e )
    call mpi_sendrecv( f(1,1,1), 1, tsend, prev, 1, f(1,1,1), 1, trecv, next, 1, comm, mpi_status_ignore, e )
    call mpi_type_free( tsend, e )
    call mpi_type_free( trecv, e )
end if
end do
end subroutine

! Vector swap halo
subroutine vector_swap_halo( f, nh )
use mpi
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: nh(3)
integer :: i, e, prev, next, nm(4), n(4), isend(4), irecv(4), tsend, trecv, comm
nm = (/ size(f,1), size(f,2), size(f,3), size(f,4) /)
do i = 1, 3
if ( np3(i) > 1 .and. nm(i) > 1 ) then
    comm = comm3d
    call mpi_cart_shift( comm, i-1, 1, prev, next, e )
    n = nm
    n(i) = nh(i)
    isend = 0
    irecv = 0
    isend(i) = nm(i) - 2 * nh(i)
    call mpi_type_create_subarray( 4, nm, n, isend, mpi_order_fortran, mpi_real, tsend, e )
    call mpi_type_create_subarray( 4, nm, n, irecv, mpi_order_fortran, mpi_real, trecv, e )
    call mpi_type_commit( tsend, e )
    call mpi_type_commit( trecv, e )
    call mpi_sendrecv( f(1,1,1,1), 1, tsend, next, 0, f(1,1,1,1), 1, trecv, prev, 0, comm, mpi_status_ignore, e )
    call mpi_type_free( tsend, e )
    call mpi_type_free( trecv, e )
    isend(i) = nh(i)
    irecv(i) = nm(i) - nh(i)
    call mpi_type_create_subarray( 4, nm, n, isend, mpi_order_fortran, mpi_real, tsend, e )
    call mpi_type_create_subarray( 4, nm, n, irecv, mpi_order_fortran, mpi_real, trecv, e )
    call mpi_type_commit( tsend, e )
    call mpi_type_commit( trecv, e )
    call mpi_sendrecv( f(1,1,1,1), 1, tsend, prev, 1, f(1,1,1,1), 1, trecv, next, 1, comm, mpi_status_ignore, e )
    call mpi_type_free( tsend, e )
    call mpi_type_free( trecv, e )
end if
end do
end subroutine

! 2D input/output
subroutine rio2( fh, f, mode, filename, mm, nn, oo, mpio, verb )
use m_frio
use mpi
integer, intent(inout) :: fh
real, intent(inout) :: f(:,:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(inout) :: mm(:), nn(:), oo(:)
integer, intent(in) :: mpio
logical, intent(in) :: verb
integer :: i, e
integer(kind=mpi_offset_kind) :: offset
i = size( oo )
if ( mpio == 0 ) then
    if ( any( nn <= 0 ) ) return
    call frio2( fh, f, mode, filename, mm(i), oo(i), verb )
    return
end if
if ( fh == mpi_file_null ) then
    call mpopen( fh, mode, filename, mm, nn, oo, verb )
    if ( any( nn <= 0 ) ) return
end if
offset = oo(i)
offset = offset * size( f, 1 )
i = size( f )
if ( mode == 'r' ) then
    if ( mpio > 0 ) then
        call mpi_file_read_at_all( fh, offset, f(1,1), i, mpi_real, mpi_status_ignore, e )
    else
        call mpi_file_read_at( fh, offset, f(1,1), i, mpi_real, mpi_status_ignore, e )
    end if
else
    if ( mpio > 0 ) then
        call mpi_file_write_at_all( fh, offset, f(1,1), i, mpi_real, mpi_status_ignore, e )
    else
        call mpi_file_write_at( fh, offset, f(1,1), i, mpi_real, mpi_status_ignore, e )
    end if
end if
i = size( oo )
if ( oo(i) + nn(i) == mm(i) ) then
    call mpi_file_close( fh, e )
    fh = mpi_file_null
end if
end subroutine

! 1D input/output
subroutine rio1( fh, f, mode, filename, m, o, mpio, verb )
integer, intent(inout) :: fh
real, intent(inout) :: f(:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: m, o, mpio
logical, intent(in) :: verb
integer :: mm(2), nn(2), oo(2)
real :: ff(1,size(f))
if ( mode == 'w' ) ff(1,:) = f
mm = (/ 1, m /)
nn = (/ 1, size(f) /)
oo = (/ 0, o /)
call rio2( fh, ff, mode, filename, mm, nn, oo, mpio, verb )
if ( mode == 'r' ) f = ff(1,:)
end subroutine

! Open file with MPIIO
! does not use mm(4) or nn(4)
subroutine mpopen( fh, mode, filename, mm, nn, oo, verb )
use mpi
integer, intent(out) :: fh
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: mm(:), nn(:), oo(:)
logical, intent(in) :: verb
integer :: mmm(size(mm)), nnn(size(nn)), ooo(size(oo)), ndims, i, n, ip, ftype, comm0, comm, e
integer(kind=mpi_offset_kind) :: offset = 0
n = size( mm )
ndims = count( mm(1:n-1) > 1 )
do i = 1, n-1
    select case( ndims )
    case( 0 ); comm0 = mpi_comm_self
    case( 1 ); if ( mm(i) /= 1 ) comm0 = comm1d(i)
    case( 2 ); if ( mm(i) == 1 ) comm0 = comm2d(i)
    case( 3 ); comm0 = comm3d
    end select
end do
if ( any( nn < 1 ) ) then
    call mpi_comm_split( comm0, mpi_undefined, 0, comm, e )
    fh = mpi_file_null
    return
end if
call mpi_comm_split( comm0, 1, 0, comm, e )
if ( mode == 'r' ) then
    i = mpi_mode_rdonly
elseif ( oo(n) == 0 ) then
    i = mpi_mode_wronly + mpi_mode_create + mpi_mode_excl
else
    i = mpi_mode_wronly
end if
call mpi_file_set_errhandler( mpi_file_null, mpi_errors_are_fatal, e )
call mpi_file_open( comm, filename, i, mpi_info_null, fh, e )
call mpi_comm_size( comm, n, e  )
call mpi_comm_rank( comm, i, e  )
call mpi_comm_rank( mpi_comm_world, ip, e  )
if ( verb .and. i == 0 ) write( 0, '(i8,a,i2,a,i8,2a)' ) &
    ip, ' Opened', ndims, 'D', n, 'P file: ', trim( filename )
ftype = mpi_real
if ( ndims > 0 ) then
    mmm = pack( mm, mm > 1, mm )
    nnn = pack( nn, mm > 1, nn )
    ooo = pack( oo, mm > 1, oo )
    call mpi_type_create_subarray( ndims, mmm, nnn, ooo, mpi_order_fortran, mpi_real, ftype, e )
    call mpi_type_commit( ftype, e )
end if
call mpi_file_set_view( fh, offset, mpi_real, ftype, 'native', mpi_info_null, e )
end subroutine

end module

