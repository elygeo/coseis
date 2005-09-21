!------------------------------------------------------------------------------!
! MPIIO

module parallelio_m
use mpi
use parallel_m

FIXME
do i = 1, nout
  call mpi_comm_split( comm, outme(i), ip, commout(i), err )
end do

! Write vector component
subroutine pwrite3( filename, w1, i1, i2, i, nn, noff )
implicit none
character*(*), intent(in) :: filename
real, intent(in) :: w1(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), nn(3), noff, i
integer :: ftype, mtype, fh, d = 0, nl(4), ng(4), i0(4), &
  mode = mpi_mode_create + mpi_mode_wronly + mpi_mode_excl
call mpi_file_set_errhandler( mpi_file_null, mpi_errors_are_fatal, err )
ng = (/ nn,            3     /)
nl = (/ i2 - i1 + 1,   1     /)
i0 = (/ i1 - 1 - noff, i - 1 /)
call mpi_type_create_subarray( 4, ng, nl, i0, mof, mpi_real, ftype, err )
call mpi_type_commit( ftype, err )
ng = (/ size(w1,1), size(w1,2), size(w1,3), size(w1,4) /)
nl = (/ i2 - i1 + 1,   1     /)
i0 = (/ i1 - 1,        i - 1 /)
call mpi_type_create_subarray( 4, ng, nl, i0, mof, mpi_real, mtype, err )
call mpi_type_commit( mtype, err )
call mpi_file_open( comm, filename, mode, mpi_info_null, fh, err )
call mpi_file_set_view( fh, d, mpi_real, ftype, 'native', mpi_info_null, err )
call mpi_file_write_all( fh, w1, 1, mtype, msi, err )
call mpi_file_close( fh )
call mpi_type_free( mtype, err )
call mpi_type_free( ftype, err )
end subroutine

! Write scalar field
subroutine pwrite3( filename, s1, i1, i2, nn, noff )
implicit none
character*(*), intent(in) :: filename
real, intent(in) :: s1(:,:,:)
integer, intent(in) :: i1(3), i2(3), nn(3), noff
integer :: ftype, mtype, fh, d = 0, nl(3), ng(3), i0(3), &
  mode = mpi_mode_create + mpi_mode_wronly + mpi_mode_excl
call mpi_file_set_errhandler( mpi_file_null, mpi_errors_are_fatal, err )
ng = nn
nl = i2 - i1 + 1
i0 = i1 - 1 - noff
call mpi_type_create_subarray( 3, nn, nl, i0, mof, mpi_real, ftype, err )
call mpi_type_commit( ftype, err )
ng = (/ size(w1,1), size(w1,2), size(w1,3) /)
nl = i2 - i1 + 1
i0 = i1 - 1
call mpi_type_create_subarray( 4, ng, nl, i0, mof, mpi_real, mtype, err )
call mpi_type_commit( mtype, err )
call mpi_file_open( comm, filename, mode, mpi_info_null, fh, err )
call mpi_file_set_view( fh, d, mpi_real, ftype, 'native', mpi_info_null, err )
call mpi_file_write_all( fh, s1, 1, mtype, msi, err )
call mpi_file_close( fh )
call mpi_type_free( mtype, err )
call mpi_type_free( ftype, err )
end subroutine

end module

