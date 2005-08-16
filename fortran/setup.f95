!------------------------------------------------------------------------------!
! SETUP

subroutine setup
use globals
integer :: i, i1(3), i2(3), j1, j2, k1, k2, l1, l2
real :: theta, scl

if ( any( hypocenter == 0 ) ) hypocenter = npg / 2 + mod( npg, 2 )
if ( nrmdim /= 0 ) npg(nrmdim) = npg(nrmdim) + 1
nhalo = 1
i1core = np * ipe3d + 1
i2core = np * ipe3d + np
i2core = min( i2core, npg )
halo1 = 0
halo2 = 0
where( ipe3d /= 0         ) halo1 = nhalo
where( ipe3d /= npe3d - 1 ) halo2 = nhalo
i1pml = max( i1core, 1   + bc(1:3) * npml )
i2pml = min( i2core, npg - bc(4:6) * npml )
i1 = i1core - nhalo
i2 = i2core + nhalo
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
allocate( &
    x(j1:j2,k1:k2,l1:l2,3), &
    u(j1:j2,k1:k2,l1:l2,3), &
    v(j1:j2,k1:k2,l1:l2,3), &
   yn(j1:j2,k1:k2,l1:l2), &
  rho(j1:j2,k1:k2,l1:l2) )
j2 = i2(1) - 1
k2 = i2(2) - 1
l2 = i2(3) - 1
allocate( &
   w1(j1:j2,k1:k2,l1:l2,3), &
   w2(j1:j2,k1:k2,l1:l2,3), &
   s1(j1:j2,k1:k2,l1:l2), &
   s2(j1:j2,k1:k2,l1:l2), &
  lam(j1:j2,k1:k2,l1:l2), &
  miu(j1:j2,k1:k2,l1:l2), &
   yc(j1:j2,k1:k2,l1:l2) )

end subroutine

