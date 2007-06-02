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
real :: prof0(18), prof(4*itio)
integer :: i

! Initialization
prof0(1) = timer( 0 )
call initialize( ip, np0, master ) ; prof0(1) = timer( 1 )
call inread                        ; prof0(2) = timer( 1 )
call setup                         ; prof0(3) = timer( 1 )
if ( master ) write( 0, * ) 'SORD - Support Operator Rupture Dynamics'
call arrays                        ; prof0(4) = timer( 1 )
call gridgen                       ; prof0(5) = timer( 1 )
call output_init                   ; prof0(6) = timer( 1 )
call momentsource_init             ; prof0(7) = timer( 1 )
call material                      ; prof0(8) = timer( 1 )
call pml
call fault_init                    ; prof0(9) = timer( 1 )
call metadata                      ; prof0(10) = timer( 1 )
call output( 0 )                   ; prof0(11) = timer( 1 )
call resample                      ; prof0(12) = timer( 1 )
call readcheckpoint                ; prof0(13) = timer( 1 )
if ( it == 0 ) then
  call output( 1 )                 ; prof0(14) = timer( 1 )
  call output( 2 )                 ; prof0(15) = timer( 1 )
end if

! Main loop
if ( master ) write( 0, * ) 'Main loop'
prof0(16) = timer( 3 )
if ( master ) call rwrite1( 'prof0', prof0(1:16) )
do while ( it < nt )
  i = modulo( it, itio ) + 1
  call timestep
  if ( master ) then
    write( 0, '(a)', advance='no' ) '.'
    if ( it == nt .or. modulo( it, 50 ) == 0 ) write( 0, '(i6)' ) it
  end if
  call stress      
  call momentsource                ; prof(i*4-3) = timer( 1 )
  call output( 1 )                 ; prof(i*4-1) = timer( 1 )
  call acceleration
  call fault
  call locknodes                   ; prof(i*4-2) = timer( 1 )
  call output( 2 )
  call writecheckpoint             ; prof(i*4-1) = prof(i*4-1) + timer( 1 )
  prof(i*4) = timer( 2 )
  if ( modulo( it, itio ) == 0 .or. it == nt ) then
    if ( master ) call rwrite1( 'prof', prof(1:i*4), it*4 )
  end if
end do

! Finish up
prof0(17) = timer( 3 )
prof0(18) = timer( 4 )
if ( master ) call rwrite1( 'prof0', prof0 )
if ( master ) write( 0, * ) 'Finished!'
call finalize

end program

