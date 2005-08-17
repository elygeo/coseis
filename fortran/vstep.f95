!------------------------------------------------------------------------------!
! VSTEP
subroutine vstep
use globals
implicit none
integer i, j, k, l, i1(3), i2(3), ic, iid, id, ix, iz
character op

! Restoring force
! P' + DP = [del]S, F = 1.P'             PML region
! F = divS                               non PML region (D=0)
s2 = 0.
outer: do ic  = 1, 3
inner: do iid = 1, 3
  id = mod( ic + iid - 1, 3 ) + 1
  ix = 6 - ic - id
  do iz = 1, size( oper, 1 )
    call zoneselect( i1, i2, operi(iz,:), npg, offset, hypocenter )
    i1 = max( i1, i1node )
    i2 = min( i2, i2node )
    if ( ic == id )
      call dfcn( s2, oper(iz), w1, x, dx, ic, id, i1, i2 )
    else
      call dfcn( s2, oper(iz), w2, x, dx, ix, id, i1, i2 )
    end if
  end do
  j1 = i1node(1); j2 = i2node(1)
  k1 = i1node(2); k2 = i2node(2)
  l1 = i1node(3); l2 = i2node(3)
  do i = 1, npml
    if ( id == 1 .and. bc(1) ) then
      j = j1 + i - 1
      forall( k=k1:k2, l=l1:l2 )
        s2(j,k,l,1) = dn2(i) * s2(j,k,l,1) + dn1(i) * p1(i,k,l,ic)
        p1(i,k,l,ic) = p1(i,k,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if ( id == 1 .and. bc(4) ) then
      j = j2 - i + 1
      forall( k=k1:k2, l=l1:l2 )
        s2(j,k,l,1) = dn2(i) * s2(j,k,l,1) + dn1(i) * p4(i,k,l,ic)
        p4(i,k,l,ic) = p4(i,k,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if ( id == 2 .and. bc(2) ) then
      k = k1 + i - 1
      forall( j=j1:j2, l=l1:l2 )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p2(j,i,l,ic)
        p2(j,i,l,ic) = p2(j,i,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if ( id == 2 .and. bc(5) ) then
      k = k2 - i + 1
      forall( j=j1:j2, l=l1:l2 )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p5(j,i,l,ic)
        p5(j,i,l,ic) = p5(j,i,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if ( id == 3 .and. bc(3) ) then
      l = l1 + i - 1
      forall( j=j1:j2, k=k1:k2 )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p3(j,k,i,ic)
        p3(j,k,i,ic) = p3(j,k,i,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if ( id == 3 .and. bc(6) ) then
      l = l2 - i + 1
      forall( j=j1:j2, k=k1:k2 )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p6(j,k,i,ic)
        p6(j,k,i,ic) = p6(j,k,i,ic) + dt * s2(j,k,l,1)
      end forall
    end if
  end do
  if ( ic == id ) then
    w1(:,:,:,ic) = s2
  else
    w1(:,:,:,ic) = w1(:,:,:,ic) + s2
  end if
end do inner
end do outer

! Newton's Law, dV = F / m * dt
do i = 1, 3
  w1(:,:,:,i) = w1(:,:,:,i) * rho
end do

! Hourglass correction
s1 = 0.
s2 = 0.
w2 = u + gamma(2) * v
do ic = 1, 3
do iq = 1, 4
  call hgnc( s1, w2, ic, iq, i1cell, i2cell )
  s1 = yc * s1
  call hgcn( s2, s1,  1, iq, i1node, i2node )
  s2 = yn * s2
  w1(:,:,:,ic) = w1(:,:,:,ic) - s2
end do
end do

! Fault calculations
if ( nrmdim /= 0 ) call fault( 1 )

! Velocity, V = V + dV
!do iz = 1, size( locknodes, 1 )
!  j1 = locki(1,1,iz); j2 = locki(2,1,iz)
!  k1 = locki(1,2,iz); k2 = locki(2,2,iz)
!  l1 = locki(1,3,iz); l2 = locki(2,3,iz)
!  i = locknodes(iz,1:3) == 1
!  forall( j=j1:j2, k=k1:k2, l=ll1:l2 ) w1(j,k,l,i) = 0
!end do

v = v + w1
u = u + dt * v

end subroutine

