! collective routines - MPI version
module m_collective
use mpi
implicit none
integer, parameter :: file_null = mpi_file_null
integer, private :: np3(3), comm1d(3), comm2d(3), comm3d, commw2f, rtype, itype, wfiletype
contains

! initialize
subroutine initialize( np0, ip )
use mpi
integer, intent(out) :: np0, ip
integer :: i, nr, ni, e
real :: r
call mpi_init( e )
call mpi_comm_size( mpi_comm_world, np0, e  )
call mpi_comm_rank( mpi_comm_world, ip, e  )
call mpi_sizeof( r, nr, e )
call mpi_sizeof( i, ni, e )
call mpi_type_match_size( mpi_typeclass_real, nr, rtype, e )
call mpi_type_match_size( mpi_typeclass_integer, ni, itype, e )
end subroutine

! finalize
subroutine finalize
use mpi
integer :: e
call mpi_finalize( e )
end subroutine

! process rank
subroutine rank( ip3, ipid, nproc3 )
use mpi
integer, intent(out) :: ip3(3), ipid
integer, intent(in) :: nproc3(3)
integer :: ip, i, e
logical :: hat(3), period(3) = .false.
np3 = nproc3
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

! find communicator and rank from Cartesian coordinates.
! exclude dimensions with coordinate < 0.
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

! barrier
subroutine barrier
use mpi
integer :: e
call mpi_barrier( comm3d, e )
end subroutine

! broadcast real 1d
subroutine rbroadcast1( f1, coords )
use mpi
real, intent(inout) :: f1(:)
integer, intent(in) :: coords(3)
integer :: comm, root, i, e
i = size(f1)
call commrank( comm, root, coords )
call mpi_bcast( f1(1), i, rtype, root, comm, e )
end subroutine

! broadcast real 4d
subroutine rbroadcast4( f4, coords )
use mpi
real, intent(inout) :: f4(:,:,:,:)
integer, intent(in) :: coords(3)
integer :: comm, root, i, e
i = size(f4)
call commrank( comm, root, coords )
call mpi_bcast( f4(1,1,1,1), i, rtype, root, comm, e )
end subroutine

! reduce integer
subroutine ireduce( i0out, i0, op, coords )
use mpi
integer, intent(out) :: i0out
integer, intent(in) :: i0, coords(3)
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
    call mpi_allreduce( i0, i0out, 1, itype, iop, comm, e )
else
    call mpi_reduce( i0, i0out, 1, itype, iop, root, comm, e )
end if
end subroutine

! reduce real 1d
subroutine rreduce1( f1out, f1, op, coords )
use mpi
real, intent(out) :: f1out(:)
real, intent(in) :: f1(:)
character(*), intent(in) :: op
integer, intent(in) :: coords(3)
integer :: iop, comm, root, e, i
select case( op )
case( 'min', 'allmin' ); iop = mpi_min
case( 'max', 'allmax' ); iop = mpi_max
case( 'sum', 'allsum' ); iop = mpi_sum
case default
stop 'problem in rreduce1'
end select
call commrank( comm, root, coords )
i = size(f1)
if ( op(1:3) == 'all' ) then
    call mpi_allreduce( f1(1), f1out(1), i, rtype, iop, comm, e )
else
    call mpi_reduce( f1(1), f1out(1), i, rtype, iop, root, comm, e )
end if
end subroutine

! reduce real 2d
subroutine rreduce2( f2out, f2, op, coords )
use mpi
real, intent(out) :: f2out(:,:)
real, intent(in) :: f2(:,:)
character(*), intent(in) :: op
integer, intent(in) :: coords(3)
integer :: iop, comm, root, e, i
select case( op )
case( 'min', 'allmin' ); iop = mpi_min
case( 'max', 'allmax' ); iop = mpi_max
case( 'sum', 'allsum' ); iop = mpi_sum
case default
stop 'problem in rreduce2'
end select
call commrank( comm, root, coords )
i = size(f2)
if ( op(1:3) == 'all' ) then
    call mpi_allreduce( f2(1,1), f2out(1,1), i, rtype, iop, comm, e )
