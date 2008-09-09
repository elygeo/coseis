! Stress calculation
module m_stress
implicit none
contains

subroutine stress
use m_globals
use m_diffnc
use m_util
integer :: i1(3), i2(3), i, j, k, l, ic, iid, id

if ( master .and. debug == 2 ) write( 0, * ) 'Stress'

! Modified displacement
do i = 1, 3
  w1(:,:,:,i) = uu(:,:,:,i) + gam * vv(:,:,:,i)
end do
call scalar_set_halo( s1, 0., i1cell, i2cell )

! Loop over component and derivative direction
doic: do ic  = 1, 3
doid: do iid = 1, 3; id = modulo( ic + iid - 1, 3 ) + 1

! Elastic region: g_ij = (u_i + gamma*v_i),j
i1 = max( i1pml + 1, i1cell )
i2 = min( i2pml - 2, i2cell )
call diffnc( s1, w1, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx )

! PML region, non-damped directions: g_ij = u_i,j
do i = 1, 3
if ( id /= i ) then
  i1 = i1cell
  i2 = i2cell
  i2(i) = min( i2(i), i1pml(i) )
  call diffnc( s1, uu, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx )
  i1 = i1cell
  i2 = i2cell
  i1(i) = max( i1(i), i2pml(i) - 1 )
  call diffnc( s1, uu, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx )
end if
end do

! PML region, damped direction: g'_ij = d_j*g_ij = v_i,j
select case( id )
case( 1 )
  i1 = i1cell
  i2 = i2cell
  i2(1) = min( i2(1), i1pml(1) )
  call diffnc( s1, vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx )
  do j = i1(1), i2(1)
  i = j + nnoff(1)
  do l = i1(3), i2(3)
  do k = i1(2), i2(2)
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g1(i,k,l,ic)
    g1(i,k,l,ic) = s1(j,k,l)
  end do
  end do
  end do
  i1 = i1cell
  i2 = i2cell
  i1(1) = max( i1(1), i2pml(1) - 1 )
  call diffnc( s1, vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx )
  do j = i1(1), i2(1)
  i = nn(1) - j - nnoff(1)
  do l = i1(3), i2(3)
  do k = i1(2), i2(2)
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g4(i,k,l,ic)
    g4(i,k,l,ic) = s1(j,k,l)
  end do
  end do
  end do
case( 2 )
  i1 = i1cell
  i2 = i2cell
  i2(2) = min( i2(2), i1pml(2) )
  call diffnc( s1, vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx )
  do k = i1(2), i2(2)
  i = k + nnoff(2)
  do l = i1(3), i2(3)
  do j = i1(1), i2(1)
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g2(j,i,l,ic)
    g2(j,i,l,ic) = s1(j,k,l)
  end do
  end do
  end do
  i1 = i1cell
  i2 = i2cell
  i1(2) = max( i1(2), i2pml(2) - 1 )
  call diffnc( s1, vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx )
  do k = i1(2), i2(2)
  i = nn(2) - k - nnoff(2)
  do l = i1(3), i2(3)
  do j = i1(1), i2(1)
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g5(j,i,l,ic)
    g5(j,i,l,ic) = s1(j,k,l)
  end do
  end do
  end do
case( 3 )
  i1 = i1cell
  i2 = i2cell
  i2(3) = min( i2(3), i1pml(3) )
  call diffnc( s1, vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx )
  do l = i1(3), i2(3)
  i = l + nnoff(3)
  do k = i1(2), i2(2)
  do j = i1(1), i2(1)
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g3(j,k,i,ic)
    g3(j,k,i,ic) = s1(j,k,l)
  end do
  end do
  end do
  i1 = i1cell
  i2 = i2cell
  i1(3) = max( i1(3), i2pml(3) - 1 )
  call diffnc( s1, vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx )
  do l = i1(3), i2(3)
  i = nn(3) - l - nnoff(3)
  do k = i1(2), i2(2)
  do j = i1(1), i2(1)
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g6(j,k,i,ic)
    g6(j,k,i,ic) = s1(j,k,l)
  end do
  end do
  end do
end select

! Add contribution to gradient
if ( ic < id ) then
  i = 6 - ic - id
  w2(:,:,:,i) = s1
elseif ( ic > id ) then
  i = 6 - ic - id
  w2(:,:,:,i) = w2(:,:,:,i) + s1
else
  w1(:,:,:,ic) = s1
end if

end do doid
end do doic

! Strain I/O
p => iolist0
do while( associated( p%next ) )
  p => p%next
  select case( p%field )
  case( 'exx' ); call rio4( 'in', p, .false., w1(:,:,:1) )
  case( 'eyy' ); call rio4( 'in', p, .false., w1(:,:,:2) )
  case( 'ezz' ); call rio4( 'in', p, .false., w1(:,:,:3) )
  case( 'eyz' ); call rio4( 'in', p, .false., w2(:,:,:1) )
  case( 'ezx' ); call rio4( 'in', p, .false., w2(:,:,:2) )
  case( 'exy' ); call rio4( 'in', p, .false., w2(:,:,:3) )
end do
p => iolist0
do while( associated( p%next ) )
  p => p%next
  select case( p%field )
  case( 'exx' ); call rio4( 'out', p, .false., w1(:,:,:1) )
  case( 'eyy' ); call rio4( 'out', p, .false., w1(:,:,:2) )
  case( 'ezz' ); call rio4( 'out', p, .false., w1(:,:,:3) )
  case( 'eyz' ); call rio4( 'out', p, .false., w2(:,:,:1) )
  case( 'ezx' ); call rio4( 'out', p, .false., w2(:,:,:2) )
  case( 'exy' ); call rio4( 'out', p, .false., w2(:,:,:3) )
end do

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

! Sress I/O
p => iolist0
do while( associated( p%next ) )
  p => p%next
  select case( p%field )
  case( 'wxx' ); call rio4( 'in', p, .false., w1(:,:,:1) )
  case( 'wyy' ); call rio4( 'in', p, .false., w1(:,:,:2) )
  case( 'wzz' ); call rio4( 'in', p, .false., w1(:,:,:3) )
  case( 'wyz' ); call rio4( 'in', p, .false., w2(:,:,:1) )
  case( 'wzx' ); call rio4( 'in', p, .false., w2(:,:,:2) )
  case( 'wxy' ); call rio4( 'in', p, .false., w2(:,:,:3) )
end do
p => inp0
do while( associated( p%next ) )
  p => p%next
  select case( p%field )
  case( 'wxx' ); call rio4( 'out', p, .false., w1(:,:,:1) )
  case( 'wyy' ); call rio4( 'out', p, .false., w1(:,:,:2) )
  case( 'wzz' ); call rio4( 'out', p, .false., w1(:,:,:3) )
  case( 'wyz' ); call rio4( 'out', p, .false., w2(:,:,:1) )
  case( 'wzx' ); call rio4( 'out', p, .false., w2(:,:,:2) )
  case( 'wxy' ); call rio4( 'out', p, .false., w2(:,:,:3) )
end do

end subroutine

end module

