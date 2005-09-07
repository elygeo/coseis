!------------------------------------------------------------------------------!
! VSTEP

module vstep_m
contains
subroutine vstep
use globals_m
use dfcn_m
use hgnc_m
use hgcn_m
use zone_m
use fault_m

implicit none
integer ic, iid, id, ix, iq, iz

! Restoring force
! P' + DP = [del]S, F = 1.P'             PML region
! F = divS                               non PML region (D=0)
s2 = 0.
outer: do ic  = 1, 3
inner: do iid = 1, 3
  id = mod( ic + iid - 2, 3 ) + 1
  ix = 6 - ic - id
  do iz = 1, noper
    call zone( i1, i2, ioper(iz,:), nn, offset, hypocenter, nrmdim )
    i1 = max( i1, i1node )
    i2 = min( i2, i2node )
    if ( ic == id ) then
      call dfcn( s2, oper(iz), w1, x, dx, ic, id, i1, i2 )
    else
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

! Hourglass correction
s1 = 0.
s2 = 0.
w2 = u + dt * viscosity(2) * v
do ic = 1, 3
do iq = 1, 4
  call hgnc( s1, w2, ic, iq, i1cell, i2cell )
  s1 = y * s1
  call hgcn( s2, s1,  1, iq, i1node, i2node )
  w1(:,:,:,ic) = w1(:,:,:,ic) - s2
end do
end do

! Newton's Law, A = F / m
do i = 1, 3
  w1(:,:,:,i) = w1(:,:,:,i) * rho
end do

! Fault calculations
call fault

! Locked nodes
do iz = 1, nlock
  call zone( i1, i2, ilock(iz,:), nn, offset, hypocenter, nrmdim )
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

! Velocity, V = V + dt * A
v = v + dt * w1

! Magnitudes
s1 = sqrt( sum( w1 * w1, 4 ) ) / dt
s2 = sqrt( sum( v * v, 4 ) )
iamax = maxloc( s1 ); amax = s1(iamax(1),iamax(2),iamax(3))
ivmax = maxloc( s2 ); vmax = s2(ivmax(1),ivmax(2),ivmax(3))
vslipmax = maxval( abs( vslip ) )

end subroutine
end module

