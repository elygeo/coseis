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
call initialize( ip, np0, master ) ; call timer( r, 1 ); prof(1) = r
call inread                        ; call timer( r, 1 ); prof(2) = r
call setup                         ; call timer( r, 1 ); prof(3) = r
if ( master ) write( 0, * ) 'SORD - Support Operator Rupture Dynamics'
call arrays                        ; call timer( r, 1 ); prof(4) = r
call gridgen                       ; call timer( r, 1 ); prof(6) = r
call output_init                   ; call timer( r, 1 ); prof(7) = r
call momentsource_init             ; call timer( r, 1 ); prof(8) = r
call rwrite1( 'prof0', prof(:8), 8 )
call material                      ; call timer( r, 1 ); prof(1) = r
call pml
call fault_init                    ; call timer( r, 1 ); prof(2) = r
call metadata
call output( 0 )                   ; call timer( r, 1 ); prof(3) = r
call resample                      ; call timer( r, 1 ); prof(4) = r
call readcheckpoint                ; call timer( r, 1 ); prof(5) = r
if ( it == 0 ) then
  call output( 1 )                 ; call timer( r, 1 ); prof(6) = r
  call output( 2 )                 ; call timer( r, 1 ); prof(7) = r
end if

! Main loop
if ( master ) write( 0, * ) 'Main loop'
call timer( r, 3 ); prof0(8) = r
call rwrite1( 'prof0', prof(:8), 16 )
do while ( it < nt )
  i = modulo( it, itio ) + 1
  call timestep                    ; call timer( r, 1 ); prof(i*8-7) = r
  if ( master ) then
    write( 0, '(a)', advance='no' ) '.'
    if ( it == nt .or. modulo( it, 50 ) == 0 ) write( 0, '(i6)' ) it
  end if
  call stress                      ; call timer( r, 1 ); prof(i*8-6) = r
  call momentsource
  call output( 1 )                 ; call timer( r, 1 ); prof(i*8-5) = r
  call acceleration                ; call timer( r, 1 ); prof(i*8-4) = r
  call fault                       ; call timer( r, 1 ); prof(i*8-3) = r
  call locknodes
  call output( 2 )                 ; call timer( r, 1 ); prof(i*8-2) = r
  call writecheckpoint             ; call timer( r, 1 ); prof(i*8-1) = r
  call timer( r, 2 ); prof(i*8) = r
  if ( master ) then
  if ( modulo( it, itio ) == 0 .or. it == nt ) then
    call rwrite1( 'prof1', prof(:i*8), it*8 )
  end if
  end if
end do

! Finish up
call timer( r, 3 ); prof(1) = r
call timer( r, 4 ); prof(2) = r
call rwrite1( 'prof0', prof(:2), 18 )
if ( master ) write( 0, * ) 'Finished!'
call finalize

end program

