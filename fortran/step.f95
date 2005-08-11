!------------------------------------------------------------------------------!
! STEP

module step_m

implicit none
real, public :: yy = 2

contains

subroutine step

write(*,*) yy

yy = yy + 3

end subroutine

end module

