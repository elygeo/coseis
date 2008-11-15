! Collective routines - MPI version
module m_collective
use mpi
implicit none
integer :: file_null = mpi_file_null
integer, private :: np(3), root3d, root2d(3), comm3d, comm2d(3), comm1d(3)
contains

! Initialize
subroutine initialize( np0, ip, master )
use mpi
integer, intent(out) :: np0, ip
logical, intent(out) :: master
integer :: e
call mpi_init( e )
call mpi_comm_size( mpi_comm_world, np0, e  )
call mpi_comm_rank( mpi_comm_world, ip, e  )
master = .false.
if ( ip == 0 ) master = .true.
end subroutine

! Finalize
subroutine finalize
use mpi
integer :: e
call mpi_finalize( e )
end subroutine

! Process rank
subroutine rank( ip3, ipid, npin )
use mpi
integer, intent(out) :: ip3(3), ipid
integer, intent(in) :: npin(3)
integer :: ip, e
logical :: period(3) = .false.
np = npin
call mpi_cart_create( mpi_comm_world, 3, np, period, .true., comm3d, e )
if ( comm3d == mpi_comm_null ) then
  call mpi_comm_rank( mpi_comm_world, ip, e  )
  write( 0, * ) 'Unused process:', ip
  call mpi_finalize( e )
  stop
end if
call mpi_comm_rank( comm3d, ip, e  )
call mpi_cart_coords( comm3d, ip, 3, ip3, e )
ipid = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
end subroutine

! Set root process and creat 2D communicators
subroutine setroot( ip3root )
use mpi
integer, intent(in) :: ip3root(3)
integer :: ip2root(2), e, i
logical :: hat(3)
call mpi_cart_rank( comm3d, ip3root, root3d, e )
root2d = 0
comm1d = mpi_comm_self
comm2d = mpi_comm_self
do i = 1, 3
if ( product( (/ np(:i-1), np(i+1:) /) ) > 1 ) then
  hat = .false.
  hat(i) = .true.
  call mpi_cart_sub( comm3d, hat, comm1d(i), e )
  hat = .true.
  hat(i) = .false.
  call mpi_cart_sub( comm3d, hat, comm2d(i), e )
  ip2root = (/ ip3root(:i-1), ip3root(i+1:) /)
  call mpi_cart_rank( comm2d(i), ip2root, root2d(i), e )
end if
end do
end subroutine

! Broadcast real 1d
subroutine rbroadcast1( r )
use mpi
real, intent(inout) :: r(:)
integer :: i, e
i = size(r)
call mpi_bcast( r, i, mpi_real, root3d, comm3d, e )
end subroutine

! Barrier
subroutine barrier
use mpi
integer :: e
call mpi_barrier( comm3d, e )
end subroutine

! Reduce integer
subroutine ireduce( ii, i, op, i2d )
use mpi
integer, intent(out) :: ii
integer, intent(in) :: i, i2d
character(*), intent(in) :: op
integer :: iop, comm, root, e
select case( op )
case( 'min', 'allmin' ); iop = mpi_min
case( 'max', 'allmax' ); iop = mpi_max
case( 'sum', 'allsum' ); iop = mpi_sum
case default; stop
end select
comm = comm3d
root = root3d
if ( i2d /= 0 ) then
  comm = comm2d(i2d)
  root = root2d(i2d)
end if
if ( op(1:3) == 'all' ) then
  call mpi_allreduce( i, ii, 1, mpi_integer, iop, comm, e )
else
  call mpi_reduce( i, ii, 1, mpi_integer, iop, root, comm, e )
end if
end subroutine

! Reduce real
subroutine rreduce( rr, r, op, i2d )
use mpi
real, intent(out) :: rr
real, intent(in) :: r
integer, intent(in) :: i2d
character(*), intent(in) :: op
integer :: iop, comm, root, e
select case( op )
case( 'min', 'allmin' ); iop = mpi_min
case( 'max', 'allmax' ); iop = mpi_max
case( 'sum', 'allsum' ); iop = mpi_sum
case default; stop
end select
comm = comm3d
root = root3d
if ( i2d /= 0 ) then
  comm = comm2d(i2d)
  root = root2d(i2d)
end if
if ( op(1:3) == 'all' ) then
  call mpi_allreduce( r, rr, 1, mpi_real, iop, comm, e )
else
  call mpi_reduce( r, rr, 1, mpi_real, iop, root, comm, e )
end if
end subroutine

! Reduce real 1d
subroutine rreduce1( rr, r, op, i2d )
use mpi
real, intent(out) :: rr(:)
real, intent(in) :: r(:)
integer, intent(in) :: i2d
character(*), intent(in) :: op
integer :: iop, root, comm, e, i
select case( op )
case( 'min', 'allmin' ); iop = mpi_min
case( 'max', 'allmax' ); iop = mpi_max
case( 'sum', 'allsum' ); iop = mpi_sum
case default; stop
end select
comm = comm3d
root = root3d
if ( i2d /= 0 ) then
  comm = comm2d(i2d)
  root = root2d(i2d)