else
    call mpi_reduce( f2(1,1), f2out(1,1), i, rtype, iop, root, comm, e )
end if
end subroutine

! scalar swap halo
subroutine scalar_swap_halo( f3, nh )
use mpi
real, intent(inout) :: f3(:,:,:)
integer, intent(in) :: nh(3)
integer :: i, e, prev, next, nm(3), n(3), isend(3), irecv(3), tsend, trecv, comm
nm = (/ size(f3,1), size(f3,2), size(f3,3) /)
do i = 1, 3
if ( np3(i) > 1 .and. nm(i) > 1 ) then
    comm = comm3d
    call mpi_cart_shift( comm, i-1, 1, prev, next, e )
    n = nm
    n(i) = nh(i)
    isend = 0
    irecv = 0
    isend(i) = nm(i) - 2 * nh(i)
    call mpi_type_create_subarray( 3, nm, n, isend, mpi_order_fortran, rtype, tsend, e )
    call mpi_type_create_subarray( 3, nm, n, irecv, mpi_order_fortran, rtype, trecv, e )
    call mpi_type_commit( tsend, e )
    call mpi_type_commit( trecv, e )
    call mpi_sendrecv( f3(1,1,1), 1, tsend, next, 0, f3(1,1,1), 1, trecv, prev, 0, comm, mpi_status_ignore, e )
    call mpi_type_free( tsend, e )
    call mpi_type_free( trecv, e )
    isend(i) = nh(i)
    irecv(i) = nm(i) - nh(i)
    call mpi_type_create_subarray( 3, nm, n, isend, mpi_order_fortran, rtype, tsend, e )
    call mpi_type_create_subarray( 3, nm, n, irecv, mpi_order_fortran, rtype, trecv, e )
    call mpi_type_commit( tsend, e )
    call mpi_type_commit( trecv, e )
    call mpi_sendrecv( f3(1,1,1), 1, tsend, prev, 1, f3(1,1,1), 1, trecv, next, 1, comm, mpi_status_ignore, e )
    call mpi_type_free( tsend, e )
    call mpi_type_free( trecv, e )
end if
end do
end subroutine

! vector swap halo
subroutine vector_swap_halo( f4, nh )
use mpi
real, intent(inout) :: f4(:,:,:,:)
integer, intent(in) :: nh(3)
integer :: i, e, prev, next, nm(4), n(4), isend(4), irecv(4), tsend, trecv, comm
nm = (/ size(f4,1), size(f4,2), size(f4,3), size(f4,4) /)
do i = 1, 3
if ( np3(i) > 1 .and. nm(i) > 1 ) then
    comm = comm3d
    call mpi_cart_shift( comm, i-1, 1, prev, next, e )
    n = nm
    n(i) = nh(i)
    isend = 0
    irecv = 0
    isend(i) = nm(i) - 2 * nh(i)
    call mpi_type_create_subarray( 4, nm, n, isend, mpi_order_fortran, rtype, tsend, e )
    call mpi_type_create_subarray( 4, nm, n, irecv, mpi_order_fortran, rtype, trecv, e )
    call mpi_type_commit( tsend, e )
    call mpi_type_commit( trecv, e )
    call mpi_sendrecv( f4(1,1,1,1), 1, tsend, next, 0, f4(1,1,1,1), 1, trecv, prev, 0, comm, mpi_status_ignore, e )
    call mpi_type_free( tsend, e )
    call mpi_type_free( trecv, e )
    isend(i) = nh(i)
    irecv(i) = nm(i) - nh(i)
    call mpi_type_create_subarray( 4, nm, n, isend, mpi_order_fortran, rtype, tsend, e )
    call mpi_type_create_subarray( 4, nm, n, irecv, mpi_order_fortran, rtype, trecv, e )
    call mpi_type_commit( tsend, e )
    call mpi_type_commit( trecv, e )
    call mpi_sendrecv( f4(1,1,1,1), 1, tsend, prev, 1, f4(1,1,1,1), 1, trecv, next, 1, comm, mpi_status_ignore, e )
    call mpi_type_free( tsend, e )
    call mpi_type_free( trecv, e )
