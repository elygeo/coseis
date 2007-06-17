! Collective routines - MPI version
module m_collective
implicit none
integer, private :: ip, ipmaster, comm3d, comm2d(3)
integer, private, allocatable :: commout(:)
contains

! Initialize
subroutine initialize( ipout, np0, master )
use mpi
integer, intent(out) :: ipout, np0
logical, intent(out) :: master
integer :: e
call mpi_init( e )
call mpi_comm_rank( mpi_comm_world, ip, e  )
call mpi_comm_size( mpi_comm_world, np0, e  )
ipout = ip
master = .false.
if ( ip == 0 ) master = .true.
end subroutine

! Finalize
subroutine finalize
use mpi
integer :: e
call mpi_finalize( e )
end subroutine

! Processor rank
subroutine rank( ipout, ip3, np )
use mpi
integer, intent(out) :: ipout, ip3(3)
integer, intent(in) :: np(3)
integer :: i, e
logical :: period(3) = .false.
call mpi_cart_create( mpi_comm_world, 3, np, period, .true., comm3d, e )
if ( comm3d == mpi_comm_null ) then
  write( 0, * ) 'Unused process:', ip
  call mpi_finalize( e )
  stop
end if
call mpi_comm_rank( comm3d, ip, e  )
call mpi_cart_coords( comm3d, ip, 3, ip3, e )
ipout = ip
do i = 1, 3
  call mpi_comm_split( comm3d, ip3(i), 0, comm2d(i), e )
end do
end subroutine

! Set master processor
subroutine setmaster( ip3master )
use mpi
integer, intent(in) :: ip3master(3)
integer :: e
call mpi_cart_rank( comm3d, ip3master, ipmaster, e )
end subroutine

! Broadcast real 1d
subroutine rbroadcast1( r )
use mpi
real, intent(inout) :: r(:)
integer :: i, e
i = size(r)
call mpi_bcast( r, i, mpi_real, ipmaster, comm3d, e )
end subroutine

! Reduce integer
subroutine ireduce( ii, i, op, i2d )
use mpi
integer, intent(out) :: ii
integer, intent(in) :: i, i2d
character(*), intent(in) :: op
integer :: iop, e, comm
select case( op )
case( 'min', 'allmin' ); iop = mpi_min
case( 'max', 'allmax' ); iop = mpi_max
case( 'sum', 'allsum' ); iop = mpi_sum
case default; stop
end select
if ( op(1:3) == 'all' ) then
  comm = comm3d
  if ( i2d /= 0 ) comm = comm2d(i2d)
  call mpi_allreduce( i, ii, 1, mpi_integer, iop, comm, e )
else
  if ( i2d /= 0 ) stop 'must allreduce for comm2d'
  call mpi_reduce( i, ii, 1, mpi_integer, iop, ipmaster, comm3d, e )
end if
end subroutine

! Reduce real
subroutine rreduce( rr, r, op, i2d )
use mpi
real, intent(out) :: rr
real, intent(in) :: r
integer, intent(in) :: i2d
character(*), intent(in) :: op
integer :: iop, e, comm
select case( op )
case( 'min', 'allmin' ); iop = mpi_min
case( 'max', 'allmax' ); iop = mpi_max
case( 'sum', 'allsum' ); iop = mpi_sum
case default; stop
end select
if ( op(1:3) == 'all' ) then
  comm = comm3d
  if ( i2d /= 0 ) comm = comm2d(i2d)
  call mpi_allreduce( r, rr, 1, mpi_real, iop, comm, e )
else
  if ( i2d /= 0 ) stop 'must allreduce for comm2d'
  call mpi_reduce( r, rr, 1, mpi_real, iop, ipmaster, comm3d, e )
end if
end subroutine

! Reduce real 1d
subroutine rreduce1( rr, r, op, i2d )
use mpi
real, intent(out) :: rr(:)
real, intent(in) :: r(:)
integer, intent(in) :: i2d
character(*), intent(in) :: op
integer :: iop, i, e, comm
select case( op )
case( 'min', 'allmin' ); iop = mpi_min
case( 'max', 'allmax' ); iop = mpi_max
case( 'sum', 'allsum' ); iop = mpi_sum
case default; stop
end select
i = size(r)
if ( op(1:3) == 'all' ) then
  comm = comm3d
  if ( i2d /= 0 ) comm = comm2d(i2d)
  call mpi_allreduce( r(1), rr(1), i, mpi_real, iop, comm, e )
else
  if ( i2d /= 0 ) stop 'must allreduce for comm2d'
  call mpi_reduce( r(1), rr(1), i, mpi_real, iop, ipmaster, comm3d, e )
end if
end subroutine

