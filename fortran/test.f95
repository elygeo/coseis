
module stuff

implicit none

contains

function fun( x ) result( y )
real :: x(:), y(size(x)/2)
y = x(2::2) * 2.34766
end function

subroutine sub( x, y )
real :: x(:), y(:)
y(2::2) = x(2::2) * 2.34766
end subroutine

end module

program main
use stuff
implicit none
integer, parameter :: n = 10000000
integer :: i, j
real, allocatable :: x(:), y(:)
allocate( x(n), y(n) )
x = 3.2455
forall( i = 1:n )
  where ( x > 3. ) x(i) = x(i) * y(i)
end forall
do i = 1,10
  !call sub( x, y )
  !y(2::2) = fun( x )
end do
print *, x(1)
end program

