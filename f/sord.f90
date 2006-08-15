! SORD - main program
program sord

! Modules
use m_inread
use m_setup
use m_arrays
use m_checkpoint
use m_gridgen
use m_material
use m_output_init
use m_output
use m_pml
use m_stress
use m_momentsource
use m_acceleration
use m_fault_init
use m_fault
use m_locknodes
use m_timestep

! Initialization
call tic
call initialize( ip, np0, master )
if ( master ) print *, 'SORD - Support Operator Rupture Dynamics'
call inread
call setup
call arrays
call readcheckpoint
call gridgen
call material
call pml
call momentsource_init
call fault_init
call output_init
if ( master ) print *, toc(), 'Finished initialization'

! Main loop
do while ( it <= nt )
  call tic             ; if ( master ) call write( *, *, advance='no' ) '.'
  call stress          ; if ( master ) call rwrite( '00/wt1', toc(), it )
  call momentsource    ; if ( master ) call rwrite( '00/wt2', toc(), it )
  call output( 1 )     ; if ( master ) call rwrite( '00/wt3', toc(), it )
  call acceleration    ; if ( master ) call rwrite( '00/wt4', toc(), it )
  call fault           ; if ( master ) call rwrite( '00/wt5', toc(), it )
  call locknodes       ; if ( master ) call rwrite( '00/wt6', toc(), it )
  call output( 2 )     ; if ( master ) call rwrite( '00/wt7', toc(), it )
  call writecheckpoint ; if ( master ) call rwrite( '00/wt8', toc(), it )
  call timestep        ; if ( master ) call rwrite( '00/wt9', toc(), it-1 )
end do

! Finish up
if ( master ) print *, 'Finished'
call finalize

end program

