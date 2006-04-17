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

! Initialization
call tic
call initialize( ip, np0, master )
if ( master ) call toc( 'SORD - Support Operator Rupture Dynamics' )
call inread
call setup
call arrays
call readcheckpoint
call gridgen
call material
call pml
call momentsource_init
call fault_init
call output_init
if ( master ) call toc( 'Finished initialization' )

! Main loop
do while ( it <= nt )
  call tic
  call stress
  call momentsource
  call output( 'w' ) 
  call acceleration
  call fault
  call locknodes
  call output( 'a' )
  call writecheckpoint
  call timestep
  if ( master ) call toc( 'Finished step', it - 1 )
end do

! Finish up
if ( master ) call toc( 'Finished run' )
call finalize

end program

