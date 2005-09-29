!------------------------------------------------------------------------------!
! Stress calculation

module stress_m
use globals_m
use diffnc_m
contains
subroutine stress

implicit none
integer :: i, j, k, l, i1(3), j1, k1, l1, i2(3), j2, k2, l2, ic, iid, id, iz

! Modified displacement
w1 = u + dt * v * viscosity(1)
w2 = 0.
s1 = 0.

! Loop over component and derivative direction
doic: do ic  = 1, 3
doid: do iid = 1, 3; id = mod( ic + iid - 1, 3 ) + 1

! Elastic region: G = grad(U + gamma*V)
do iz = 1, noper
  i1 = max( max( i1oper(iz,:), i1pml + 1 ),     i1cell )
  i2 = min( min( i2oper(iz,:), i2pml - 1 ) - 1, i2cell )
  call diffnc( s1, oper(iz), w1, x, dx, ic, id, i1, i2 )
end do

! PML coordinates
i1 = max( i2pml - 1, i1cell )
i2 = min( i1pml,     i2cell )
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

! PML region, non-damped directions: G = gradU
if ( id /= 1 ) then
  i1 = i1cell
  i2 = i2cell
  i2(1) = j2
  call diffnc( s1, oper(1), u, x, dx, ic, id, i1, i2 )
  i1 = i1cell
  i2 = i2cell
  i1(1) = j1
  call diffnc( s1, oper(1), u, x, dx, ic, id, i1, i2 )
end if
if ( id /= 2 ) then
  i1 = i1cell
  i2 = i2cell
  i2(2) = k2
  call diffnc( s1, oper(1), u, x, dx, ic, id, i1, i2 )
  i1 = i1cell
  i2 = i2cell
  i1(2) = k1
  call diffnc( s1, oper(1), u, x, dx, ic, id, i1, i2 )
end if
if ( id /= 3 ) then
  i1 = i1cell
  i2 = i2cell
  i2(3) = l2
  call diffnc( s1, oper(1), u, x, dx, ic, id, i1, i2 )
  i1 = i1cell
  i2 = i2cell
  i1(3) = l1
  call diffnc( s1, oper(1), u, x, dx, ic, id, i1, i2 )
end if

! PML region, damped direction: G' + DG = gradV
if ( id == 1 ) then
  i1 = i1cell
  i2 = i2cell
  i2(1) = j2
  call diffnc( s1, oper(1), v, x, dx, ic, id, i1, i2 )
  do j = i1(1), i2(1)
  i = j - nnoff(1)
  forall( k=i1(2):i2(2), l=i1(3):i2(3) )
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g1(i,k,l,ic)
    g1(i,k,l,ic) = s1(j,k,l)
  end forall
  end do
  i1 = i1cell
  i2 = i2cell
  i1(1) = j1
  call diffnc( s1, oper(1), v, x, dx, ic, id, i1, i2 )
  do j = i1(1), i2(1)
  i = nn(1) - j + nnoff(1)
  forall( k=i1(2):i2(2), l=i1(3):i2(3) )
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g4(i,k,l,ic)
    g4(i,k,l,ic) = s1(j,k,l)
  end forall
  end do
end if
if ( id == 2 ) then
  i1 = i1cell
  i2 = i2cell
  i2(2) = k2
  call diffnc( s1, oper(1), v, x, dx, ic, id, i1, i2 )
  do k = i1(2), i2(2)
  i = k - nnoff(2)
  forall( j=i1(1):i2(1), l=i1(3):i2(3) )
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g2(j,i,l,ic)
    g2(j,i,l,ic) = s1(j,k,l)
  end forall
  end do
  i1 = i1cell
  i2 = i2cell
  i1(2) = k1
  call diffnc( s1, oper(1), v, x, dx, ic, id, i1, i2 )
  do k = i1(2), i2(2)
  i = nn(2) - k + nnoff(2)
  forall( j=i1(1):i2(1), l=i1(3):i2(3) )
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g5(j,i,l,ic)
    g5(j,i,l,ic) = s1(j,k,l)
  end forall
  end do
end if
if ( id == 3 ) then
  i1 = i1cell
  i2 = i2cell
  i2(3) = l2
  call diffnc( s1, oper(1), v, x, dx, ic, id, i1, i2 )
  do l = i1(3), i2(3)
  i = l - nnoff(3)
  forall( j=i1(1):i2(1), k=i1(2):i2(2) )
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g3(j,k,i,ic)
    g3(j,k,i,ic) = s1(j,k,l)
  end forall
  end do
  i1 = i1cell
  i2 = i2cell
  i2(3) = l2
  call diffnc( s1, oper(1), v, x, dx, ic, id, i1, i2 )
  do l = i1(3), i2(3)
  i = nn(3) - l + nnoff(3)
  forall( j=i1(1):i2(1), k=i1(2):i2(2) )
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g6(j,k,i,ic)
    g6(j,k,i,ic) = s1(j,k,l)
  end forall
  end do
end if

! Add contribution to strain
if ( ic == id ) then
  w1(:,:,:,ic) = s1
else
  i = 6 - ic - id
  w2(:,:,:,i) = w2(:,:,:,i) + s1
end if

end do doid
end do doic

! Hook's Law: W = lam*trace(G)*I + mu*(G + G^T)
s1 = lam * sum( w1, 4 )
do i = 1, 3
  w1(:,:,:,i) = 2. * mu * w1(:,:,:,i) + s1
  w2(:,:,:,i) =      mu * w2(:,:,:,i)
end do

end subroutine
end module

