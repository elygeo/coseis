!------------------------------------------------------------------------------!
! VSTEP

subroutine vstep
use globals
use dfcn_mod
use hgnc_mod
use hgcn_mod
use utils

implicit none
integer ic, iid, id, ix, iq, iz

! Restoring force
! P' + DP = [del]S, F = 1.P'             PML region
! F = divS                               non PML region (D=0)
if ( verb > 1 ) print '(a)', 'Vstep'
s2 = 0.
outer: do ic  = 1, 3
print *, ic
inner: do iid = 1, 3
  id = mod( ic + iid - 2, 3 ) + 1
  ix = 6 - ic - id
  do iz = 1, noper
    call zoneselect( i1, i2, ioper(iz,:), npg, hypocenter, nrmdim )
    i1 = max( i1, i1node )
    i2 = min( i2, i2node )
    call dfcn( s2, oper(iz), w2, x, dx, 1, 1, i1, i2 ); print *, 1
    call dfcn( s2, oper(iz), w2, x, dx, 1, 2, i1, i2 ); print *, 2
    call dfcn( s2, oper(iz), w2, x, dx, 1, 3, i1, i2 ); print *, 3
    call dfcn( s2, oper(iz), w2, x, dx, 2, 1, i1, i2 ); print *, 4
    call dfcn( s2, oper(iz), w2, x, dx, 2, 2, i1, i2 ); print *, 5
    call dfcn( s2, oper(iz), w2, x, dx, 2, 3, i1, i2 ); print *, 6
    call dfcn( s2, oper(iz), w2, x, dx, 3, 1, i1, i2 ); print *, 7
    call dfcn( s2, oper(iz), w2, x, dx, 3, 2, i1, i2 ); print *, 8
    call dfcn( s2, oper(iz), w2, x, dx, 3, 3, i1, i2 ); print *, 9
    if ( ic == id ) then
print *, ic, id
      call dfcn( s2, oper(iz), w1, x, dx, ic, id, i1, i2 )
    else
print *, ix, id, 'die'
      call dfcn( s2, oper(iz), w2, x, dx, ix, id, i1, i2 )
    end if
  end do
  i1 = i1node
  i2 = i2node
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  do i = 1, npml
    if ( id == 1 .and. bc(1) == 1 ) then
      j = j1 + i - 1
      forall( k=k1:k2, l=l1:l2 )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p1(i,k,l,ic)
        p1(i,k,l,ic) = p1(i,k,l,ic) + dt * s2(j,k,l)
      end forall
    end if
    if ( id == 1 .and. bc(4) == 1 ) then
      j = j2 - i + 1
      forall( k=k1:k2, l=l1:l2 )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p4(i,k,l,ic)
        p4(i,k,l,ic) = p4(i,k,l,ic) + dt * s2(j,k,l)
      end forall
    end if
    if ( id == 2 .and. bc(2) == 1 ) then
      k = k1 + i - 1
      forall( j=j1:j2, l=l1:l2 )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p2(j,i,l,ic)
        p2(j,i,l,ic) = p2(j,i,l,ic) + dt * s2(j,k,l)
      end forall
    end if
    if ( id == 2 .and. bc(5) == 1 ) then
      k = k2 - i + 1
      forall( j=j1:j2, l=l1:l2 )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p5(j,i,l,ic)
        p5(j,i,l,ic) = p5(j,i,l,ic) + dt * s2(j,k,l)
      end forall
    end if
    if ( id == 3 .and. bc(3) == 1 ) then
      l = l1 + i - 1
      forall( j=j1:j2, k=k1:k2 )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p3(j,k,i,ic)
        p3(j,k,i,ic) = p3(j,k,i,ic) + dt * s2(j,k,l)
      end forall
    end if
    if ( id == 3 .and. bc(6) == 1 ) then
      l = l2 - i + 1
      forall( j=j1:j2, k=k1:k2 )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p6(j,k,i,ic)
        p6(j,k,i,ic) = p6(j,k,i,ic) + dt * s2(j,k,l)
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
w2 = u + gam(2) * v
do ic = 1, 3
do iq = 1, 4
  call hgnc( s1, w2, ic, iq, i1cell, i2cell ); s1 = yc * s1
  call hgcn( s2, s1,  1, iq, i1node, i2node ); s2 = yn * s2
  w1(:,:,:,ic) = w1(:,:,:,ic) - s2
end do
end do

! Fault calculations
call fault

! Velocity, V = V + dV
do iz = 1, nlock
  call zoneselect( i1, i2, ilock(iz,:), npg, hypocenter, nrmdim )
  i1 = max( i1, i1node )
  i2 = min( i2, i2node )
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  i1 = locknodes(iz,:)
  do i = 1, 3
    if ( i1(i) == 1 ) forall( j=j1:j2, k=k1:k2, l=l1:l2 ) w1(j,k,l,i) = 0.
  end do
end do

v = v + w1

end subroutine

!------------------------------------------------------------------------------!
! USTEP

subroutine ustep

use globals
implicit none

u = u + dt * v

end subroutine

