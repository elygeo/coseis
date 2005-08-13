!------------------------------------------------------------------------------!

module globals
  implicit none
end module

module mod2
  use globals
  implicit none
  contains
    subroutine extsub
    x = 1.22
    end subroutine
end module

program main
  use mod2
  call extsub
  contains
    subroutine intsub
    end subroutine
end program

