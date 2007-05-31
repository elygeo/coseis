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
real :: r, prof(8*itio)
integer :: i

! Initialization
call timer
call initialize( ip, np0, master )
call inread
call setup
if ( master ) write( 0, * ) 'SORD - Support Operator Rupture Dynamics'
call arrays            ; if ( master ) call writetimer( 1, 'prof0', 1 )
call gridgen           ; if ( master ) call writetimer( 1, 'prof0', 2 )
call output_init       ; if ( master ) call writetimer( 1, 'prof0', 3 )
call momentsource_init ; if ( master ) call writetimer( 1, 'prof0', 4 )
call material          ; if ( master ) call writetimer( 1, 'prof0', 5 )
call pml               ; if ( master ) call writetimer( 1, 'prof0', 6 )
call fault_init        ; if ( master ) call writetimer( 1, 'prof0', 7 )
call metadata          ; if ( master ) call writetimer( 1, 'prof0', 8 )
call output( 0 )       ; if ( master ) call writetimer( 1, 'prof0', 9 )
call resample          ; if ( master ) call writetimer( 1, 'prof0', 10 )
call readcheckpoint    ; if ( master ) call writetimer( 1, 'prof0', 11 )
if ( it == 0 ) then
  call output( 1 )     ; if ( master ) call writetimer( 1, 'prof0', 12 )
  call output( 2 )     ; if ( master ) call writetimer( 1, 'prof0', 13 )
end if

! Main loop
if ( master ) write( 0, * ) 'Main loop'
if ( master ) call writetimer( 3, 'prof0', 14 )
do while ( it < nt )
  i = modulo( it-1, itio ) + 1
  call timestep        ; call timer( r, 1 ); prof(i*8-7) = r
  if ( master ) then
    write( 0, '(a)', advance='no' ) '.'
    if ( it == nt .or. mod( it, 50 ) == 0 ) write( 0, '(i6)' ) it
  end if
  call stress          ; call timer( r, 1 ); prof(i*8-6) = r
  call momentsource
  call output( 1 )     ; call timer( r, 1 ); prof(i*8-5) = r
  call acceleration    ; call timer( r, 1 ); prof(i*8-4) = r
  call fault           ; call timer( r, 1 ); prof(i*8-3) = r
  call locknodes
  call output( 2 )     ; call timer( r, 1 ); prof(i*8-2) = r
  call writecheckpoint ; call timer( r, 1 ); prof(i*8-1) = r
  call timer( r, 2 ); prof(i*8) = r
  if ( master ) then
  if ( i == itio .or. it == nt .or. modulo( it, itcheck ) == 0 ) then
    call rwrite1( 'prof1', prof(:i*8), it*8 )
  end if
  end if
end do

! Finish up
if ( master ) write( 0, * ) 'Finished!'
if ( master ) call writetimer( 3, 'prof0', 15 )
if ( master ) call writetimer( 4, 'prof0', 16 )
call finalize

end program

