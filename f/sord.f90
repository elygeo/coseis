! SORD - main program
program sord

! Modules
use m_collective
use m_globals
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
use m_util
implicit none

! Initialization
call timer
call initialize( ip, np0, master )
call inread
call setup
if ( master ) write( 0, * ) 'SORD - Support Operator Rupture Dynamics'
call arrays            ; if ( master ) call timer( 1, 'main', 1 )
call gridgen           ; if ( master ) call timer( 1, 'main', 2 )
call output_init       ; if ( master ) call timer( 1, 'main', 3 )
call momentsource_init ; if ( master ) call timer( 1, 'main', 4 )
call material          ; if ( master ) call timer( 1, 'main', 5 )
call pml               ; if ( master ) call timer( 1, 'main', 6 )
call fault_init        ; if ( master ) call timer( 1, 'main', 7 )
call metadata          ; if ( master ) call timer( 1, 'main', 8 )
call output( 0 )       ; if ( master ) call timer( 1, 'main', 9 )
call resample          ; if ( master ) call timer( 1, 'main', 10 )
call readcheckpoint    ; if ( master ) call timer( 1, 'main', 11 )
if ( it == 0 ) then
  call output( 1 )     ; if ( master ) call timer( 1, 'main', 12 )
  call output( 2 )     ; if ( master ) call timer( 1, 'main', 13 )
end if

! Main loop
if ( master ) write( 0, * ) 'Main loop'
if ( master ) call timer( 3, 'main', 14 )
do while ( it < nt )
  call timestep        ; if ( master ) call timer( 1, '0tst', it )
  if ( master ) then
    write( 0, '(a)', advance='no' ) '.'
    if ( it == nt .or. mod( it, 50 ) == 0 ) write( 0, '(i6)' ) it
  end if
  call stress          ; if ( master ) call timer( 1, '1str', it )
  call momentsource    ; if ( master ) call timer( 1, '2mom', it )
  call output( 1 )     ; if ( master ) call timer( 1, '3out', it )
  call acceleration    ; if ( master ) call timer( 1, '4acc', it )
  call fault           ; if ( master ) call timer( 1, '5flt', it )
  call locknodes       ; if ( master ) call timer( 1, '6loc', it )
  call output( 2 )     ; if ( master ) call timer( 1, '7out', it )
  call writecheckpoint ; if ( master ) call timer( 1, '8ckp', it )
  if ( master ) call timer( 2, '9tot', it )
end do

! Finish up
if ( master ) write( 0, * ) 'Finished!'
if ( master ) call timer( 3, 'main', 15 )
if ( master ) call timer( 4, 'main', 16 )
call finalize

end program

