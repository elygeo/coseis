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
use m_bc
implicit none
real :: prof0(16), prof1(itio), prof2(itio), prof3(itio), prof4(itio)
integer :: jp = 0

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
if ( master ) call tseriesio( 1, mpout, 'prof/main', prof0, 16 )
do while ( it < nt )
  it = it + 1
  jp = jp + 1
  if ( sync ) call barrier ; call timestep
  if ( sync ) call barrier ; call stress
  if ( sync ) call barrier ; call momentsource ; prof1(jp) = timer( 1 )
  if ( sync ) call barrier ; call output( 1 )  ; prof2(jp) = timer( 1 )
  if ( sync ) call barrier ; call acceleration
  if ( sync ) call barrier ; call fault
  if ( sync ) call barrier ; call locknodes    ; prof1(jp) = prof1(jp) + timer( 1 )
  if ( sync ) call barrier ; call output( 2 )  ; prof2(jp) = prof2(jp) + timer( 1 )
  if ( sync ) call barrier ; call vectorswaphalo( w1, nhalo ) ; prof3(jp) = timer( 1 )
  if ( sync ) call barrier ; call vectorbc( w1, bc1, bc2, i1bc, i2bc, 0 )
  if ( modulo( it, itcheck ) == 0 ) then
    if ( sync ) call barrier ; call writecheckpoint
  end if
  prof2(jp) = prof2(jp) + timer( 1 )
  prof4(jp) = timer( 2 )
  if ( it == nt .or. modulo( it, itio ) == 0 ) then
    if ( master ) then
      call tseriesio( 1, mpout, 'prof/comp', prof1(:jp), it )
      call tseriesio( 1, mpout, 'prof/out' , prof2(:jp), it )
      call tseriesio( 1, mpout, 'prof/comm', prof3(:jp), it )
      call tseriesio( 1, mpout, 'prof/step', prof4(:jp), it )
    end if
    jp = 0
  end if
end do

! Finish up
if ( sync ) call barrier
if ( master ) then
  prof0(1) = timer( 3 )
  prof0(2) = timer( 4 )
  call tseriesio( 1, mpout, 'prof/main', prof0(:2), 18 )
  write( 0, * ) 'Finished!'
end if
call finalize

end program