end if
end do
end subroutine

subroutine set_write_range( point, shape_w, xxx, yyy, zzz, nwx, nwy, nwz, w_flag )
use m_globals
use mpi
integer, intent(in) :: point(3), shape_w(3)
integer, intent(in) :: xxx(3), yyy(3), zzz(3)
integer, intent(out) :: nwx(3), nwy(3), nwz(3)
integer, intent(out) :: w_flag
integer :: i,j,k,npts

if(point(1)>xxx(1)) then
    nwx(1) = point(1)
else
    nwx(1) = xxx(1)
end if

! caculate x range:
npts = int((nwx(1)-xxx(1))/xxx(3))*xxx(3) + xxx(1)
if (nwx(1) > npts) nwx(1) = npts + xxx(3)

if(point(1)+shape_w(1)-1<xxx(2)) then
    nwx(2) = point(1)+shape_w(1) - 1
else
    nwx(2) = xxx(2)
end if

npts = int((nwx(2)-xxx(1))/xxx(3))*xxx(3) + xxx(1)
if (nwx(2) > npts) nwx(2) = npts 

if ( nwx(2)<nwx(1) ) then
  w_flag = 0
  return
end if

nwx(3) = xxx(3)

! caculate y range:
if(point(2)>yyy(1)) then
    nwy(1) = point(2)
else
    nwy(1) = yyy(1)
end if

npts = int((nwy(1)-yyy(1))/yyy(3))*yyy(3) + yyy(1)
if (nwy(1) > npts) nwy(1) = npts + yyy(3) 

if(point(2)+shape_w(2)-1<yyy(2)) then
    nwy(2) = point(2) + shape_w(2) - 1
else
    nwy(2) = yyy(2)
end if

npts = int((nwy(2)-yyy(1))/yyy(3))*yyy(3) + yyy(1)
if (nwy(2) > npts) nwy(2) = npts - yyy(3) 

nwy(3) = yyy(3)

if ( nwy(2)<nwy(1) ) then
  w_flag = 0
  return
end if

! caculate z range:
if(point(3)>zzz(1)) then
    nwz(1) = point(3)
else
    nwz(1) = zzz(1)
end if

npts = int((nwz(1)-zzz(1))/zzz(3))*zzz(3) + zzz(1)
if (nwz(1) > npts) nwz(1) = npts + zzz(3) 

if(point(3)+shape_w(3)-1<zzz(2)) then
    nwz(2) = point(3) + shape_w(3) - 1
else
    nwz(2) = zzz(2)
end if

npts = int((nwz(2)-zzz(1))/zzz(3))*zzz(3) + zzz(1)
if (nwz(2) < npts) nwz(2) = npts - zzz(3) 

if ( nwz(2)<nwz(1) ) then
  w_flag = 0
  return
end if

nwz(3) = zzz(3)

w_flag = 1
end subroutine

subroutine set_write_filetype( prec, xxx, yyy, zzz, nwx, nwy, nwz, wstep, ip )
use m_globals
use mpi
integer, intent(inout) :: prec(:,:)
integer, intent(in) :: xxx(3), yyy(3), zzz(3)
integer, intent(in) :: nwx(3), nwy(3), nwz(3)
integer, intent(in) :: wstep, ip
integer :: i,j,k,npts,nr,e
integer*8 :: r, Li, Lj, Lk, nrec
integer :: l, nprec
integer(kind=MPI_ADDRESS_KIND), dimension (:), allocatable :: tpmap, pmap
integer,dimension(:), allocatable :: block
real :: r_f

l = 1
r = -1

Li = int((xxx(2)-xxx(1))/xxx(3)) + 1
Lj = int((yyy(2)-yyy(1))/yyy(3)) + 1
Lk = int((zzz(2)-zzz(1))/zzz(3)) + 1

