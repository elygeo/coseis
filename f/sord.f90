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
call tictoc
call initialize( ip, np0, master )
if ( master ) print *, 'SORD - Support Operator Rupture Dynamics'
call inread            ; if ( master ) call tictoc( '00/wt0', 1 )
call setup             ; if ( master ) call tictoc( '00/wt0', 2 )
call arrays            ; if ( master ) call tictoc( '00/wt0', 3 )
call readcheckpoint    ; if ( master ) call tictoc( '00/wt0', 4 )
call gridgen           ; if ( master ) call tictoc( '00/wt0', 5 )
call material          ; if ( master ) call tictoc( '00/wt0', 6 )
call pml               ; if ( master ) call tictoc( '00/wt0', 7 )
call momentsource_init ; if ( master ) call tictoc( '00/wt0', 8 )
call fault_init        ; if ( master ) call tictoc( '00/wt0', 9 )
call output_init       ; if ( master ) call tictoc( '00/wt0', 10 )

! Main loop
if ( master ) print *, 'Starting main loop'
do while ( it <= nt )
  call tictoc
  call stress          ; if ( master ) call tictoc( '00/wt1', it )
  call momentsource    ; if ( master ) call tictoc( '00/wt2', it )
  call output( 1 )     ; if ( master ) call tictoc( '00/wt3', it )
  call acceleration    ; if ( master ) call tictoc( '00/wt4', it )
  call fault           ; if ( master ) call tictoc( '00/wt5', it )
  call locknodes       ; if ( master ) call tictoc( '00/wt6', it )
  call output( 2 )     ; if ( master ) call tictoc( '00/wt7', it )
  call writecheckpoint ; if ( master ) call tictoc( '00/wt8', it )
  call timestep        ; if ( master ) call tictoc( '00/wt9', it-1 )
end do

! Finish up
if ( master ) print *, 'Finished'
call finalize

end program

