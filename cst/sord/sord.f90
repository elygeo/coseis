! SORD main program
program sord

use collective
use globals
use parameters
use setup
use arrays
use grid_generation
use material_model
use pml
use kinematic_source
use dynamic_rupture
use material_resample
use time_integration
use stress
use acceleration
use utilities
use statistics

implicit none

call system_clock(clock0)
call initialize(np0, ip, master)
call read_parameters
call setup_dimensions
call allocate_arrays
call init_grid
call init_material
call init_pml
call init_finite_source
call init_rupture
call resample_material

do it = 1, nt
    call system_clock(clock1)
    call step_time
    call step_stress
    call step_accel
    call stats
end do

call finalize

end program

