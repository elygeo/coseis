! SORD main program
program sord

! Modules
use m_collective
use m_globals
use m_parameters
use m_setup
use m_arrays
use m_grid_gen
use m_fieldio
use m_source
use m_material
use m_fault
use m_resample
use m_checkpoint
use m_timestep
use m_stress
use m_acceleration
use m_util
use m_stats
implicit none
integer :: jp = 0, fh(5)
real :: prof0(14) = 0.
real, allocatable :: prof(:,:)
fh = file_null

! Initialization
iotimer = 0.
prof0(1) = timer( 0 )
call initialize( np0, ip, master )                          ; prof0(1) = timer( 6 )
call read_parameters                                        ; prof0(2) = timer( 6 )
call setup                                                  ; prof0(3) = timer( 6 )
if ( master ) write( 0, * ) 'SORD - Support Operator Rupture Dynamics'
if ( sync ) call barrier ; call look_for_checkpoint         ; prof0(4) = timer( 6 )
if ( sync ) call barrier ; call arrays                      ; prof0(5) = timer( 6 )
if ( sync ) call barrier ; call grid_gen                    ; prof0(6) = timer( 6 )
if ( sync ) call barrier ; call fieldio_init                ; prof0(7) = timer( 6 )
if ( sync ) call barrier ; call source_init                 ; prof0(8) = timer( 6 )
if ( sync ) call barrier ; call material
if ( sync ) call barrier ; call pml                         ; prof0(9) = timer( 6 )
if ( sync ) call barrier ; call fault_init                  ; prof0(10) = timer( 6 )
if ( sync ) call barrier ; call resample                    ; prof0(11) = timer( 6 )
if ( sync ) call barrier ; call read_checkpoint             ; prof0(12) = timer( 6 )
if ( sync ) call barrier ; prof0(13) = iotimer              ; prof0(14) = timer( 7 )
if ( master ) call rio1( fh(1), prof0, 'w', 'prof/main', 16, 0, mpout )
allocate( prof(4,itio) )

! Main loop
if ( master ) write( 0, * ) 'Main loop'
do while ( it < nt )
  it = it + 1
  jp = jp + 1
  iotimer = 0.
  if ( sync ) call barrier ; call timestep
  if ( sync ) call barrier ; call stress
  if ( sync ) call barrier ; call moment_source
  if ( sync ) call barrier ; call acceleration   
  if ( sync ) call barrier ; call fault
  if ( sync ) call barrier ; prof(1,jp) = timer( 5 )
  if ( sync ) call barrier ; call vector_swap_halo( w1, nhalo )
  if ( sync ) call barrier ; call stats()
  if ( sync ) call barrier ; prof(2,jp) = timer( 5 )
  if ( sync ) call barrier ; call write_checkpoint
  if ( sync ) call barrier ; prof(3,jp) = timer( 5 ) + iotimer
  prof(4,jp) = timer( 6 )
  if ( it == nt .or. modulo( it, itio ) == 0 ) then
    if ( master ) then
      call rio1( fh(2), prof(1,:jp), 'w', 'prof/comp', nt, it-jp, mpout )
      call rio1( fh(3), prof(2,:jp), 'w', 'prof/comm', nt, it-jp, mpout )
      call rio1( fh(4), prof(3,:jp), 'w', 'prof/io',   nt, it-jp, mpout )
      call rio1( fh(5), prof(4,:jp), 'w', 'prof/step', nt, it-jp, mpout )
      open( 1, file='currentstep', status='replace' )
      write( 1, * ) it
      close( 1 )
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
  call rio1( fh(1), prof0(:2), 'w', 'prof/main', 16, 14, mpout )
  write( 0, * ) 'Finished!'
end if
call finalize

end program

