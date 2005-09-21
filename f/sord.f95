!------------------------------------------------------------------------------!
! SORD

program sord

! Modules
use globals_m
use inread_m
use parallel_m
use indices_m
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
use steptime_m

! Initialization
call init
if ( ip == 0 ) print '(a)', ''
if ( ip == 0 ) print '(a)', 'SORD - Support Operator Rupture Dynamics'
call inread( 'defaults.m' )
call inread( 'in.m' )
call indices
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
  call steptime
end do

! Finsh up
call finalize

end program