! Reduce real 2d
subroutine rreduce2( rr, r, op, i2d )
use mpi
real, intent(out) :: rr(:,:)
real, intent(in) :: r(:,:)
integer, intent(in) :: i2d
character(*), intent(in) :: op
integer :: iop, i, e, comm
select case( op )
case( 'min', 'allmin' ); iop = mpi_min
case( 'max', 'allmax' ); iop = mpi_max
case( 'sum', 'allsum' ); iop = mpi_sum
case default; stop
end select
i = size(r)
if ( op(1:3) == 'all' ) then
  comm = comm3d
  if ( i2d /= 0 ) comm = comm2d(i2d)
  call mpi_allreduce( r(1,1), rr(1,1), i, mpi_real, iop, comm, e )
else
  if ( i2d /= 0 ) stop 'must allreduce for comm2d'
  call mpi_reduce( r(1,1), rr(1,1), i, mpi_real, iop, ipmaster, comm3d, e )
end if
end subroutine

! Reduce extrema location, real 3d
subroutine reduceloc( rr, ii, r, op, n, noff, i2d )
use mpi
double precision :: local(2), global(2)
real, intent(out) :: rr
real, intent(in) :: r(:,:,:)
integer, intent(out) :: ii(3)
integer, intent(in) :: n(3), noff(3), i2d
character(*), intent(in) :: op
integer(8) :: nn(3), i
integer :: iop, comm, e
select case( op )
case( 'min', 'allmin' ); ii = minloc( r ); iop = mpi_minloc
case( 'max', 'allmax' ); ii = maxloc( r ); iop = mpi_maxloc
case default; stop
end select
rr = r(ii(1),ii(2),ii(3))
ii = ii - 1 + noff
i = ii(1) + n(1) * ( ii(2) + n(2) * ii(3) )
local(1) = rr
local(2) = i
if ( op(1:3) == 'all' ) then
  comm = comm3d
  if ( i2d /= 0 ) comm = comm2d(i2d)
  call mpi_allreduce( local, global, 1, mpi_2double_precision, iop, comm, e )
else
  if ( i2d /= 0 ) stop 'must allreduce for comm2d'
  call mpi_reduce( local, global, 1, mpi_2double_precision, iop, ipmaster, comm3d, e )
end if
rr = global(1)
i = global(2)
nn = n
ii(3) = i / ( n(1) * n(2) )
ii(2) = modulo( i / nn(1), nn(2) )
ii(1) = modulo( i, nn(1) )
ii = ii + 1 - noff
end subroutine

! Vector send
subroutine vectorsend( f, i1, i2, i )
use mpi
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
integer :: nm(4), nl(4), i0(4), prev, next, dtype, e
nm = (/ size(f,1), size(f,2), size(f,3), size(f,4) /)
nl = (/ i2 - i1 + 1, nm(4) /)
i0 = (/ i1 - 1, 0 /)
call mpi_cart_shift( comm3d, abs(i)-1, sign(1,i), prev, next, e )
call mpi_type_create_subarray( 4, nm, nl, i0, mpi_order_fortran, mpi_real, dtype, e )
call mpi_type_commit( dtype, e )
call mpi_send( f(1,1,1,1), 1, dtype, next, 0, comm3d, e )
do e = 1,1; end do ! bug work-around, need slight delay here for MPICH2
call mpi_type_free( dtype, e )
end subroutine

! Vector receive
subroutine vectorrecv( f, i1, i2, i )
use mpi
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
integer :: nm(4), nl(4), i0(4), prev, next, dtype, e
nm = (/ size(f,1), size(f,2), size(f,3), size(f,4) /)
nl = (/ i2 - i1 + 1, nm(4) /)
i0 = (/ i1 - 1, 0 /)
call mpi_cart_shift( comm3d, abs(i)-1, sign(1,i), prev, next, e )
call mpi_type_create_subarray( 4, nm, nl, i0, mpi_order_fortran, mpi_real, dtype, e )
call mpi_type_commit( dtype, e )
call mpi_recv( f(1,1,1,1), 1, dtype, next, 0, comm3d, mpi_status_ignore, e )
call mpi_type_free( dtype, e )
end subroutine

