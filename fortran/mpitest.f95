program main

include 'mpif.h'

call mpi_init( ierr )
call mpi_comm_rank( mpi_comm_world, ipe, ierr )
print *, ipe, ierr

end program main
