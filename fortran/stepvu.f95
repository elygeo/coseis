!------------------------------------------------------------------------------!
! STEPVU
subroutine stepvu
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
    op = oper(iz)
    i1 = opi1(iz,:)
    i2 = opi2(iz,:)
    if ic == id
      call dfcn( s2, op, w1, x, dx, ic, id, i1, i2 )
    else
      call dfcn( s2, op, w2, x, dx, ix, id, i1, i2 )
    end if
  end do
  i1 = halo + 1
  i2 = halo + np
  do i = 1, npml
    if ( id == 1 .and. bc(1) ) then
      j = i1(1) + i - 1
      forall( k=i1(2):i2(2), l=i1(3):i2(3) )
        s2(j,k,l,1) = dn2(i) * s2(j,k,l,1) + dn1(i) * p1(i,k,l,ic)
        p1(i,k,l,ic) = p1(i,k,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if ( id == 1 .and. bc(4) ) then
      j = i2(1) - i + 1
      forall( k=i1(2):i2(2), l=i1(3):i2(3) )
        s2(j,k,l,1) = dn2(i) * s2(j,k,l,1) + dn1(i) * p4(i,k,l,ic)
        p4(i,k,l,ic) = p4(i,k,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if ( id == 2 .and. bc(2) ) then
      k = i1(2) + i - 1
      forall( j=i1(1):i2(1), l=i1(3):i2(3) )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p2(j,i,l,ic)
        p2(j,i,l,ic) = p2(j,i,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if ( id == 2 .and. bc(5) ) then
      k = i2(2) - i + 1
      forall( j=i1(1):i2(1), l=i1(3):i2(3) )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p5(j,i,l,ic)
        p5(j,i,l,ic) = p5(j,i,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if ( id == 3 .and. bc(3) ) then
      l = i1(3) + i - 1
      forall( j=i1(1):i2(1), k=i1(2):i2(2) )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p3(j,k,i,ic)
        p3(j,k,i,ic) = p3(j,k,i,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if ( id == 3 .and. bc(6) ) then
      l = i2(3) - i + 1
      forall( j=i1(1):i2(1), k=i1(2):i2(2) )
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
i1 = halo + (/ 1, 1, 1 /)
i2 = halo + np
s1 = 0.
s2 = 0.
w2 = u + gamma(2) * v
do ic = 1, 3
do iq = 1, 4
  call hgnc( s1, w2, ic, iq, i1, i2 - 1 )
  s1 = yc * s1
  call hgcn( s2, s1, 1, iq, i1, i2 )
  s2 = yn * s2
  w1(:,:,:,ic) = w1(:,:,:,ic) - s2
end do
end do

! Fault calculations
if ( nrmdim /= 0 ) call fault( 1 )

! Velocity, V = V + dV
!do iz = 1, size( locknodes, 1 )
!  i1 = locki(1,:,iz)
!  i2 = locki(2,:,iz)
!  i = locknodes(iz,1:3) == 1
!  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) ) w1(j,k,l,i) = 0
!end do

v = v + w1
u = u + dt * v

end subroutine

