!------------------------------------------------------------------------------!
! SORD

program sord

use globals
implicit none
integer :: wt(5), wt_rate
real :: dwt(5)

call inputs
call gridgen
call matmodel
print '(a)', 'step  compute  commun   output   checkpnt total'
it = 0

do while ( it <= nt )
  it = it + 1;
  call system_clock( wt(1), count_rate=wt_rate )
  call vstep
  call ustep
  call system_clock( wt(2) )
  call wstep
  call system_clock( wt(3) )
  call output
  call system_clock( wt(4) )
  dwt(1:4) = real( wt(2:4) - wt(1:3) ) / real( wt_rate )
  dwt(5)   = real( wt(4)   - wt(1)   ) / real( wt_rate )
  print '(a,i5,x,4(e9.2))', it, dwt
end do

end program

