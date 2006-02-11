! SORD - main program
program sord

! Modules
use inread_m
use setup_m
use arrays_m
use checkpoint_m
use gridgen_m
use material_m
use output_m
use pml_m
use stress_m
use momentsource_m
use acceleration_m
use fault_m
use locknodes_m
use timestep_m

integer i

! Initialization
call initialize( ip, np0, master )
if ( master ) then
  open( 9, file='log', position='append' )
  write( 9, * ) 'SORD - Support Operator Rupture Dynamics'
  close( 9 )
end if

! Setup
call inread( 'defaults.m' )
call inread( 'in.m' )
call setup
call arrays
call readcheckpoint
call gridgen
call material
call momentsource_init
call fault_init
call output_init

! Main loop
do while ( it <= nt )
  call pml
  call stress
  call momentsource
  call output( 'w' ) 
  call acceleration
  call fault
  call locknodes
  call output( 'a' )
  call writecheckpoint
  call timestep
end do

! Finish up
if ( master ) then
  open( 9, file='log', position='append' )
  write( 9, * ) 'Finished'
  close( 9 )
end if
call finalize

end program

