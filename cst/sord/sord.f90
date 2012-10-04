! SORD main program
program sord

! modules
use collective
use globals
use parameters
use setup
use arrays
use grid_generation
use field_io_mod
use material_model
use kinematic_source
use dynamic_rupture
use material_resample
use time_integration
use stress
use acceleration
use utilities
use statistics
implicit none
integer :: jp = 0, fh(7)
real :: prof0(10) = 0.0
real, allocatable :: prof(:,:)

! initialization
iotimer = 0.0
prof0(1) = timer(0)
call initialize(np0, ip);        master = ip == 0; prof0(1)  = timer(6)
call read_parameters;                              prof0(2)  = timer(6)
call setup_dimensions;     if (sync) call barrier; prof0(3)  = timer(6)
if (master) write (*, '(a)') 'SORD - Support Operator Rupture Dynamics'
call allocate_arrays;      if (sync) call barrier; prof0(4)  = timer(6)
call init_grid;            if (sync) call barrier; prof0(5)  = timer(6)
call init_material;        if (sync) call barrier; prof0(6)  = timer(6)
call init_pml;             if (sync) call barrier; prof0(7)  = timer(6)
call init_finite_source;   if (sync) call barrier; prof0(8)  = timer(6)
call init_rupture;         if (sync) call barrier; prof0(9)  = timer(6)
call resample_material;    if (sync) call barrier; prof0(10) = timer(6)
fh = -1
if (mpout /= 0) fh = file_null

! write profile info
if (master) then
    open (1, file='prof-init.txt', status='replace')
    write (1, "(g15.7,'  initialize')")         prof0(1)
    write (1, "(g15.7,'  read_parameters')")    prof0(2)
    write (1, "(g15.7,'  setup_dimensions')")   prof0(3)
    write (1, "(g15.7,'  allocate_arrays')")    prof0(4)
    write (1, "(g15.7,'  init_grid')")          prof0(5)
    write (1, "(g15.7,'  init_material')")      prof0(6)
    write (1, "(g15.7,'  init_pml')")           prof0(7)
    write (1, "(g15.7,'  init_finite_source')") prof0(8)
    write (1, "(g15.7,'  init_rupture')")       prof0(9)
    write (1, "(g15.7,'  resample_material')")  prof0(10)
    close (1)
end if

! main loop
if (master) write (*, '(a,i6,a)') 'Main loop:', nt, ' steps'
allocate (prof(7,itio))
prof(1,1) = timer(7)
loop: do while (it < nt)
it = it + 1
jp = jp + 1
mptimer = 0.0
iotimer = 0.0
prof(1,jp) = timer(5)
call step_time;     if (sync) call barrier; prof(1,jp) = timer(5)
call step_stress;   if (sync) call barrier; prof(2,jp) = timer(5)
call step_accel;    if (sync) call barrier; prof(3,jp) = timer(5)
call stats;         if (sync) call barrier; prof(4,jp) = timer(5)
prof(5,jp) = mptimer
prof(6,jp) = iotimer
prof(7,jp) = timer(6)
if (it == nt .or. modulo(it, itio) == 0) then
    if (master) then
        call rio1(fh(1), prof(1,:jp), 'w', 'prof-1time.bin',   nt, it-jp, mpout, verb)
        call rio1(fh(2), prof(2,:jp), 'w', 'prof-2stress.bin', nt, it-jp, mpout, verb)
        call rio1(fh(3), prof(3,:jp), 'w', 'prof-3accel.bin',  nt, it-jp, mpout, verb)
        call rio1(fh(4), prof(4,:jp), 'w', 'prof-4stats.bin',  nt, it-jp, mpout, verb)
        call rio1(fh(5), prof(5,:jp), 'w', 'prof-5mp.bin',     nt, it-jp, mpout, verb)
        call rio1(fh(6), prof(6,:jp), 'w', 'prof-6io.bin',     nt, it-jp, mpout, verb)
        call rio1(fh(7), prof(7,:jp), 'w', 'prof-7step.bin',   nt, it-jp, mpout, verb)
        open (1, file='currentstep', status='replace')
        write (1, '(i6)') it
        close (1)
    end if
    jp = 0
end if
if (it == itstop) stop
end do loop

! finish up
if (sync) call barrier
if (master) write (*, '(a)') 'Finished!'
call finalize

end program

