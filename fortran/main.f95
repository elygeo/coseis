!------------------------------------------------------------------------------!

program sord
use globals

print '(a)', 'SORD - Support Opperator Rupture Dynamics'

call input
call init
call gridgen
call matmodel
call fault

do while ( it < nt )
  it = it + 1;
  call system_clock( wt(1) ); call vstep
  call system_clock( wt(2) ); call output( 1 )
  call system_clock( wt(3) ); call ustep
  call system_clock( wt(4) ); call wstep
  call system_clock( wt(5) ); call output( 2 )
end do

end program

