program main
use mpi
integer :: e, i, n
call mpi_init(e)
call mpi_comm_rank(mpi_comm_world, i, e)
call mpi_comm_size(mpi_comm_world, n, e)
print *, 'Process ', i, ' of ', n
!$omp parallel do schedule(static) private(i)
do i = 1, 100000000
end do
!$omp end parallel do
call mpi_finalize(e)
end program