! Scalar swap halo
subroutine scalarswaphalo( f, nhalo )
use mpi
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: nhalo
integer :: i, e, prev, next, nm(3), n(3), isend(3), irecv(3), tsend, trecv
nm = (/ size(f,1), size(f,2), size(f,3) /)
do i = 1, 3
if ( nm(i) > 1 ) then
  call mpi_cart_shift( comm3d, i-1, 1, prev, next, e )
  n = nm
  n(i) = nhalo
  isend = 0
  irecv = 0
  isend(i) = nm(i) - 2 * nhalo
  call mpi_type_create_subarray( 3, nm, n, isend, mpi_order_fortran, mpi_real, tsend, e )
  call mpi_type_create_subarray( 3, nm, n, irecv, mpi_order_fortran, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_sendrecv( f(1,1,1), 1, tsend, next, 0, f(1,1,1), 1, trecv, prev, 0, comm3d, mpi_status_ignore, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
  isend(i) = nhalo
  irecv(i) = nm(i) - nhalo
  call mpi_type_create_subarray( 3, nm, n, isend, mpi_order_fortran, mpi_real, tsend, e )
  call mpi_type_create_subarray( 3, nm, n, irecv, mpi_order_fortran, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_sendrecv( f(1,1,1), 1, tsend, prev, 1, f(1,1,1), 1, trecv, next, 1, comm3d, mpi_status_ignore, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
end if
end do
end subroutine

! Vector swap halo
subroutine vectorswaphalo( f, nhalo )
use mpi
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: nhalo
integer :: i, e, prev, next, nm(4), n(4), isend(4), irecv(4), tsend, trecv
nm = (/ size(f,1), size(f,2), size(f,3), size(f,4) /)
do i = 1, 3
if ( nm(i) > 1 ) then
  call mpi_cart_shift( comm3d, i-1, 1, prev, next, e )
  n = nm
  n(i) = nhalo
  isend = 0
  irecv = 0
  isend(i) = nm(i) - 2 * nhalo
  call mpi_type_create_subarray( 4, nm, n, isend, mpi_order_fortran, mpi_real, tsend, e )
  call mpi_type_create_subarray( 4, nm, n, irecv, mpi_order_fortran, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_sendrecv( f(1,1,1,1), 1, tsend, next, 0, f(1,1,1,1), 1, trecv, prev, 0, comm3d, mpi_status_ignore, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
  isend(i) = nhalo
  irecv(i) = nm(i) - nhalo
  call mpi_type_create_subarray( 4, nm, n, isend, mpi_order_fortran, mpi_real, tsend, e )
  call mpi_type_create_subarray( 4, nm, n, irecv, mpi_order_fortran, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_sendrecv( f(1,1,1,1), 1, tsend, prev, 1, f(1,1,1,1), 1, trecv, next, 1, comm3d, mpi_status_ignore, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
end if
end do
end subroutine

! Split communicator
subroutine splitio( iz, n, color )
use mpi
integer, intent(in) :: iz, n, color
integer :: i, e
if ( .not. allocated( commout ) ) allocate( commout(n) )
i = color
if ( i < 0 ) i = mpi_undefined
call mpi_comm_split( comm3d, i, 0, commout(iz), e )
end subroutine

! Scalar field input/output
subroutine scalario( io, str, r, s1, i1, i2, i3, i4, ir, mpio )
use m_util
use mpi
real, intent(inout) :: r, s1(:,:,:)
integer, intent(in) :: i1(3), i2(3), i3(3), i4(3), ir, mpio
character(*), intent(in) :: io, str
integer :: i, ndims, ftype, mtype, fh, nl(3), n(3), i0(3), comm, e
integer(kind=mpi_offset_kind) :: dr
if ( all( i1 == i2 ) .and. io == 'w' ) then
  r = s1(i1(1),i1(2),i1(3))
  return
end if
if ( mpio == 0 ) then
  call rio3( io, str, s1, i3, i4, ir )
  return
end if
call mpi_file_set_errhandler( mpi_file_null, MPI_ERRORS_ARE_FATAL, e )
i0 = i3 - i1           ! offsets
n  = i2 - i1 + 1       ! global size
nl = i4 - i3 + 1       ! local size
inquire( iolength=i ) r
dr = i * (ir-1) * n(1) * n(2) * n(3)
ndims = 3
do i = ndims, 1, -1    ! squeeze singleton dimentions
if ( n(i) == 1 ) then
  ndims = ndims - 1
  i0(i:) = (/ i0(i+1:), 0 /)
  n(i:)  = (/ n(i+1:),  1 /)
  nl(i:) = (/ nl(i+1:), 1 /)
end if
end do
if ( mpio < 0 ) then   ! collapes dimension if all on one proc
  do i = 1, ndims-1
  if ( n(i) == nl(i) ) then
    ndims = ndims - 1
    i0(i:) = (/ i0(i)+n(i)*i0(i+1), i0(i+2:), 0 /)
    n(i:)  = (/ n(i)*n(i+1),        n(i+2:),  1 /)
    nl(i:) = (/ nl(i)*nl(i+1),      nl(i+2:), 1 /)
    exit               ! only do this once to prevent 32 bit overrun
  end if
  end do
end if
if ( ndims < 1 ) ndims = 1
call mpi_type_create_subarray( ndims, n, nl, i0, mpi_order_fortran, mpi_real, ftype, e )
call mpi_type_commit( ftype, e )
i0 = i3 - 1
n  = (/ size(s1,1), size(s1,2), size(s1,3) /)
nl = i4 - i3 + 1
call mpi_type_create_subarray( 3, n, nl, i0, mpi_order_fortran, mpi_real, mtype, e )
call mpi_type_commit( mtype, e )
i = abs( mpio )
select case( io )
case( 'r' )
  comm = comm3d
  if ( i <= 3 ) comm = comm2d(i)
  call mpi_file_open( comm, str, mpi_mode_rdonly, mpi_info_null, fh, e )
  call mpi_file_set_view( fh, dr, mpi_real, ftype, 'native', mpi_info_null, e )
  call mpi_file_read_all( fh, s1(1,1,1), 1, mtype, mpi_status_ignore, e )
case( 'w' )
  comm = commout(i)
  i = 0
  if ( ir == 1 ) i = mpi_mode_create
  call mpi_file_open( comm, str, mpi_mode_wronly + i, mpi_info_null, fh, e )
  call mpi_file_set_view( fh, dr, mpi_real, ftype, 'native', mpi_info_null, e )
  call mpi_file_write_all( fh, s1(1,1,1), 1, mtype, mpi_status_ignore, e )
end select
call mpi_file_close( fh, e )
call mpi_type_free( mtype, e )
call mpi_type_free( ftype, e )
end subroutine

! Vector field component input/output
subroutine vectorio( io, str, r, w1, i1, i2, i3, i4, ic, ir, mpio )
use m_util
use mpi
real, intent(inout) :: r, w1(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i3(3), i4(3), ic, ir, mpio
character(*), intent(in) :: io, str
integer :: i, ndims, ftype, mtype, fh, nl(3), n(3), i0(3), comm, e
integer(kind=mpi_offset_kind) :: dr
if ( all( i1 == i2 ) .and. io =='w' ) then
  r = w1(i1(1),i1(2),i1(3),ic)
  return
end if
if ( mpio == 0 ) then
  call rio4( io, str, w1, i3, i4, ic, ir )
  return
end if
call mpi_file_set_errhandler( mpi_file_null, MPI_ERRORS_ARE_FATAL, e )
i0 = i3 - i1           ! offsets
n  = i2 - i1 + 1       ! global size
nl = i4 - i3 + 1       ! local size
inquire( iolength=i ) r
dr = i * (ir-1) * n(1) * n(2) * n(3)
ndims = 3
do i = ndims, 1, -1    ! squeeze singleton dimentions
if ( n(i) == 1 ) then
  ndims = ndims - 1
  i0(i:) = (/ i0(i+1:), 0 /)
  n(i:)  = (/ n(i+1:),  1 /)
  nl(i:) = (/ nl(i+1:), 1 /)
end if
end do
if ( mpio < 0 ) then   ! collapes dimension if all on one proc
  do i = 1, ndims-1
  if ( n(i) == nl(i) ) then
    ndims = ndims - 1
    i0(i:) = (/ i0(i)+n(i)*i0(i+1), i0(i+2:), 0 /)
    n(i:)  = (/ n(i)*n(i+1),        n(i+2:),  1 /)
    nl(i:) = (/ nl(i)*nl(i+1),      nl(i+2:), 1 /)
    exit               ! only do this once to prevent 32 bit overrun
  end if
  end do
end if
if ( ndims < 1 ) ndims = 1
call mpi_type_create_subarray( ndims, n, nl, i0, mpi_order_fortran, mpi_real, ftype, e )
call mpi_type_commit( ftype, e )
i0 = i3 - 1
n  = (/ size(w1,1), size(w1,2), size(w1,3) /)
nl = i4 - i3 + 1
call mpi_type_create_subarray( 3, n, nl, i0, mpi_order_fortran, mpi_real, mtype, e )
call mpi_type_commit( mtype, e )
i = abs( mpio )
select case( io )
case( 'r' )
  comm = comm3d
  if ( i <= 3 ) comm = comm2d(i)
  call mpi_file_open( comm, str, mpi_mode_rdonly, mpi_info_null, fh, e )
  call mpi_file_set_view( fh, dr, mpi_real, ftype, 'native', mpi_info_null, e )
  call mpi_file_read_all( fh, w1(1,1,1,ic), 1, mtype, mpi_status_ignore, e )
case( 'w' )
  comm = commout(i)
  i = 0
  if ( ir == 1 ) i = mpi_mode_create
  call mpi_file_open( comm, str, mpi_mode_wronly + i, mpi_info_null, fh, e )
  call mpi_file_set_view( fh, dr, mpi_real, ftype, 'native', mpi_info_null, e )
  call mpi_file_write_all( fh, w1(1,1,1,ic), 1, mtype, mpi_status_ignore, e )
end select
call mpi_file_close( fh, e )
call mpi_type_free( mtype, e )
call mpi_type_free( ftype, e )
end subroutine

end module

