! threading, openmp version
module thread
implicit none
contains

subroutine init_thread(nthread)
integer, intent(in) :: nthread
if (nthread > 0) call omp_set_num_threads(nthread)
end subroutine

end module

