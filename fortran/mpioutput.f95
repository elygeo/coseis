!------------------------------------------------------------------------------!
! MPIOUTPUT

subroutine mpioutput( iz, comm )

use globals 
implicit none
include 'mpif.h'
integer :: i, iz, comm, err, ftype, mtype, fh, d = 0, nl(4), ng(4), start(4)
integer :: mof = mpi_order_fortran, msi = mpi_status_ignore
integer :: mode =  mpi_mode_create + mpi_mode_wronly + mpi_mode_excl
character(255) :: ofile

select case ( outvar(iz) )
case('x'); nc = 3
case('u'); nc = 3
case('v'); nc = 3
case default; stop 'Error: outvar'
end select
call zoneselect( i1, i2, iout(iz,:), npg, hypocenter, nrmdim )
i1g = i1
i2g = i2
i1 = max( i1, i1node )
i2 = max( i2, i2node )
ng(1:3) = i2g - i1g + 1
nl(1:3) = i2 - i1 + 1
start(1:3) = i1 - i1g
call mpi_type_create_subarray( 3, ng, nl, start, mof, mpi_real, ftype, err )
call mpi_type_commit( ftype, err )
ng = size( v )
nl(1:3) = outli2(iz,:) - outli1(iz,:) + 1
start(1:3) = outli1(iz,:) - i1node
ng(4) = outnc(iz)
lsize(4) = 1
start(4) = ic - 1
call mpi_type_create_subarray( 4, ng, nl, start, mof, mpi_real, mtype, err )
call mpi_type_commit( mtype, err )
call mpi_file_set_errhandler( mpi_file_null, mpi_errors_are_fatal, err )
do ic = 1, outnc(iz)
  write ( ofile, '(a,i2.2,a,i1,a,i5.5)' ) 'out/', iz, '/', ic, '/', it
  call mpi_file_open( comm, ofile, mode, mpi_info_null, fh, err )
  call mpi_file_set_view( fh, d, mpi_real, ftype, 'native', mpi_info_null, err )
  select case ( outvar(iz) )
  case('x'); call mpi_file_write_all( fh, x, 1, mtype, msi, err )
  case('u'); call mpi_file_write_all( fh, u, 1, mtype, msi, err )
  case('v'); call mpi_file_write_all( fh, v, 1, mtype, msi, err )
  case default; stop 'Error: outvar'
  end select
  call mpi_file_close( fh )
end do
call mpi_type_free( mtype, err )
call mpi_type_free( ftype, err )
if ( ipe == 0 ) then
  write( ofile, '(a,i2.2,a)' ) 'out/', iz, '/hdr'
  open(  9, file=ofile )
  write( 9, * ) nc, i1, i2, outint(iz), it, dt, dx, outvar(iz)
  close( 9 )
end if

end subroutine

