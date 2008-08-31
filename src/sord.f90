! SORD - main program
program sord

! Modules
use m_collective
use m_globals
use m_inread
use m_setup
use m_arrays
use m_grid_gen
use m_file_io
use m_source
use m_material
use m_fault
use m_metadata
use m_resample
use m_checkpoint
use m_timestep
use m_stress
use m_acceleration
use m_util
implicit none
integer :: jp = 0
real :: prof0(17) = 0.
real, allocatable :: prof(:,:)

! Initialization
prof0(1) = timer( 0 )
call initialize( np0, ip, master )                          ; prof0(1) = timer( 6 )
call inread                                                 ; prof0(2) = timer( 6 )
call setup                                                  ; prof0(3) = timer( 6 )
if ( master ) write( 0, * ) 'SORD - Support Operator Rupture Dynamics'
if ( sync ) call barrier ; call arrays                      ; prof0(4) = timer( 6 )
if ( sync ) call barrier ; call grid_gen                    ; prof0(5) = timer( 6 )
if ( sync ) call barrier ; call file_io_init                ; prof0(6) = timer( 6 )
if ( sync ) call barrier ; call source_init                 ; prof0(7) = timer( 6 )
if ( sync ) call barrier ; call material                    ; prof0(8) = timer( 6 )
if ( sync ) call barrier ; call pml
if ( sync ) call barrier ; call fault_init                  ; prof0(9) = timer( 6 )
if ( sync ) call barrier ; call metadata                    ; prof0(10) = timer( 6 )
if ( sync ) call barrier ; call look_for_checkpoint           ; prof0(11) = timer( 6 )
if ( sync ) call barrier ; if ( it == 0 ) call file_io( 0 ) ; prof0(12) = timer( 6 )
if ( sync ) call barrier ; call resample                    ; prof0(13) = timer( 6 )
if ( sync ) call barrier ; call read_checkpoint             ; prof0(14) = timer( 6 )
if ( sync ) call barrier ; if ( it == 0 ) call file_io( 1 ) ; prof0(15) = timer( 6 )
if ( sync ) call barrier ; if ( it == 0 ) call file_io( 2 ) ; prof0(16) = timer( 6 )
if ( sync ) call barrier ; prof0(17) = timer( 7 )
if ( master .and. it == 0 ) call rio1( 10, mpout, 'prof/main', prof0, 17, 19 )
allocate( prof(itio,4) )

! Main loop
if ( master ) write( 0, * ) 'Main loop'
do while ( it < nt )
  it = it + 1
  jp = jp + 1
  if ( sync ) call barrier ; call timestep
  if ( sync ) call barrier ; call finite_source
  if ( sync ) call barrier ; call stress
  if ( sync ) call barrier ; call moment_source
  if ( sync ) call barrier ; prof(jp,1) = timer( 5 )
  if ( sync ) call barrier ; call output( 1 )
  if ( sync ) call barrier ; prof(jp,2) = timer( 5 )
  if ( sync ) call barrier ; call acceleration   
  if ( sync ) call barrier ; call fault
  if ( sync ) call barrier ; prof(jp,1) = prof(jp,1) + timer( 5 )
  if ( sync ) call barrier ; call vector_swap_halo( w1, nhalo )
  if ( sync ) call barrier ; prof(jp,3) = timer( 5 )
  if ( sync ) call barrier ; call output( 2 )
  if ( modulo( it, itcheck ) == 0 ) then
    if ( sync ) call barrier ; call write_checkpoint
  end if
  if ( sync ) call barrier ; prof(jp,2) = prof(jp,2) + timer( 5 )
  prof(jp,4) = timer( 6 )
  if ( it == nt .or. modulo( it, itio ) == 0 ) then
    if ( master ) then
      call rio1( 11, mpout, 'prof/comp', prof(:jp,1), it, nt )
      call rio1( 12, mpout, 'prof/out' , prof(:jp,2), it, nt )
      call rio1( 13, mpout, 'prof/comm', prof(:jp,3), it, nt )
      call rio1( 14, mpout, 'prof/step', prof(:jp,4), it, nt )
    end if
    jp = 0
  end if
  if ( master .and. it == itstop ) stop
end do

! Finish up
if ( sync ) call barrier
if ( master ) then
  prof0(1) = timer( 7 )
  prof0(2) = timer( 8 )
  call rio1( 10, mpout, 'prof/main', prof0(:2), 19, 19 )
  write( 0, * ) 'Finished!'
end if
call finalize

end program

