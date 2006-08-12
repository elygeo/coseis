! Stress calculation
module m_stress
implicit none
contains

subroutine stress
use m_globals
use m_diffnc
use m_tictoc
integer :: i1(3), i2(3), i, j, k, l, ic, iid, id, iz

if ( master ) call toc( 'Stress' )

! Modified displacement
w1 = u + dt * v * viscosity(1)
w2 = 0.
s1 = 0.

! Loop over component and derivative direction
doic: do ic  = 1, 3
doid: do iid = 1, 3; id = modulo( ic + iid - 1, 3 ) + 1

! Elastic region: g_ij = (u_i + gamma*v_i),j
do iz = 1, noper
  i1 = max( max( i1oper(iz,:), i1pml + 1 ),     i1cell )
  i2 = min( min( i2oper(iz,:), i2pml - 1 ) - 1, i2cell )
  call diffnc( s1, oper(iz), w1, x, dx, ic, id, i1, i2 )
end do

! PML region, non-damped directions: g_ij = u_i,j
if ( id /= 1 ) then
  i1 = i1cell
  i2 = i2cell
  i2(1) = min( i2(1), i1pml(1) )
  call diffnc( s1, oper(1), u, x, dx, ic, id, i1, i2 )
  i1 = i1cell
  i2 = i2cell
  i1(1) = max( i1(1), i2pml(1) - 1 )
  call diffnc( s1, oper(1), u, x, dx, ic, id, i1, i2 )
end if
if ( id /= 2 ) then
  i1 = i1cell
  i2 = i2cell
  i2(2) = min( i2(2), i1pml(2) )
  call diffnc( s1, oper(1), u, x, dx, ic, id, i1, i2 )
  i1 = i1cell
  i2 = i2cell
  i1(2) = max( i1(2), i2pml(2) - 1 )
  call diffnc( s1, oper(1), u, x, dx, ic, id, i1, i2 )
end if
if ( id /= 3 ) then
  i1 = i1cell
  i2 = i2cell
  i2(3) = min( i2(3), i1pml(3) )
  call diffnc( s1, oper(1), u, x, dx, ic, id, i1, i2 )
  i1 = i1cell
  i2 = i2cell
  i1(3) = max( i1(3), i2pml(3) - 1 )
  call diffnc( s1, oper(1), u, x, dx, ic, id, i1, i2 )
end if

! PML region, damped direction: g_ij' = d_j*g_ij = v_i,j
select case( id )
case( 1 )
  i1 = i1cell
  i2 = i2cell
  i2(1) = min( i2(1), i1pml(1) )
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
  i1(1) = max( i1(1), i2pml(1) - 1 )
  call diffnc( s1, oper(1), v, x, dx, ic, id, i1, i2 )
  do j = i1(1), i2(1)
  i = nn(1) - j + nnoff(1)
  forall( k=i1(2):i2(2), l=i1(3):i2(3) )
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g4(i,k,l,ic)
    g4(i,k,l,ic) = s1(j,k,l)
  end forall
  end do
case( 2 )
  i1 = i1cell
  i2 = i2cell
  i2(2) = min( i2(2), i1pml(2) )
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
  i1(2) = max( i1(2), i2pml(2) - 1 )
  call diffnc( s1, oper(1), v, x, dx, ic, id, i1, i2 )
  do k = i1(2), i2(2)
  i = nn(2) - k + nnoff(2)
  forall( j=i1(1):i2(1), l=i1(3):i2(3) )
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g5(j,i,l,ic)
    g5(j,i,l,ic) = s1(j,k,l)
  end forall
  end do
case( 3 )
  i1 = i1cell
  i2 = i2cell
  i2(3) = min( i2(3), i1pml(3) )
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
  i1(3) = max( i1(3), i2pml(3) - 1 )
  call diffnc( s1, oper(1), v, x, dx, ic, id, i1, i2 )
  do l = i1(3), i2(3)
  i = nn(3) - l + nnoff(3)
  forall( j=i1(1):i2(1), k=i1(2):i2(2) )
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g6(j,k,i,ic)
    g6(j,k,i,ic) = s1(j,k,l)
  end forall
  end do
end select

! Add contribution to gradient
if ( ic == id ) then
  w1(:,:,:,ic) = s1
else
  i = 6 - ic - id
  w2(:,:,:,i) = w2(:,:,:,i) + s1
end if

end do doid
end do doic

! Attenuation
!do j = 1, 2
!do k = 1, 2
!do l = 1, 2
!  i = j + 2 * ( k - 1 ) + 4 * ( l - 1 )
!  z1(j::2,k::2,l::2,:) = c1(i) * z1(j::2,k::2,l::2,:) + c2(i) * w1(j::2,k::2,l::2,:)
!  z2(j::2,k::2,l::2,:) = c1(i) * z2(j::2,k::2,l::2,:) + c2(i) * w2(j::2,k::2,l::2,:)
!end do
!end do
!end do

! Hook's Law: w_ij = lam*g_ij*delta_ij + mu*(g_ij + g_ji)
s1 = lam * sum( w1, 4 )
do i = 1, 3
  w1(:,:,:,i) = 2. * mu * w1(:,:,:,i) + s1
  w2(:,:,:,i) =      mu * w2(:,:,:,i)
end do

end subroutine

end module

