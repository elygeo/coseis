!------------------------------------------------------------------------------!
! MPI

module parallel_m
use mpi

implicit none
save
integer :: comm
logical :: period(3) = .false.

contains

! Initialize
subroutine init
call mpi_init( err )
end subroutine

! Finalize
subroutine finalize
call mpi_finalize( err )
end subroutine

! Find rank
subroutine prank( np, ip, ip3 )
integer, intent(in) :: np
integer, intent(out) :: ip, ip3
call mpi_cart_create( mpi_comm_world, 3, np, period, .true., comm, err )
call mpi_comm_rank( comm, ip, err  )
call mpi_cart_get( comm, 3, np, period, ip3, err )
end subroutine

! Parallel integer minimum
function pimin( l ) result( g )
integer :: l, g
mpi_allreduce( l, g, 1, mpi_integer, mpi_min, comm, err )
end function

! Parallel real minimum
function prmin( l ) result( g )
real :: l, g
mpi_allreduce( l, g, 1, mpi_real, mpi_min, comm, err )
end function

! Parallel real maximum
function prmax( l ) result( g )
real :: l, g
mpi_allreduce( l, g, 1, mpi_real, mpi_max, comm, err )
end function

! Swap halo
subroutine swaphalo
use globals

integer :: nreqs, req(12), commout(nz), mpistatus( mpi_statis_size, 4 )
integer :: i, ng(4), nl(4), istart(4) = 0, ape1, ape2, vsub

do i = 1, nout
  call mpi_comm_split( comm, outme(i), ip, commout(i), err )
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

!------------------------------------------------------------------------------!
! PWRITE

module pwrite_m
contains
subroutine pwrite( filename, s1, i1, i2 )

implicit none
character*(*), intent(in) :: filename
real, intent(in) :: s1(:,:,:)
integer, intent(in) :: i1(3), i2(3)
integer :: ftype, mtype, fh, d = 0, nl(3), ng(3), istart(3)
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

