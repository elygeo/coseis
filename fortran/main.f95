!------------------------------------------------------------------------------!
! SORD

program sord
use globals
integer :: wt(5), wt_rate
real :: dwt(5)

call inputs
call setup
call gridgen
call matmodel
call output( 0 )
if ( ipe == 0 ) print '(a)', 'step  compute  commun   output   checkpnt total'
it = 0

do while ( it <= nt )
  it = it + 1;
  call system_clock( wt(1), count_rate=wt_rate )
  call vstep
  call wstep
  call system_clock( wt(2) )
  if ( nout /= 0 ) call output
  call system_clock( wt(3) )
  call system_clock( wt(4) )
  dwt(1:4) = real( wt(2:4) - wt(1:3) ) / real( wt_rate )
  dwt(5)   = real( wt(4)   - wt(1)   ) / real( wt_rate )
  if ( ipe == 0 ) print '(a,i5,x,4(e9.2))', it, dwt
end do

end program

