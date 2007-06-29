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
integer :: jp = 0
real :: prof0(17) = 0.
real, allocatable, dimension(:) :: prof1, prof2, prof3, prof4

! Initialization
prof0(1) = timer( 0 )
call initialize( ip, np0, master )                         ; prof0(1) = timer( 6 )
call inread                                                ; prof0(2) = timer( 6 )
call setup                                                 ; prof0(3) = timer( 6 )
if ( master ) write( 0, * ) 'SORD - Support Operator Rupture Dynamics'
if ( sync ) call barrier ; call arrays                     ; prof0(4) = timer( 6 )
if ( sync ) call barrier ; call gridgen                    ; prof0(5) = timer( 6 )
if ( sync ) call barrier ; call output_init                ; prof0(6) = timer( 6 )
if ( sync ) call barrier ; call momentsource_init          ; prof0(7) = timer( 6 )
if ( sync ) call barrier ; call material                   ; prof0(8) = timer( 6 )
if ( sync ) call barrier ; call pml
if ( sync ) call barrier ; call fault_init                 ; prof0(9) = timer( 6 )
if ( sync ) call barrier ; call metadata                   ; prof0(10) = timer( 6 )
if ( sync ) call barrier ; call lookforcheckpoint          ; prof0(11) = timer( 6 )
if ( sync ) call barrier ; if ( it == 0 ) call output( 0 ) ; prof0(12) = timer( 6 )
if ( sync ) call barrier ; call resample                   ; prof0(13) = timer( 6 )
if ( sync ) call barrier ; call readcheckpoint             ; prof0(14) = timer( 6 )
if ( sync ) call barrier ; if ( it == 0 ) call output( 1 ) ; prof0(15) = timer( 6 )
if ( sync ) call barrier ; if ( it == 0 ) call output( 2 ) ; prof0(16) = timer( 6 )
if ( sync ) call barrier ; prof0(17) = timer( 7 )
if ( master .and. it == 0 ) call rio1( 1, mpout, 'prof/main', prof0, 17 )
allocate( prof1(itio), prof2(itio), prof3(itio), prof4(itio) )

! Main loop
if ( master ) write( 0, * ) 'Main loop'
do while ( it < nt )
  it = it + 1
  jp = jp + 1
  if ( sync ) call barrier ; call timestep
  if ( sync ) call barrier ; call stress
  if ( sync ) call barrier ; call momentsource    ; prof1(jp) = timer( 5 )
  if ( sync ) call barrier ; call output( 1 )     ; prof2(jp) = timer( 5 )
  if ( sync ) call barrier ; call acceleration   
  if ( sync ) call barrier ; call fault           
  if ( sync ) call barrier ; call locknodes       ; prof1(jp) = prof1(jp) + timer( 5 )
  if ( sync ) call barrier ; call output( 2 )     ; prof2(jp) = prof2(jp) + timer( 5 )
  if ( sync ) call barrier ; call vectorswaphalo( w1, nhalo ) ; prof3(jp) = timer( 5 )
  if ( sync ) call barrier ; call vectorbc( w1, bc1, bc2, i1bc, i2bc, 0 )
  if ( modulo( it, itcheck ) == 0 ) then
    if ( sync ) call barrier ; call writecheckpoint
  end if
  prof2(jp) = prof2(jp) + timer( 5 )
  prof4(jp) = timer( 6 )
  if ( it == nt .or. modulo( it, itio ) == 0 ) then
    if ( master ) then
      call rio1( 1, mpout, 'prof/comp', prof1(:jp), it )
      call rio1( 1, mpout, 'prof/out' , prof2(:jp), it )
      call rio1( 1, mpout, 'prof/comm', prof3(:jp), it )
      call rio1( 1, mpout, 'prof/step', prof4(:jp), it )
    end if
    jp = 0
  end if
  if ( it == itstop ) then
    if ( master ) write( 0, * ) 'Killing job'
    stop
  end if
end do

! Finish up
if ( sync ) call barrier
if ( master ) then
  prof0(1) = timer( 7 )
  prof0(2) = timer( 8 )
  call rio1( 1, mpout, 'prof/main', prof0(:2), 19 )
  write( 0, * ) 'Finished!'
end if
call finalize

end program

