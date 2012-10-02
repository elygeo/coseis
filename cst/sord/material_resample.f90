! resample material arrays
module material_resample
implicit none
contains

subroutine resample_material
use globals
use collective
use boundary_cond
use utilities
integer :: i1(3), i2(3), bc(3)

if (master) write (*, '(a)') 'Resample material model'

! mass ratio
s2 = mr * vc
call average(mr, s2, i1node, i2node, -1)
call r3invert(mr)
call scalar_swap_halo(mr, nhalo)
call scalar_bc(mr, bc1, bc2, i1bc, i2bc)

! invert cell volume
call r3invert(vc)

! viscosity, bc=4 means copy into halo for resampling at the node
bc = 4
i1 = i1bc - 1
i2 = i2bc
call scalar_bc(gam, bc, bc, i1, i2)
s2 = gam * dt
call average(gam, s2, i1node, i2node, -1)
call set_halo(gam, 0.0, i1bc, i2bc)
call scalar_swap_halo(gam, nhalo)
call scalar_bc(gam, bc1, bc2, i1bc, i2bc)

! zero hourglass viscosity outside boundary, and at fault cell
i1 = i1bc
i2 = i2bc - 1
call set_halo(yy, 0.0, i1, i2)
select case (ifn)
case (1); yy(irup,:,:) = 0.0
case (2); yy(:,irup,:) = 0.0
case (3); yy(:,:,irup) = 0.0
end select

! initial state
tm = 0.0
vv = 0.0
uu = 0.0
w1 = 0.0
!z1 = 0.0
!z2 = 0.0
p1 = 0.0
p2 = 0.0
p3 = 0.0
p4 = 0.0
p5 = 0.0
p6 = 0.0
g1 = 0.0
g2 = 0.0
g3 = 0.0
g4 = 0.0
g5 = 0.0
g6 = 0.0

w2 = 0.0
s1 = 0.0
s2 = 0.0

end subroutine

end module

