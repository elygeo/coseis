program main
use mpi
integer :: e, i, n
call mpi_init(e)
call mpi_comm_rank(mpi_comm_world, i, e)
call mpi_comm_size(mpi_comm_world, n, e)
print *, 'Process ', i, ' of ', n
call mpi_finalize(e)
end program