npts = (int((nwx(2)-nwx(1))/nwx(3)) + 1)*(int((nwy(2)-nwy(1))/nwy(3)) + 1)*(int((nwz(2)-nwz(1))/nwz(3)) + 1)
nrec = Li*Lj*Lk
 
allocate(pmap(npts))
pmap = 0
do k=nwz(1),nwz(2),nwz(3)
   do j=nwy(1),nwy(2),nwy(3)
      do i=nwx(1),nwx(2),nwx(3)
         prec(l,1) = i
         prec(l,2) = j
         prec(l,3) = k 
         r = Li*Lj*int((k-zzz(1))/zzz(3)) + Li*int((j-yyy(1))/yyy(3)) + int((i-xxx(1))/xxx(3))
         pmap(l) = r
         l = l+1  
      enddo
   enddo
enddo   

allocate(tpmap(npts*wstep))
tpmap = 0
do i = 1, wstep
   do j = 1, npts
      tpmap((i-1)*npts+j) = pmap(j)+int((i-1)*nrec,MPI_ADDRESS_KIND)
   end do
end do
deallocate(pmap)
allocate(block(npts*wstep))
block = 1

call mpi_sizeof( r_f, nr, e )
tpmap=tpmap*nr 

call MPI_TYPE_CREATE_HINDEXED(npts*wstep, block, tpmap, rtype, wfiletype,e)
call MPI_TYPE_COMMIT(wfiletype,e)

deallocate(tpmap)
deallocate(block)
   
end subroutine

! 2d real input/output
subroutine rio2( fh, f2, mode, filename, mm, nn, oo, mpio, verb )

use m_fio
use mpi
integer, intent(inout) :: fh
real, intent(inout) :: f2(:,:)
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
    call frio2( fh, f2, mode, filename, mm(i), oo(i), verb )
    return
end if
if ( fh == mpi_file_null ) then
    call mpopen( fh, mode, filename, mm, nn, oo, verb )
    if ( any( nn <= 0 ) ) return
end if
offset = oo(i)
offset = offset * size( f2, 1 )
i = size( f2 )
if ( mode == 'r' ) then
    if ( mpio > 0 ) then
        call mpi_file_read_at_all( fh, offset, f2(1,1), i, rtype, mpi_status_ignore, e )
    else
        call mpi_file_read_at( fh, offset, f2(1,1), i, rtype, mpi_status_ignore, e )
    end if
else
    if ( mpio > 0 ) then
        call mpi_file_write_at_all( fh, offset, f2(1,1), i, rtype, mpi_status_ignore, e )
    else
        call mpi_file_write_at( fh, offset, f2(1,1), i, rtype, mpi_status_ignore, e )
    end if
end if
i = size( oo )
if ( oo(i) + nn(i) == mm(i) ) then
    call mpi_file_close( fh, e )
    fh = mpi_file_null
end if
end subroutine

! 2d integer input/output
subroutine iio2( fh, f2, mode, filename, mm, nn, oo, mpio, verb )
use m_fio
use mpi
integer, intent(inout) :: fh
integer, intent(inout) :: f2(:,:)
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
    call fiio2( fh, f2, mode, filename, mm(i), oo(i), verb )
    return
end if
if ( fh == mpi_file_null ) then
    call mpopen( fh, mode, filename, mm, nn, oo, verb )
    if ( any( nn <= 0 ) ) return
end if
offset = oo(i)
offset = offset * size( f2, 1 )
i = size( f2 )
if ( mode == 'r' ) then
    if ( mpio > 0 ) then
        call mpi_file_read_at_all( fh, offset, f2(1,1), i, itype, mpi_status_ignore, e )
    else
        call mpi_file_read_at( fh, offset, f2(1,1), i, itype, mpi_status_ignore, e )
    end if
else
    if ( mpio > 0 ) then
        call mpi_file_write_at_all( fh, offset, f2(1,1), i, itype, mpi_status_ignore, e )
    else
        call mpi_file_write_at( fh, offset, f2(1,1), i, itype, mpi_status_ignore, e )
    end if
