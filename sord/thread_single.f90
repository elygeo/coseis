! threading, single thread version
module thread
implicit none
contains

subroutine int_thread(nthread)
integer, intent(in) :: nthread
if (nthread > 1) stop 'Multithread not enabled'
end subroutine

end module

