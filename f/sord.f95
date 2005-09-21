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
use steptime_m

! Initialization
call init
call inread
call setup
call arrays
call gridgen
call matmodel
call momentsrc
call fault
call swaphalo
call output( 'a' )

! Main loop
do while ( it < nt )
  call pml
  call gradu
  call momentsrc
  call output( 'w' ) 
  call divw
  call swaphalo
  call fault
  call locknodes
  call output( 'a' )
  call steptime
end do

! Finsh up
call finalize

end program

