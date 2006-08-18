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
call clock
call initialize( ip, np0, master )
if ( master ) write( 0, * ) 'SORD - Support Operator Rupture Dynamics'
call inread            ; if ( master ) call clock( '0ini', 1 )
call setup             ; if ( master ) call clock( '0ini', 2 )
call arrays            ; if ( master ) call clock( '0ini', 3 )
call gridgen           ; if ( master ) call clock( '0ini', 4 )
call material          ; if ( master ) call clock( '0ini', 5 )
call pml               ; if ( master ) call clock( '0ini', 6 )
call momentsource_init ; if ( master ) call clock( '0ini', 7 )
call fault_init        ; if ( master ) call clock( '0ini', 8 )
call output_init       ; if ( master ) call clock( '0ini', 9 )
call readcheckpoint    ; if ( master ) call clock( '0ini', 10 )

! Main loop
if ( master ) write( 0, * ) 'Main loop'
do while ( it < nt )
  call clock
  call timestep        ; if ( master ) call clock( '1tst', it )
  call stress          ; if ( master ) call clock( '2str', it )
  call momentsource    ; if ( master ) call clock( '3src', it )
  call output( 1 )     ; if ( master ) call clock( '4out', it )
  call acceleration    ; if ( master ) call clock( '5acc', it )
  call fault           ; if ( master ) call clock( '6flt', it )
  call locknodes       ; if ( master ) call clock( '7lok', it )
  call output( 2 )     ; if ( master ) call clock( '8out', it )
  call writecheckpoint ; if ( master ) call clock( '9ckp', it )
  if ( master ) then
    write( 0, '(a)', advance='no' ) '.'
    if ( it == nt .or. mod( it, 50 ) == 0 ) write( 0, * ) it
  end if
end do

! Finish up
if ( master ) write( 0, * ) 'Finished!'
call finalize

end program

