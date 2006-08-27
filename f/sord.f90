! SORD - main program
program sord

! Modules
use m_inread
use m_setup
use m_arrays
use m_gridgen
use m_output
use m_momentsource
use m_material
use m_fault
use m_metadata
use m_resample
use m_checkpoint
use m_timestep
use m_stress
use m_acceleration
use m_locknodes

! Initialization
call timer
call initialize( ip, np0, master )
call inread
call setup
if ( master ) write( 0, * ) 'SORD - Support Operator Rupture Dynamics'
call arrays            ; if ( master ) call timer( 1, 'init', 1 )
call gridgen           ; if ( master ) call timer( 1, 'init', 2 )
call output_init       ; if ( master ) call timer( 1, 'init', 3 )
call momentsource_init ; if ( master ) call timer( 1, 'init', 4 )
call material          ; if ( master ) call timer( 1, 'init', 5 )
call pml               ; if ( master ) call timer( 1, 'init', 6 )
call fault_init        ; if ( master ) call timer( 1, 'init', 7 )
call metadata          ; if ( master ) call timer( 1, 'init', 8 )
call output( 0 )       ; if ( master ) call timer( 1, 'init', 9 )
call resample          ; if ( master ) call timer( 1, 'init', 10 )
call output( 1 )       ; if ( master ) call timer( 1, 'init', 11 )
call output( 2 )       ; if ( master ) call timer( 1, 'init', 12 )
call readcheckpoint    ; if ( master ) call timer( 1, 'init', 13 )

! Main loop
if ( master ) write( 0, * ) 'Main loop'
if ( master ) call timer( 3, 'main', 1 )
do while ( it < nt )
  call timestep        ; if ( master ) call timer( 1, 'step', it )
  call stress          ; if ( master ) call timer( 1, 'stre', it )
  call momentsource    ; if ( master ) call timer( 1, 'msrc', it )
  call output( 1 )     ; if ( master ) call timer( 1, 'out1', it )
  call acceleration    ; if ( master ) call timer( 1, 'accl', it )
  call fault           ; if ( master ) call timer( 1, 'falt', it )
  call locknodes       ; if ( master ) call timer( 1, 'lock', it )
  call output( 2 )     ; if ( master ) call timer( 1, 'out2', it )
  call writecheckpoint ; if ( master ) call timer( 1, 'ckpt', it )
  if ( master ) then
    write( 0, '(a)', advance='no' ) '.'
    if ( it == nt .or. mod( it, 50 ) == 0 ) write( 0, '(i6)' ) it
    call timer( 2, 'loop', it )
  end if
end do

! Finish up
if ( master ) write( 0, * ) 'Finished!'
if ( master ) call timer( 3, 'main', 2 )
if ( master ) call timer( 4, 'main', 3 )
call finalize

end program

