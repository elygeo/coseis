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
real :: prof(8*itio)
integer :: i

! Initialization
prof(1) = timer( 0 )
call initialize( ip, np0, master ) ; prof(1) = timer( 1 )
call inread                        ; prof(2) = timer( 1 )
call setup                         ; prof(3) = timer( 1 )
if ( master ) write( 0, * ) 'SORD - Support Operator Rupture Dynamics'
call arrays                        ; prof(4) = timer( 1 )
call gridgen                       ; prof(6) = timer( 1 )
call output_init                   ; prof(7) = timer( 1 )
call momentsource_init             ; prof(8) = timer( 1 )
if ( master ) call rwrite1( 'prof0', prof(:8), 8 )
call material                      ; prof(1) = timer( 1 )
call pml
call fault_init                    ; prof(2) = timer( 1 )
call metadata
call output( 0 )                   ; prof(3) = timer( 1 )
call resample                      ; prof(4) = timer( 1 )
call readcheckpoint                ; prof(5) = timer( 1 )
if ( it == 0 ) then
  call output( 1 )                 ; prof(6) = timer( 1 )
  call output( 2 )                 ; prof(7) = timer( 1 )
end if

! Main loop
if ( master ) write( 0, * ) 'Main loop'
prof(8) = timer( 3 )
if ( master ) call rwrite1( 'prof0', prof(:8), 16 )
do while ( it < nt )
  i = modulo( it, itio ) + 1
  call timestep                    ; prof(i*8-7) = timer( 1 )
  if ( master ) then
    write( 0, '(a)', advance='no' ) '.'
    if ( it == nt .or. modulo( it, 50 ) == 0 ) write( 0, '(i6)' ) it
  end if
  call stress                      ; prof(i*8-6) = timer( 1 )
  call momentsource
  call output( 1 )                 ; prof(i*8-5) = timer( 1 )
  call acceleration                ; prof(i*8-4) = timer( 1 )
  call fault                       ; prof(i*8-3) = timer( 1 )
  call locknodes
  call output( 2 )                 ; prof(i*8-2) = timer( 1 )
  call writecheckpoint             ; prof(i*8-1) = timer( 1 )
  prof(i*8) = timer( 2 )
  if ( modulo( it, itio ) == 0 .or. it == nt ) then
    if ( master ) call rwrite1( 'prof1', prof(:i*8), it*8 )
  end if
end do

! Finish up
prof(1) = timer( 3 )
prof(2) = timer( 4 )
if ( master ) call rwrite1( 'prof0', prof(:2), 18 )
if ( master ) write( 0, * ) 'Finished!'
call finalize

end program

