! Splice SORD output
program main
implicit none
real, allocatable :: x(:,:)
integer :: np(3), nn(3), nl(3), i1(4), i2(4), dit, io
character(8) :: filename

open( 1, file='out/hdr', status='old' )
read( 1, * ) nn
read( 1, * ) np
nl = nn / np; where ( modulo( nn, np ) /= 0 ) nl = nl + 1
np = nn / nl; where ( modulo( nn, nl ) /= 0 ) np = np + 1
doline: do
  read( 1, '(a)', iostat=io ) filename, dit, i1, i2
  if ( io /= 0 ) exit doline
end do doline

end program

