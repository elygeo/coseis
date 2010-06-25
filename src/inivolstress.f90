! Initialization of volume stresses 
module m_inivolstress
implicit none
contains

subroutine inivolstress 
use m_globals
use m_diffcn
use m_bc
use m_util
use m_fieldio
use m_collective
integer :: i1(3), i2(3), i, ic, iid, id,   &
           j1, k1, l1, j2, k2, l2, j3, k3, l3, j4, k4, l4

if ( verb ) write( 0, * ) 'Initialization of volume stresses'

si1 = 0.0
si2 = 0.0

call fieldio( '<>', 'a11', si1(:,:,:,1) )
call fieldio( '<>', 'a22', si1(:,:,:,2) )
call fieldio( '<>', 'a33', si1(:,:,:,3) )
call fieldio( '<>', 'a23', si2(:,:,:,1) )
call fieldio( '<>', 'a31', si2(:,:,:,2) )
call fieldio( '<>', 'a12', si2(:,:,:,3) )

!print *, si1(50,50,2,1), maxval(si1(:,:,:,1)), minval(si1(:,:,:,1))
!print *, si1(50,50,2,2), maxval(si1(:,:,:,2)), minval(si1(:,:,:,2))
!print *, si1(50,50,2,3), maxval(si1(:,:,:,3)), minval(si1(:,:,:,3))
!print *, si2(50,50,2,1), maxval(si2(:,:,:,1)), minval(si2(:,:,:,1))
!print *, si2(50,50,2,2), maxval(si2(:,:,:,2)), minval(si2(:,:,:,2))
!print *, si2(50,50,2,3), maxval(si2(:,:,:,3)), minval(si2(:,:,:,3))

w1 = si1
w2 = si2
call vector_swap_halo( w1, nhalo )
call vector_swap_halo( w2, nhalo )

s1 = 0.0
call set_halo( s1, 0.0, i1node, i2node )

! Loop over component and derivative direction
doic: do ic  = 1, 3
doid: do iid = 1, 3; id = modulo( ic + iid - 2, 3 ) + 1

! Elastic region
! f_i = w_ij,j
i1 = i1node
i2 = i2node
if ( ic == id ) then
    call diffcn( s1, w1, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx )
else
    i = 6 - ic - id
    call diffcn( s1, w2, i, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx )
end if

! Add contribution to force vector
if ( ic == id ) then
    w1(:,:,:,ic) = s1
else
    w1(:,:,:,ic) = w1(:,:,:,ic) + s1
end if

end do doid
end do doic

print *, 'w1(...,1): ', minval(w1(:,:,:,1)), maxval(w1(:,:,:,1))
print *, 'w1(...,2): ', minval(w1(:,:,:,2)), maxval(w1(:,:,:,2))
print *, 'w1(...,3): ', minval(w1(:,:,:,3)), maxval(w1(:,:,:,3))

call vector_swap_halo( w1, nhalo )
call vector_bc( w1, bc1, bc2, i1bc, i2bc )

print *, 'w1(...,1): ', minval(w1(:,:,:,1)), maxval(w1(:,:,:,1))
print *, 'w1(...,2): ', minval(w1(:,:,:,2)), maxval(w1(:,:,:,2))
print *, 'w1(...,3): ', minval(w1(:,:,:,3)), maxval(w1(:,:,:,3))

! Extract tractions on fault
i1 = 1
i2 = nm
i1(ifn) = irup
i2(ifn) = irup
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1(ifn) = irup + 1
i2(ifn) = irup + 1
j3 = i1(1); j4 = i2(1)
k3 = i1(2); k4 = i2(2)
l3 = i1(3); l4 = i2(3)
  
print *, 'j1,j2: ', j1, j2
print *, 'j3,j4: ', j3, j4
print *, 'k1,k2: ', k1, k2
print *, 'k3,k4: ', k3, k4
print *, 'l1,l2: ', l1, l2
print *, 'l3,l4: ', l3, l4

print *, minval(w1(j1:j2,k1:k2,l1:l2,1)), maxval(w1(j1:j2,k1:k2,l1:l2,1))
print *, minval(w1(j1:j2,k1:k2,l1:l2,2)), maxval(w1(j1:j2,k1:k2,l1:l2,2))
print *, minval(w1(j1:j2,k1:k2,l1:l2,3)), maxval(w1(j1:j2,k1:k2,l1:l2,3))

print *, minval(w1(j3:j4,k3:k4,l3:l4,1)), maxval(w1(j3:j4,k3:k4,l3:l4,1)) 
print *, minval(w1(j3:j4,k3:k4,l3:l4,2)), maxval(w1(j3:j4,k3:k4,l3:l4,2))
print *, minval(w1(j3:j4,k3:k4,l3:l4,3)), maxval(w1(j3:j4,k3:k4,l3:l4,3))

!f1 = area * ( mr(j1:j2,k1:k2,l1:l2) + mr(j3:j4,k3:k4,l3:l4) )
f1 = area
call invert( f1 )

print *, 'f1: ', minval(f1), maxval(f1)
print *, 'mr: ', minval(mr), maxval(mr)

do i = 1, 3
!     t0(:,:,:,i) = w1(j3:j4,k3:k4,l3:l4,i) - w1(j1:j2,k1:k2,l1:l2,i)
!     t0(:,:,:,i) =  &
!            f1 * ( w1(j3:j4,k3:k4,l3:l4,i) * mr(j3:j4,k3:k4,l3:l4) &
!                 - w1(j1:j2,k1:k2,l1:l2,i) * mr(j1:j2,k1:k2,l1:l2) )
     t0(:,:,:,i) =  &
            0.5 * f1  * ( w1(j3:j4,k3:k4,l3:l4,i) + w1(j1:j2,k1:k2,l1:l2,i) )             
end do

print *, 't0(...,1): ', t0(200,300:305,:,1), t0(200,300:305,:,1)
print *, 't0(...,2): ', t0(200,300:305,:,2), t0(200,300:305,:,2)
print *, 't0(...,3): ', t0(200,300:305,:,3), t0(200,300:305,:,3)

end subroutine

end module

