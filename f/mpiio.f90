!------------------------------------------------------------------------------!
! MPIIO

module collectiveio_m
use mpi_m
use collective_m
implicit none
integer, private, allocatable :: commout(:)
contains

! Split communicator
subroutine iosplit( iz, nout, ditout )
integer, intent(in) :: iz, nout, ditout
integer :: e
if ( .not. allocated( commout ) ) allocate( commout(nout) )
call mpi_comm_split( c, ditout, 0, commout(iz), e )
end subroutine

! Input/output scalar
subroutine ioscalar( io, filename, s1, i1, i2, n, noff, iz )
character(*), intent(in) :: io, filename
real, intent(in) :: s1(:,:,:)
integer, intent(in) :: i1(3), i2(3), n(3), noff(3), iz
integer :: ftype, mtype, fh, d=0, nl(3), ng(3), i0(3), e
call mpi_file_set_errhandler( mpi_file_null, mpi_errors_are_fatal, e )
ng = n
nl = i2 - i1 + 1
i0 = i1 - 1 - noff
call mpi_type_create_subarray( 3, ng, nl, i0, mpi_order_fortran, mpi_real, ftype, e )
call mpi_type_commit( ftype, e )
ng = (/ size(s1,1), size(s1,2), size(s1,3) /)
nl = i2 - i1 + 1
i0 = i1 - 1
call mpi_type_create_subarray( 3, ng, nl, i0, mpi_order_fortran, mpi_real, mtype, e )
call mpi_type_commit( mtype, e )
select case( io )
case( 'r' )
  call mpi_file_open( c, filename, mpi_mode_rdonly, mpi_info_null, fh, e )
  call mpi_file_set_view( fh, d, mpi_real, ftype, 'native', mpi_info_null, e )
  call mpi_file_read_all( fh, s1, 1, mtype, mpi_status_ignore, e )
  call mpi_file_close( fh )
case( 'w' )
  call mpi_file_open( commout(iz), filename, mpi_mode_create + mpi_mode_wronly, mpi_info_null, fh, e )
  call mpi_file_set_view( fh, d, mpi_real, ftype, 'native', mpi_info_null, e )
  call mpi_file_write_all( fh, s1, 1, mtype, mpi_status_ignore, e )
  call mpi_file_close( fh )
end select
call mpi_type_free( mtype, e )
call mpi_type_free( ftype, e )
end subroutine

! Input/output vector component
subroutine iovector( io, filename, w1, i, i1, i2, n, noff, iz )
character(*), intent(in) :: io, filename
real, intent(in) :: w1(:,:,:,:)
integer, intent(in) :: i, i1(3), i2(3), n(3), noff(3), iz
integer :: ftype, mtype, fh, d = 0, nl(4), ng(4), i0(4), e
call mpi_file_set_errhandler( mpi_file_null, mpi_errors_are_fatal, e )
ng = (/ n,             3     /)
nl = (/ i2 - i1 + 1,   1     /)
i0 = (/ i1 - 1 - noff, i - 1 /)
call mpi_type_create_subarray( 4, ng, nl, i0, mpi_order_fortran, mpi_real, ftype, e )
call mpi_type_commit( ftype, e )
ng = (/ size(w1,1), size(w1,2), size(w1,3), size(w1,4) /)
nl = (/ i2 - i1 + 1,   1     /)
i0 = (/ i1 - 1,        i - 1 /)
call mpi_type_create_subarray( 4, ng, nl, i0, mpi_order_fortran, mpi_real, mtype, e )
call mpi_type_commit( mtype, e )
select case( io )
case( 'r' )
  call mpi_file_open( c, filename, mpi_mode_rdonly, mpi_info_null, fh, e )
  call mpi_file_set_view( fh, d, mpi_real, ftype, 'native', mpi_info_null, e )
  call mpi_file_read_all( fh, w1, 1, mtype, mpi_status_ignore, e )
  call mpi_file_close( fh )
case( 'w' )
  call mpi_file_open( commout(iz), filename, mpi_mode_create + mpi_mode_wronly, mpi_info_null, fh, e )
  call mpi_file_set_view( fh, d, mpi_real, ftype, 'native', mpi_info_null, e )
  call mpi_file_write_all( fh, w1, 1, mtype, mpi_status_ignore, e )
  call mpi_file_close( fh )
end select
call mpi_type_free( mtype, e )
call mpi_type_free( ftype, e )
end subroutine

end module

