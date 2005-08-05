!------------------------------------------------------------------------------!
! MAIN

program main

use step_m
use dfnc_m
use dfcn_m
use hgnc_m
use hgcn_m

implicit none
real, public :: x(2,2), asdf = 234
integer :: i, j, k

call step
call step

!forall ( j = 1:2, k = 1:2 ) x(j,k) = j*k
forall ( j = 1:2 ) 
x(:,j) = x(:,j) / 10
end forall

print '(%.1f)', x(1,1)
print *, x(1,1)

end program

