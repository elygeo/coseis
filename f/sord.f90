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
real :: prof0(16), prof1(itio), prof2(itio), prof3(itio), prof4(itio)
integer :: i

! Initialization
prof0(1) = timer( 0 )
call initialize( ip, np0, master )                ; prof0(1) = timer( 1 )
call inread                                       ; prof0(2) = timer( 1 )
call setup                                        ; prof0(3) = timer( 1 )
if ( master ) write( 0, * ) 'SORD - Support Operator Rupture Dynamics'
if ( sync ) call barrier ; call arrays            ; prof0(4) = timer( 1 )
if ( sync ) call barrier ; call gridgen           ; prof0(5) = timer( 1 )
if ( sync ) call barrier ; call output_init       ; prof0(6) = timer( 1 )
if ( sync ) call barrier ; call momentsource_init ; prof0(7) = timer( 1 )
if ( sync ) call barrier ; call material          ; prof0(8) = timer( 1 )
if ( sync ) call barrier ; call pml
if ( sync ) call barrier ; call fault_init        ; prof0(9) = timer( 1 )
if ( sync ) call barrier ; call metadata          ; prof0(10) = timer( 1 )
if ( sync ) call barrier ; call output( 0 )       ; prof0(11) = timer( 1 )
if ( sync ) call barrier ; call resample          ; prof0(12) = timer( 1 )
if ( sync ) call barrier ; call readcheckpoint    ; prof0(13) = timer( 1 )
if ( it == 0 ) then
  if ( sync ) call barrier ; call output( 1 )     ; prof0(14) = timer( 1 )
  if ( sync ) call barrier ; call output( 2 )     ; prof0(15) = timer( 1 )
end if

! Main loop
if ( sync ) call barrier ; prof0(16) = timer( 3 )
if ( master ) write( 0, * ) 'Main loop'
if ( master ) call rwrite1( 'prof/main', prof0 )
i = itio
do while ( it < nt )
  i = modulo( it, itio ) + 1
  if ( sync ) call barrier ; call timestep
  if ( master ) then
    write( 0, '(a)', advance='no' ) '.'
    if ( modulo( it, 50 ) == 0 .or. it == nt ) write( 0, '(i6)' ) it
  end if
  if ( sync ) call barrier ; call stress
  if ( sync ) call barrier ; call momentsource     ; prof1(i) = timer( 1 )
  if ( sync ) call barrier ; call output( 1 )      ; prof2(i) = timer( 1 )
  if ( sync ) call barrier ; call acceleration     ; prof1(i) = prof1(i) + timer( 1 )
  if ( sync ) call barrier ; call vectorswaphalo( w1, nhalo ) ; prof3(i) = timer( 1 )
  if ( sync ) call barrier ; call fault
  if ( sync ) call barrier ; call locknodes        ; prof1(i) = prof1(i) + timer( 1 )
  if ( sync ) call barrier ; call output( 2 )
  if ( modulo( it, itcheck ) == 0 ) then
    if ( sync ) call barrier ; call writecheckpoint
  end if
  prof2(i) = prof2(i) + timer( 1 )
  prof4(i) = timer( 2 )
  if ( modulo( it, itio ) == 0 .and. master ) then
    call rwrite1( 'prof/comp', prof1, it )
    call rwrite1( 'prof/out' , prof2, it )
    call rwrite1( 'prof/comm', prof3, it )
    call rwrite1( 'prof/step', prof4, it )
  end if
end do

! Finish up
if ( sync ) call barrier
if ( master ) then
  if ( i /= itio ) then
    call rwrite1( 'prof/comp', prof1(1:i), it )
    call rwrite1( 'prof/out',  prof2(1:i), it )
    call rwrite1( 'prof/comm', prof3(1:i), it )
    call rwrite1( 'prof/step', prof4(1:i), it )
  end if
  prof0(1) = timer( 3 )
  prof0(2) = timer( 4 )
  call rwrite1( 'prof/main', prof0(1:2), 18 )
  write( 0, * ) 'Finished!'
end if
call finalize

end program

