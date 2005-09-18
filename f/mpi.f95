subroutine setup
use globals
use mpi

implicit none
save
integer :: nreqs, req(12), comm, commout(nz), mpistatus( mpi_statis_size, 4 )
integer :: i, err
integer, intent(in) :: stage
integer, intent(out) :: nreqs = 0, req(12)
integer :: err, i, ng(4), nl(4), istart(4) = 0, ape1, ape2, vsub
logical :: period(3) = .false., init = .true.
real :: x00(3), matmin0(3), matmax0(3)
integer :: it0

nl = nn / np; where ( mod( nn, np ) /= 0 ) nl = nl + 1
nl = max( nl, nn - noff ) broken!!!!
np = nn / nl; where ( mod( nn, nl ) /= 0 ) np = np + 1


call mpi_cart_create( mpi_comm_world, 3, np, period, .true., comm3, err )
call mpi_cart_get( comm, 3, np, period, ip3, err )

! figure out if fault is on processor
! set bc depending on ip3

nm = nl + 2 * nhalo
i1node = nhalo + 1
i2node = nhalo + nl
i1cell = nhalo + 1
i2cell = nhalo + nl - 1
where( ip3 /= 0      ) i1cell = i1cell - nhalo
where( ip3 /= np - 1 ) i2cell = i2cell + nhalo
i1nodepml = max( i1node, 1      + bc(1:3) * npml )
i2nodepml = min( i2node, nn     - bc(4:6) * npml )
i1cellpml = max( i1cell, 1      + bc(1:3) * npml )
i2cellpml = min( i2cell, nn - 1 - bc(4:6) * npml )

offset = nl * ip3 + nhalo
where( hypocenter == 0 ) hypocenter = nn / 2 + mod( nn, 2 )

! now run along now and alloacter arrays
end subroutine

!------------------------------------------------------------------------------!
! SWAPHALO
subroutine swaphalo
use globals
use mpi

x00 = x0
it0 = it
matmin0 = matmin
matmax0 = matmax
mpi_broadcast( x0 ... )
mpi_allreduce( it0, it, 1, mpi_integer, mpi_min, comm3d, err )
mpi_allreduce( matmin0, matmin, 3, mpi_real, mpi_min, comm3d, err )
mpi_allreduce( matmax0, matmax, 3, mpi_real, mpi_max, comm3d, err )

do i = 1, nout
  call mpi_comm_split( comm3, outme(i), ip, commout(i), err )
end do

if ( comm3 == mpi_comm_null ) then
  print *, 'unused processor: ', ip
  call mpi_finalize( err )
  stop
end if
nreqs = count( np > 1 ) * 4
ng = size( v )
do i = 1, 3
if ( np(i) > 1 ) then
  call mpi_cart_shift( comm3, i-1, 1, ape1, ape2, err )
  nl = ng
  nl(i) = nhalo
  istart = i1node - nhalo
  call mpi_type_create_subarray( 4, ng, nl, istart, mof, mpi_real, vsub, err )
  call mpi_type_commit( vsub, err )
  call mpi_recv_init( v(j,k,l,:), 1, vsub, ape1, 1, comm3, req(4*i-3), err )
  istart(i) = i2node(i) + nhalo
  call mpi_type_create_subarray( 4, ng, nl, istart, mof, mpi_real, vsub, err )
  call mpi_type_commit( vsub, err )
  call mpi_recv_init( v(j,k,l,:), 1, vsub, ape2, 2, comm3, req(4*i-2), err )
  istart(i) = i1node(i)
  call mpi_type_create_subarray( 4, ng, nl, istart, mof, mpi_real, vsub, err )
  call mpi_type_commit( vsub, err )
  call mpi_send_init( v(j,k,l,:), 1, vsub, ape1, 2, comm3, req(4*i-1), err )
  istart(i) = i2node(i)
  call mpi_type_create_subarray( 4, ng, nl, istart, mof, mpi_real, vsub, err )
  call mpi_type_commit( vsub, err )
  call mpi_send_init( v(j,k,l,:), 1, vsub, ape2, 1, comm3, req(4*i-0), err )
end if
end do

  do i = 1, nreqs, 4
    call mpi_startall( 4, req(i), err )
    call mpi_waitall( 4, req(i), mpistatus, err )
  end do
call mpi_finalize( err )

!------------------------------------------------------------------------------!
! BWRITE

module bwrite_m
contains
subroutine bwrite( filename, s1, i1, i2 )
use mpi
use sordmpi_m

implicit none
include 'mpif.h'

character*(*), intent(in) :: filename
real, intent(in) :: s1(:,:,:)
integer, intent(in) :: i1(3), i2(3)

integer :: comm, err, ftype, mtype, fh, d = 0, nl(3), ng(3), istart(3)
integer :: mof = mpi_order_fortran, msi = mpi_status_ignore
integer :: mode =  mpi_mode_create + mpi_mode_wronly + mpi_mode_excl

i1 = max( i1, i1node )
i2 = max( i2, i2node )

ng = i2 - i1 + 1
nl = i2 - i1 + 1
start = i1 + offset

call mpi_type_create_subarray( 3, ng, nl, istart, mof, mpi_real, ftype, err )
call mpi_type_commit( ftype, err )

ng = size( v )
nl = i2l(iz,:) - i1l(iz,:) + 1
start = i1l - i1node

call mpi_type_create_subarray( 4, ng, nl, istart, mof, mpi_real, mtype, err )
call mpi_type_commit( mtype, err )

call mpi_file_set_errhandler( mpi_file_null, mpi_errors_are_fatal, err )
call mpi_file_open( comm, filename, mode, mpi_info_null, fh, err )
call mpi_file_set_view( fh, d, mpi_real, ftype, 'native', mpi_info_null, err )
call mpi_file_write_all( fh, x, 1, mtype, msi, err )
call mpi_file_close( fh )
call mpi_type_free( mtype, err )
call mpi_type_free( ftype, err )

end subroutine
end module

