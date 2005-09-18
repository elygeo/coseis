!------------------------------------------------------------------------------!
! BWRITE

module bwrite_m
contains
subroutine bwrite( filename, s1, i1, i2 )
use mpi
use mpi_m

implicit none
character*(*), intent(in) :: filename
real, intent(in) :: s1(:,:,:)
integer, intent(in) :: i1(3), i2(3)

integer :: comm, err, ftype, mtype, fh, d = 0, nl(3), ng(3), start(3)
integer :: mof = mpi_order_fortran, msi = mpi_status_ignore
integer :: mode =  mpi_mode_create + mpi_mode_wronly + mpi_mode_excl

i1 = max( i1, i1node )
i2 = max( i2, i2node )

ng = i2 - i1 + 1
nl = i2 - i1 + 1
start = i1 + offset

call mpi_type_create_subarray( 3, ng, nl, start, mof, mpi_real, ftype, err )
call mpi_type_commit( ftype, err )

ng = size( v )
nl = i2l(iz,:) - i1l(iz,:) + 1
start = i1l - i1node

call mpi_type_create_subarray( 4, ng, nl, start, mof, mpi_real, mtype, err )
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

