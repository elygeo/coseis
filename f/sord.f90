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
call inread            ; if ( master ) call tictoc( 'init', 1 )
call setup             ; if ( master ) call tictoc( 'init', 2 )
call arrays            ; if ( master ) call tictoc( 'init', 3 )
call readcheckpoint    ; if ( master ) call tictoc( 'init', 4 )
call gridgen           ; if ( master ) call tictoc( 'init', 5 )
call material          ; if ( master ) call tictoc( 'init', 6 )
call pml               ; if ( master ) call tictoc( 'init', 7 )
call momentsource_init ; if ( master ) call tictoc( 'init', 8 )
call fault_init        ; if ( master ) call tictoc( 'init', 9 )
call output_init       ; if ( master ) call tictoc( 'init', 10 )

! Main loop
if ( master ) print *, 'Starting main loop'
do while ( it <= nt )
  call tictoc
  call stress          ; if ( master ) call tictoc( 'm1str', it )
  call momentsource    ; if ( master ) call tictoc( 'm2src', it )
  call output( 1 )     ; if ( master ) call tictoc( 'm3out', it )
  call acceleration    ; if ( master ) call tictoc( 'm4acc', it )
  call fault           ; if ( master ) call tictoc( 'm5flt', it )
  call locknodes       ; if ( master ) call tictoc( 'm6lok', it )
  call output( 2 )     ; if ( master ) call tictoc( 'm7out', it )
  call writecheckpoint ; if ( master ) call tictoc( 'm8ckp', it )
  call timestep        ; if ( master ) call tictoc( 'm9tst', it-1 )
end do

! Finish up
if ( master ) print *, 'Finished'
call finalize

end program

