! SORD - main program
program sord

! Modules
use m_inread
use m_setup
use m_arrays
use m_checkpoint
use m_gridgen
use m_material
use m_output_init
use m_output
use m_pml
use m_stress
use m_momentsource
use m_acceleration
use m_fault_init
use m_fault
use m_locknodes
use m_timestep

! Initialization
call tic
call initialize( ip, np0, master )
if ( master ) print '(a)', 'SORD - Support Operator Rupture Dynamics'
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
  call output( 1 ) 
  call acceleration
  call fault
  call locknodes
  call output( 2 )
  call writecheckpoint
  call timestep
  if ( master ) call toc( 'Finished step', it - 1 )
end do

! Finish up
if ( master ) call toc( 'Finished run' )
call finalize

end program

