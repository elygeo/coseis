!------------------------------------------------------------------------------!
! SORD

program sord
use globals

implicit none
integer :: wt(5), wt_rate
real :: dwt(5)

print '(a)', 'SORD - Support Opperator Rupture Dynamics'
call inputs
call gridgen
call matmodel
call fault( 0 )

print '(a)', 'Main time loop'
print '(a)', 'Step     V        U        W       I/O    Total'

it = 0

do while ( it < nt )
  it = it + 1;
  call system_clock( wt(1), count_rate=wt_rate )
  call vstep
  call system_clock( wt(2) )
  call ustep
  call system_clock( wt(3) )
  call wstep
  call system_clock( wt(4) )
  call output
  call system_clock( wt(5) )
  dwt(1:4) = real( wt(2:5) - wt(1:4) ) / real( wt_rate )
  dwt(5)   = real( wt(5)   - wt(1)   ) / real( wt_rate )
  print '(i4,x,5(e9.2))', it, dwt
end do

end program

