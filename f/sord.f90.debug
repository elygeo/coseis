! SORD - main program
program sord

! Modules
use inread_m
use setup_m
use arrays_m
use checkpoint_m
use gridgen_m
use material_m
use output_m
use pml_m
use stress_m
use momentsource_m
use acceleration_m
use fault_m
use locknodes_m
use timestep_m

integer i

! Initialization
call initialize( ip, np0, master )
if ( master ) then
  open( 9, file='log', position='append' )
  write( 9, * ) 'SORD - Support Operator Rupture Dynamics'
  close( 9 )
end if

! Setup
call inread( 'defaults.m' )
call inread( 'in.m' )
call setup
call arrays
call readcheckpoint
call gridgen
call material
call momentsource_init
call fault_init
call output_init

print *, 'x1'; print *, x(:,:,5:6,1)
print *, 'x2'; print *, x(:,:,5:6,2)
print *, 'x3'; print *, x(:,:,5:6,3)
print *, 'mr'; print *, mr(:,:,5:6)
print *, 'lam'; print *, lam(:,:,4:5)
print *, 'mu'; print *, mu(:,:,4:5)
print *, 'y'; print *, y(:,:,4:5)
! Main loop
do while ( it <= nt )
  call pml
  call stress
print *, it, '---------------------'
print *, 'w1'; print *, w1(:,:,4:5,1)
print *, 'w2'; print *, w1(:,:,4:5,2)
print *, 'w3'; print *, w1(:,:,4:5,3)
print *, 'w4'; print *, w2(:,:,4:5,1)
print *, 'w5'; print *, w2(:,:,4:5,2)
print *, 'w6'; print *, w2(:,:,4:5,3)
  call momentsource
  call output( 'w' ) 
  call acceleration
print *, it, '---------------------'
print *, 'a1'; print *, w1(:,:,5:6,1)
print *, 'a2'; print *, w1(:,:,5:6,2)
print *, 'a3'; print *, w1(:,:,5:6,3)
  call fault
print *, it, '---------------------'
print *, 'a1-'; print *, w1(:,:,5:6,1)
print *, 'a2-'; print *, w1(:,:,5:6,2)
print *, 'a3-'; print *, w1(:,:,5:6,3)
  call locknodes
  call output( 'a' )
  call writecheckpoint
  call timestep
end do

! Finish up
if ( master ) then
  open( 9, file='log', position='append' )
  write( 9, * ) 'Finished'
  close( 9 )
end if
call finalize

end program

