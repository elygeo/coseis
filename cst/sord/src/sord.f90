! SORD main program
program sord

! modules
use m_collective
use m_globals
use m_parameters
use m_setup
use m_arrays
use m_grid_gen
use m_fieldio
use m_material
use m_source
use m_rupture
use m_resample
use m_checkpoint
use m_timestep
use m_stress
use m_acceleration
use m_util
use m_stats
implicit none
integer :: jp = 0, fh(9)
real :: prof0(14) = 0.0
real, allocatable :: prof(:,:)

! initialization
iotimer = 0.0
prof0(1) = timer(0)
call initialize( np0, ip )     ; master = ip == 0 ; prof0(1)  = timer(6)
call read_parameters                              ; prof0(2)  = timer(6)
call setup               ; if (sync) call barrier ; prof0(3)  = timer(6)
if ( master ) write( *, '(a)' ) 'SORD - Support Operator Rupture Dynamics'
call look_for_checkpoint ; if (sync) call barrier ; prof0(4)  = timer(6)
call arrays              ; if (sync) call barrier ; prof0(5)  = timer(6)
call grid_gen            ; if (sync) call barrier ; prof0(6)  = timer(6)
call material            ; if (sync) call barrier ; prof0(7)  = timer(6)
call pml                 ; if (sync) call barrier ; prof0(8)  = timer(6)
call finite_source_init  ; if (sync) call barrier ; prof0(9)  = timer(6)
call rupture_init        ; if (sync) call barrier ; prof0(10) = timer(6)
call resample            ; if (sync) call barrier ; prof0(11) = timer(6)
call read_checkpoint     ; if (sync) call barrier ; prof0(12) = timer(6)
fh = -1
if ( mpout /= 0 ) fh = file_null
allocate( prof(8,itio) )
prof0(13) = iotimer
prof0(14) = timer(7)
if ( master ) call rio1( fh(9), prof0, 'w', 'prof/main.bin', 16, 0, mpout, verb )
prof0(14) = timer(7)

! main loop
if ( master ) write( *, '(a,i6,a)' ) 'Main loop:', nt, ' steps'
loop: do while ( it < nt )
it = it + 1
jp = jp + 1
mptimer = 0.0
iotimer = 0.0
prof(1,jp) = timer(5)
call timestep            ; if (sync) call barrier ; prof(1,jp) = timer(5)
call stress              ; if (sync) call barrier ; prof(2,jp) = timer(5)
call acceleration        ; if (sync) call barrier ; prof(3,jp) = timer(5)
call stats               ; if (sync) call barrier ; prof(4,jp) = timer(5)
call write_checkpoint    ; if (sync) call barrier ; prof(5,jp) = timer(5)
prof(6,jp) = mptimer
prof(7,jp) = iotimer
prof(8,jp) = timer(6)
if ( it == nt .or. modulo( it, itio ) == 0 ) then
    if ( master ) then
        call rio1( fh(1), prof(1,:jp), 'w', 'prof/1time.bin',   nt, it-jp, mpout, verb )
        call rio1( fh(2), prof(2,:jp), 'w', 'prof/2stress.bin', nt, it-jp, mpout, verb )
        call rio1( fh(3), prof(3,:jp), 'w', 'prof/3accel.bin',  nt, it-jp, mpout, verb )
        call rio1( fh(4), prof(4,:jp), 'w', 'prof/4stats.bin',  nt, it-jp, mpout, verb )
        call rio1( fh(5), prof(5,:jp), 'w', 'prof/5ckpt.bin',   nt, it-jp, mpout, verb )
        call rio1( fh(6), prof(6,:jp), 'w', 'prof/6mp.bin',     nt, it-jp, mpout, verb )
        call rio1( fh(7), prof(7,:jp), 'w', 'prof/7io.bin',     nt, it-jp, mpout, verb )
        call rio1( fh(8), prof(8,:jp), 'w', 'prof/8step.bin',   nt, it-jp, mpout, verb )
        open( 1, file='currentstep', status='replace' )
        write( 1, '(i6)' ) it
        close( 1 )
    end if
    jp = 0
end if
if ( master .and. it == itstop ) stop
end do loop

! finish up
if ( sync ) call barrier
prof0(1) = timer(7)
prof0(2) = timer(8)
if ( master ) then
    call rio1( fh(9), prof0(:2), 'w', 'prof/main.bin', 16, 14, mpout, verb )
    write( *, '(a)' ) 'Finished!'
end if
call finalize

end program

