!------------------------------------------------------------------------------!

module globals
end module

module mod2
  use globals
  contains
    subroutine extsub
    x = 1.22
    end subroutine
end module

program main
  use mod2
  real :: x(4) = (/ 1.1, 2.2, 3.3, 4.4 /), y(8)
  integer :: i = 5, j = 4
  integer, allocatable :: al(:,:)
  logical :: z(3) = .true.
  allocate( al(1:10,1:0) )
  al = 2
  print *, 'asdf', al
  call extsub
  contains
    subroutine intsub
    end subroutine
end program