end if
i = size( oo )
if ( oo(i) + nn(i) == mm(i) ) then
    call mpi_file_close( fh, e )
    fh = mpi_file_null
end if
end subroutine

! 1d real input/output
subroutine rio1( fh, f1, mode, filename, m, o, mpio, verb )
integer, intent(inout) :: fh
real, intent(inout) :: f1(:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: m, o, mpio
logical, intent(in) :: verb
integer :: mm(2), nn(2), oo(2)
real :: f2(1,size(f1))
if ( mode == 'w' ) f2(1,:) = f1
mm = (/ 1, m /)
nn = (/ 1, size(f1) /)
oo = (/ 0, o /)
call rio2( fh, f2, mode, filename, mm, nn, oo, mpio, verb )
if ( mode == 'r' ) f1 = f2(1,:)
end subroutine

! 1d real input/output
subroutine iio1( fh, f1, mode, filename, m, o, mpio, verb )
integer, intent(inout) :: fh
integer, intent(inout) :: f1(:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: m, o, mpio
logical, intent(in) :: verb
integer :: mm(2), nn(2), oo(2)
integer :: f2(1,size(f1))
if ( mode == 'w' ) f2(1,:) = f1
mm = (/ 1, m /)
nn = (/ 1, size(f1) /)
oo = (/ 0, o /)
call iio2( fh, f2, mode, filename, mm, nn, oo, mpio, verb )
if ( mode == 'r' ) f1 = f2(1,:)
end subroutine

subroutine set_write_comm( write_flag )
use mpi
integer, intent(in) :: write_flag
integer :: e
call mpi_comm_split( comm3d, write_flag, 0, commw2f, e )
end subroutine

subroutine write_to_file( fh, buf, npts, wstep )
use mpi
integer, intent(inout) :: fh
integer, intent(in)  :: npts, wstep
real, intent(in)  :: buf(:)
integer(kind=mpi_offset_kind) :: offset
integer :: e
offset = 0
call mpi_file_write_at_all( fh, offset, buf(1), npts*wstep, rtype, mpi_status_ignore, e )
end subroutine

subroutine open_write_file( fh, mode, filename )
use mpi
integer, intent(out) :: fh
integer, intent(in)  :: mode
character(*), intent(in) :: filename
integer :: i, e
integer(kind=mpi_offset_kind) :: offset = 0

if (mode == 1) then
    offset = 0
    i = mpi_mode_wronly + mpi_mode_create + mpi_mode_excl
    call mpi_file_open( commw2f, filename, i, mpi_info_null, fh, e )
    call mpi_file_set_view( fh, offset, rtype, wfiletype, 'native', mpi_info_null, e )
else
    call mpi_file_close( fh, e )
    fh = mpi_file_null
end if 
end subroutine

! open file with MPIIO
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
call mpi_comm_size( comm, n, e  )
call mpi_comm_rank( comm, i, e  )
call mpi_comm_rank( mpi_comm_world, ip, e  )
if ( verb .and. i == 0 ) write( 0, '(i8,a,i2,a,i8,2a)' ) &
    ip, ' Opening', ndims, 'D', n, 'P file: ', trim( filename )
if ( mode == 'r' ) then
    i = mpi_mode_rdonly
elseif ( oo(n) == 0 ) then
    i = mpi_mode_wronly + mpi_mode_create + mpi_mode_excl
else
    i = mpi_mode_wronly
end if
call mpi_file_set_errhandler( mpi_file_null, mpi_errors_are_fatal, e )
call mpi_file_open( comm, filename, i, mpi_info_null, fh, e )
ftype = rtype
if ( ndims > 0 ) then
    mmm = pack( mm, mm > 1, mm )
    nnn = pack( nn, mm > 1, nn )
    ooo = pack( oo, mm > 1, oo )
    call mpi_type_create_subarray( ndims, mmm, nnn, ooo, mpi_order_fortran, rtype, ftype, e )
    call mpi_type_commit( ftype, e )
end if
call mpi_file_set_view( fh, offset, rtype, ftype, 'native', mpi_info_null, e )
end subroutine

end module

