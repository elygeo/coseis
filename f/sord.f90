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
call initialize( master )
call inread( 'defaults.m' )
call inread( 'in.m' )
call setup
call arrays
call readcheckpoint
call gridgen
call material
call momentsource
call fault
call swaphalovector( w1, nhalo )
call output( 'i' )

! Main loop
do while ( it <= nt )
  call pml
  call stress
  call momentsource
  call output( 'w' ) 
  call acceleration
  call swaphalovector( w1, nhalo )
  call fault
  call locknodes
  call output( 'a' )
  call writecheckpoint
  call timestep
end do

! Finish up
call finalize

end program

