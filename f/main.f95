!------------------------------------------------------------------------------!
! MAIN

program sord

use globals_m
use input_m
use setup_m
use gridgen_m
use matmodel_m
use fault_m
use momentsrc_m
use vstep_m
use wstep_m
use output_m

print '(a)', 'SORD - Support Opperator Rupture Dynamics'

call input
call setup
call gridgen
call matmodel
call fault
call momentsrc

do while ( it < nt )
  it = it + 1;
  call system_clock( wt(1) ); call vstep
  call system_clock( wt(2) ); call output( 1 )
  call system_clock( wt(3) ); call ustep
  call system_clock( wt(4) ); call wstep
  call system_clock( wt(5) ); call output( 2 )
end do

end program

