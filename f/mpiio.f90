! MPIIO
module collectiveio_m
use collective_m
implicit none
integer, private, allocatable :: commout(:)
contains

! Split communicator
subroutine iosplit( iz, nout, ditout )
integer, intent(in) :: iz, nout, ditout
integer :: e
if ( .not. allocated( commout ) ) allocate( commout(nout+1) )
call mpi_comm_split( c, ditout, 0, commout(iz), e )
end subroutine

! Scalar field input/output
subroutine scalario( io, filename, s1, ir, i1, i2, i1l, i2l, iz )
character(*), intent(in) :: io, filename
real, intent(in) :: s1(:,:,:)
integer, intent(in) :: ir, i1(3), i2(3), i1l(3), i2l(3), iz
integer :: ftype, mtype, fh, nl(4), n(4), i0(4), e
integer(kind=mpi_offset_kind) :: d = 0
call mpi_file_set_errhandler( mpi_file_null, mpi_errors_are_fatal, e )
nl = (/ i2l - i1l + 1, 1      /)
n  = (/ i2  - i1  + 1, ir     /)
i0 = (/ i1l - i1,      ir - 1 /)
call mpi_type_create_subarray( 4, n, nl, i0, mpi_order_fortran, mpi_real, ftype, e )
call mpi_type_commit( ftype, e )
n  = (/ size(s1,1), size(s1,2), size(s1,3), 1 /)
i0 = (/ i1l - 1, 1 /)
call mpi_type_create_subarray( 3, n, nl, i0, mpi_order_fortran, mpi_real, mtype, e )
call mpi_type_commit( mtype, e )
select case( io )
case( 'r' )
  call mpi_file_open( c, filename, mpi_mode_rdonly, mpi_info_null, fh, e )
  call mpi_file_set_view( fh, d, mpi_real, ftype, 'native', mpi_info_null, e )
  call mpi_file_read_all( fh, s1, 1, mtype, mpi_status_ignore, e )
  call mpi_file_close( fh, e )
case( 'w' )
  call mpi_file_open( commout(iz), filename, mpi_mode_create + mpi_mode_wronly, mpi_info_null, fh, e )
  call mpi_file_set_view( fh, d, mpi_real, ftype, 'native', mpi_info_null, e )
  call mpi_file_write_all( fh, s1, 1, mtype, mpi_status_ignore, e )
  call mpi_file_close( fh, e )
end select
call mpi_type_free( mtype, e )
call mpi_type_free( ftype, e )
end subroutine

! Vector field component input/output
subroutine vectorio( io, filename, w1, ic, ir, i1, i2, i1l, i2l, iz )
character(*), intent(in) :: io, filename
real, intent(in) :: w1(:,:,:,:)
integer, intent(in) :: ic, ir, i1(3), i2(3), i1l(3), i2l(3), iz
integer :: ftype, mtype, fh, nl(4), n(4), i0(4), e
integer(kind=mpi_offset_kind) :: d = 0
call mpi_file_set_errhandler( mpi_file_null, mpi_errors_are_fatal, e )
nl = (/ i2l - i1l + 1, 1      /)
n  = (/ i2  - i1  + 1, ir     /)
i0 = (/ i1l - i1,      ir - 1 /)
call mpi_type_create_subarray( 4, n, nl, i0, mpi_order_fortran, mpi_real, ftype, e )
call mpi_type_commit( ftype, e )
n  = (/ size(w1,1), size(w1,2), size(w1,3), size(w1,4) /)
i0 = (/ i1l - 1,  ic - 1 /)
call mpi_type_create_subarray( 4, n, nl, i0, mpi_order_fortran, mpi_real, mtype, e )
call mpi_type_commit( mtype, e )
select case( io )
case( 'r' )
  call mpi_file_open( c, filename, mpi_mode_rdonly, mpi_info_null, fh, e )
  call mpi_file_set_view( fh, d, mpi_real, ftype, 'native', mpi_info_null, e )
  call mpi_file_read_all( fh, w1, 1, mtype, mpi_status_ignore, e )
  call mpi_file_close( fh, e )
case( 'w' )
  call mpi_file_open( commout(iz), filename, mpi_mode_create + mpi_mode_wronly, mpi_info_null, fh, e )
  call mpi_file_set_view( fh, d, mpi_real, ftype, 'native', mpi_info_null, e )
  call mpi_file_write_all( fh, w1, 1, mtype, mpi_status_ignore, e )
  call mpi_file_close( fh, e )
end select
call mpi_type_free( mtype, e )
call mpi_type_free( ftype, e )
end subroutine

end module

