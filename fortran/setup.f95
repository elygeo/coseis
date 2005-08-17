!------------------------------------------------------------------------------!
! SETUP

subroutine setup
use globals
integer :: i, i1(3), i2(3), j1, j2, k1, k2, l1, l2

if( any( hypocenter == 0 ) ) hypocenter = npg / 2 + mod( npg, 2 )
if( nrmdim /= 0 ) npg(nrmdim) = npg(nrmdim) + 1
nhalo = 1
i1node = np * ipe3d + 1
i2node = np * ipe3d + np; i2node = min( i2node, npg )
i1cell = i1node
i2cell = i2node - 1
where( ipe3d /= 0         ) i1cell = i1cell - nhalo
where( ipe3d /= npe3d - 1 ) i2cell = i2cell + nhalo
i1nodepml = max( i1node, 1       + bc(1:3) * npml )
i2nodepml = min( i2node, npg     - bc(4:6) * npml )
i1cellpml = max( i1cell, 1       + bc(1:3) * npml )
i2cellpml = min( i2cell, npg - 1 - bc(4:6) * npml )

i1 = i1node - nhalo
i2 = i2node + nhalo
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
allocate( &
    x(j1:j2,k1:k2,l1:l2,3), &
    u(j1:j2,k1:k2,l1:l2,3), &
    v(j1:j2,k1:k2,l1:l2,3), &
   w1(j1:j2,k1:k2,l1:l2,3), &
   w2(j1:j2,k1:k2,l1:l2,3), &
   s1(j1:j2,k1:k2,l1:l2), &
   s2(j1:j2,k1:k2,l1:l2), &
  rho(j1:j2,k1:k2,l1:l2), &
   yn(j1:j2,k1:k2,l1:l2), &
  lam(j1:j2,k1:k2,l1:l2), &
  miu(j1:j2,k1:k2,l1:l2), &
   yc(j1:j2,k1:k2,l1:l2) )

end subroutine

