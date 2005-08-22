!------------------------------------------------------------------------------!

program sord
use globals

implicit none
integer :: wt(5), wt_rate
real :: dwt(3)

print '(a)', 'SORD - Support Opperator Rupture Dynamics'
call system_clock( wt(1), count_rate=wt_rate )
print *, wt(1)
call inputs
call gridgen
call matmodel
call fault
call output

print '(a)', 'Main time loop'
print '(a)', 'Step     V        U        W       I/O    Total'
print '(a)', 'Step     Compute  I/O    Total    |U|max  |V|max'

it = 0

do while ( it < nt )
  it = it + 1;
  call system_clock( wt(2) )
  call vstep
  call ustep
  call wstep
  call system_clock( wt(3) )
  call output
  call system_clock( wt(4) )
  dwt(1:2) = real( wt(3:4) - wt(2:3) ) / real( wt_rate )
  dwt(3)   = real( wt(4)   - wt(1)   ) / real( wt_rate )
  print '(i4,x,5(e9.2))', it, dwt, umax, vmax
end do

end program

