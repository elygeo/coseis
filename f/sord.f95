!------------------------------------------------------------------------------!
! SORD

program sord

! Modules
use globals_m
use inread_m
use parallel_m
use setup_m
use arrays_m
use gridgen_m
use matmodel_m
use output_m
use pml_m
use gradu_m
use momentsrc_m
use divw_m
use fault_m
use locknodes_m
use timestep_m

! Initialization
call init
if ( master ) print '(a)', ''
if ( master ) print '(a)', 'SORD - Support Operator Rupture Dynamics'
call inread( 'defaults.m' )
call inread( 'in.m' )
call setup
call arrays
call gridgen
call matmodel
call momentsrc
call fault
call swaphalo( w1 )
call output( 'a' )

! Main loop
do while ( it < nt )
  call pml
  call gradu
  call momentsrc
  call output( 'w' ) 
  call divw
  call swaphalo( w1 )
  call fault
  call locknodes
  call output( 'a' )
  call timestep
end do

! Finsh up
call finalize

end program