end if
i = size(r)
if ( op(1:3) == 'all' ) then
  call mpi_allreduce( r(1), rr(1), i, mpi_real, iop, comm, e )
else
  call mpi_reduce( r(1), rr(1), i, mpi_real, iop, root, comm, e )
end if
end subroutine

! Reduce real 2d
subroutine rreduce2( rr, r, op, i2d )
use mpi
real, intent(out) :: rr(:,:)
real, intent(in) :: r(:,:)
integer, intent(in) :: i2d
character(*), intent(in) :: op
integer :: iop, comm, root, e, i
select case( op )
case( 'min', 'allmin' ); iop = mpi_min
case( 'max', 'allmax' ); iop = mpi_max
case( 'sum', 'allsum' ); iop = mpi_sum
case default; stop
end select
comm = comm3d
root = root3d
if ( i2d /= 0 ) then
  comm = comm2d(i2d)
  root = root2d(i2d)
end if
i = size(r)
if ( op(1:3) == 'all' ) then
  call mpi_allreduce( r(1,1), rr(1,1), i, mpi_real, iop, comm, e )
else
  call mpi_reduce( r(1,1), rr(1,1), i, mpi_real, iop, root, comm, e )
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
integer :: iop, comm, root, e
select case( op )
case( 'min', 'allmin' ); ii = minloc( r ); iop = mpi_minloc
case( 'max', 'allmax' ); ii = maxloc( r ); iop = mpi_maxloc
case default; stop
end select
comm = comm3d
root = root3d
if ( i2d /= 0 ) then
  comm = comm2d(i2d)
  root = root2d(i2d)
end if
rr = r(ii(1),ii(2),ii(3))
ii = ii - 1 + noff
i = ii(1) + n(1) * ( ii(2) + n(2) * ii(3) )
local(1) = rr
local(2) = i
if ( op(1:3) == 'all' ) then
  call mpi_allreduce( local, global, 1, mpi_2double_precision, iop, comm, e )
else
  call mpi_reduce( local, global, 1, mpi_2double_precision, iop, root, comm, e )
end if
rr = global(1)
i = global(2)
nn = n
ii(3) = i / ( n(1) * n(2) )
ii(2) = modulo( i / nn(1), nn(2) )
ii(1) = modulo( i, nn(1) )
ii = ii + 1 - noff
end subroutine

! Scalar swap halo
subroutine scalar_swap_halo( f, nh )
use mpi
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: nh(3)
integer :: i, e, prev, next, nm(3), n(3), isend(3), irecv(3), tsend, trecv, comm
nm = (/ size(f,1), size(f,2), size(f,3) /)
do i = 1, 3
if ( np(i) > 1 .and. nm(i) > 1 ) then
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
if ( np(i) > 1 .and. nm(i) > 1 ) then
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
subroutine rio2( fh, f, mode, filename, mm, nn, oo, mpio )
use m_frio
use mpi
integer, intent(inout) :: fh
real, intent(inout) :: f(:,:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(inout) :: mm(:), nn(:), oo(:)
integer, intent(in) :: mpio
integer :: i, e
integer(kind=mpi_offset_kind) :: offset
i = size( oo )
if ( mpio == 0 ) then
  call frio2( fh, f, mode, filename, mm(i), oo(i) )
  return
end if
if ( fh == mpi_file_null ) then
  call mpopen( fh, mode, filename, mm, nn, oo )
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
subroutine rio1( fh, f, mode, filename, m, o, mpio )
integer, intent(inout) :: fh
real, intent(inout) :: f(:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: m, o, mpio
integer :: mm(2), nn(2), oo(2)
real :: ff(1,size(f))
if ( mode == 'w' ) ff(1,:) = f
mm = (/ 1, m /)
nn = (/ 1, size(f) /)
oo = (/ 0, o /)
call rio2( fh, ff, mode, filename, mm, nn, oo, mpio )
if ( mode == 'r' ) f = ff(1,:)
end subroutine

! Open file with MPIIO
! does not use mm(4) or nn(4)
subroutine mpopen( fh, mode, filename, mm, nn, oo )
use mpi
integer, intent(out) :: fh
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: mm(:), nn(:), oo(:)
integer :: mmm(size(mm)), nnn(size(nn)), ooo(size(oo)), ndims, i, n, ip, ftype, comm0, comm, e
integer(kind=mpi_offset_kind) :: offset = 0
n = size( mm )
ndims = count( mm(1:n-1) > 1 )
do i = 1, n-1
  select case( ndims )
  case( 0 ); comm0 = mpi_comm_self
  case( 1 ); if ( mm(i) == 1 ) comm0 = comm1d(i)
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
if ( i == 0 ) write( 0, '(i8,a,i2,a,i8,2a)' ) &
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

