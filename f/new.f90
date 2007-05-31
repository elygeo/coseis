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
real :: prof

! Initialization
call timer
call initialize( ip, np0, master )
call inread
call setup
if ( master ) write( 0, * ) 'SORD - Support Operator Rupture Dynamics'
call arrays
call gridgen
call output_init
call momentsource_init
call material
call pml
call fault_init
call metadata
call output( 0 )
call resample
call readcheckpoint
if ( it == 0 ) then
  call output( 1 )
  call output( 2 )
end if

! Main loop
call timer( prof, 3 )
if ( master ) then
  write( 0, * ) 'Initialization time', prof
  write( 0, * ) 'Main loop'
end if
do while ( it < nt )
  call timestep        ; if ( master ) call timer( prof, 1 ) = prof
  if ( master ) then
    write( 0, '(a)', advance='no' ) '.'
    if ( it == nt .or. mod( it, 50 ) == 0 ) write( 0, '(i6)' ) it
  end if
  call stress          ; if ( master ) call timer( prof, 1 )
  call momentsource    ; if ( master ) call timer( prof, 1 )
  call output( 1 )     ; if ( master ) call timer( prof, 1 )
  call acceleration    ; if ( master ) call timer( prof, 1 )
  call fault           ; if ( master ) call timer( prof, 1 )
  call locknodes       ; if ( master ) call timer( prof, 1 )
  call output( 2 )     ; if ( master ) call timer( prof, 1 )
  call writecheckpoint ; if ( master ) call timer( prof, 1 )
  call timer( prof, 2 )
  if ( master ) then
   flush = i == itio .or. it = nt .or. modulo( it, itcheck ) /= 0
    if ( flush ) then
        call rwrite1( 'stats/vmax', gvstats(1,:i), it )
        call rwrite1( 'stats/wmax', gvstats(2,:i), it )
        call rwrite1( 'stats/umax', gvstats(3,:i), it )
        call rwrite1( 'stats/amax', gvstats(4,:i), it )

end do

! Finish up
if ( master ) then
  call timer( prof, 3 )
  write( 0, * ) 'Main loop time', prof
  write( 0, * ) 'Finished!'
end if
call finalize

end program

