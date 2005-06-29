!==============================================================================!
! SORD
!------------------------------------------------------------------------------!

integer n(3), 
real h, dt
program main

! STEPV

! Restoring force
! P' + DP = [del]S, F = 1.P'             PML region
! F = divS                               non PML region (D=0)
s2 = 0
do ic = 1, 3
do iid = 1, 3
  id = mod( ic + iid - 1, 3 ) + 1
  ix = 6 - ic - id
  do iz = 1, size( oper, 1 )
    op = oper(iz)
    i1 = opi1(iz,:)
    i2 = opi2(iz,:)
    if ic == id
      call dfcn( s2, op, w1, x, h, ic, id, i1, i2 )
    else
      call dfcn( s2, op, w2, x, h, ix, id, i1, i2 )
    end if
  end do
  i1 = halo1 + 1
  i2 = halo1 + ncore
  do i = 1, npml
    if id == 1 .and. bc(1)
      j = i1(1) + i - 1
      forall( k=i1(2):i2(2), l=i1(3):i2(3) )
        s2(j,k,l,1) = dn2(i) * s2(j,k,l,1) + dn1(i) * p1(i,k,l,ic)
        p1(i,k,l,ic) = p1(i,k,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if id == 1 .and. bc(4)
      j = i2(1) - i + 1
      forall( k=i1(2):i2(2), l=i1(3):i2(3) )
        s2(j,k,l,1) = dn2(i) * s2(j,k,l,1) + dn1(i) * p4(i,k,l,ic)
        p4(i,k,l,ic) = p4(i,k,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if id == 2 .and. bc(2)
      k = i1(2) + i - 1
      forall( j=i1(1):i2(1), l=i1(3):i2(3) )
        s2(j,k,l,1) = dn2(i) * s2(j,k,l,1) + dn1(i) * p2(j,i,l,ic)
        p2(j,i,l,ic) = p2(j,i,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if id == 2 .and. bc(5)
      k = i2(2) - i + 1
      forall( j=i1(1):i2(1), l=i1(3):i2(3) )
        s2(j,k,l,1) = dn2(i) * s2(j,k,l,1) + dn1(i) * p5(j,i,l,ic)
        p5(j,i,l,ic) = p5(j,i,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if id == 3 .and. bc(3)
      l = i1(3) + i - 1
      forall( j=i1(1):i2(1), k=i1(2):i2(2) )
        s2(j,k,l,1) = dn2(i) * s2(j,k,l,1) + dn1(i) * p3(j,k,i,ic)
        p3(j,k,i,ic) = p3(j,k,i,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if id == 3 .and. bc(6)
      l = i2(3) - i + 1
      forall( j=i1(1):i2(1), k=i1(2):i2(2) )
        s2(j,k,l,1) = dn2(i) * s2(j,k,l,1) + dn1(i) * p6(j,k,i,ic)
        p6(j,k,i,ic) = p6(j,k,i,ic) + dt * s2(j,k,l,1)
      end forall
    end if
  end do
  if ic == id
    w1(:,:,:,ic) = s2
  else
    w1(:,:,:,ic) = w1(:,:,:,ic) + s2
  end if
end do
end do

! Newton's Law, dV = F / m * dt
forall( i=1:3 ) w1(:,:,:,i) = w1(:,:,:,i) * rho

! Hourglass correction
i1 = halo1 + 1
i2 = halo1 + ncore
s1 = 0
s2 = 0
w2 = u + gamma(2) * v
do ic = 1, 3
do iq = 1, 4
  hgnc( s1, w2, ic, iq, i1, i2 - 1 )
  s1 = yc * s1
  hgcn( s2, s1, 1, iq, i1, i2 )
  s2 = yn * s2
  w1(:,:,:,ic) = w1(:,:,:,ic) - s2
end do
end do

! Fault calculations
! if nrmdim, fault, end

! Velocity, V = V + dV
!do iz = 1, size( locknodes, 1 )
!  i1 = locki(1,:,iz)
!  i2 = locki(2,:,iz)
!  i = locknodes(iz,1:3) == 1
!  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) ) w1(j,k,l,i) = 0
!end do
v = v + w1

! if planewavedim, planewave, end

! STEPW

! Gadient
! G = grad(U + gamma*V)    non PML region
! G' + DG = gradV          PML region
s2 = 0
w2 = 0
do ic = 1, 3
s1 = u(:,:,:,ic) + gamma(1) .* v(:,:,:,ic)
do id = 1, 3
  ix = 6 - ic - id
  do iz = 1, size( oper, 1 )
    op = oper(iz)
    i1 = opi1(iz,:)
    i2 = opi2(iz,:) - 1
    i1 = max( i1, i1pml )
    i2 = min( i2, i2pml - 1 )
    call dfnc( s2, op, s1, x, h, 1, id, i1, i2 )
  end do
  op = operator(1)
  do i = 1, npml
    if id /= 1 .and. bc(1)
      i1 = halo1 + 1
      i2 = halo1 + ncore - 1
      j = i1(1) + i - 1
      i1(1) = j
      i2(1) = j
      call dfnc( s2, op, u, x, h, ic, id, i1, i2 )
    end if
    if id /= 1 .and. bc(4)
      i1 = halo1 + 1
      i2 = halo1 + ncore - 1
      j = i2(1) - i + 1
      i1(1) = j
      i2(1) = j
      call dfnc( s2, op, u, x, h, ic, id, i1, i2 )
    end if
    if id /= 2 .and. bc(2)
      i1 = halo1 + 1
      i2 = halo1 + ncore - 1
      k = i1(2) + i - 1
      i1(2) = k
      i2(2) = k
      call dfnc( s2, op, u, x, h, ic, id, i1, i2 )
    end if
    if id /= 2 .and. bc(5)
      i1 = halo1 + 1
      i2 = halo1 + ncore - 1
      k = i2(2) - i + 1
      i1(2) = k
      i2(2) = k
      call dfnc( s2, op, u, x, h, ic, id, i1, i2 )
    end if
    if id /= 3 .and. bc(3)
      i1 = halo1 + 1
      i2 = halo1 + ncore - 1
      l = i1(3) + i - 1
      i1(3) = l
      i2(3) = l
      call dfnc( s2, op, u, x, h, ic, id, i1, i2 )
    end if
    if id /= 3 .and. bc(6)
      i1 = halo1 + 1
      i2 = halo1 + ncore - 1
      l = i2(3) - i + 1
      i1(3) = l
      i2(3) = l
      call dfnc( s2, op, u, x, h, ic, id, i1, i2 )
    end if
  end do
  do i = 1, npml
    if id == 1 .and. bc(1)
      i1 = halo1 + 1
      i2 = halo1 + ncore - 1
      j = i1(1) + i - 1
      i1(1) = j
      i2(1) = j
      call dfnc( s2, op, v, x, h, ic, id, i1, i2 )
      forall( k=i1(2):i2(2), l=i1(3):i2(3) )
        s2(j,k,l,1) = dc2(i) * s2(j,k,l,1) + dc1(i) * g1(i,k,l,ic)
        g1(i,k,l,ic) = s2(j,k,l,1)
      end forall
    end if
    if id == 1 .and. bc(4)
      i1 = halo1 + 1
      i2 = halo1 + ncore - 1
      j = i2(1) - i + 1
      i1(1) = j
      i2(1) = j
      call dfnc( s2, op, v, x, h, ic, id, i1, i2 )
      forall( k=i1(2):i2(2), l=i1(3):i2(3) )
        s2(j,k,l,1) = dc2(i) * s2(j,k,l,1) + dc1(i) * g4(i,k,l,ic)
        g4(i,k,l,ic) = s2(j,k,l,1)
      end forall
    end if
    if id == 2 .and. bc(2)
      i1 = halo1 + 1
      i2 = halo1 + ncore - 1
      k = i1(2) + i - 1
      i1(2) = k
      i2(2) = k
      call dfnc( s2, op, v, x, h, ic, id, i1, i2 )
      forall( j=i1(1):i2(1), l=i1(3):i2(3) )
        s2(j,k,l,1) = dc2(i) * s2(j,k,l,1) + dc1(i) * g2(j,i,l,ic)
        g2(j,i,l,ic) = s2(j,k,l,1)
      end forall
    end if
    if id == 2 .and. bc(5)
      i1 = halo1 + 1
      i2 = halo1 + ncore - 1
      k = i2(2) - i + 1
      i1(2) = k
      i2(2) = k
      call dfnc( s2, op, v, x, h, ic, id, i1, i2 )
      forall( j=i1(1):i2(1), l=i1(3):i2(3) )
        s2(j,k,l,1) = dc2(i) * s2(j,k,l,1) + dc1(i) * g5(j,i,l,ic)
        g5(j,i,l,ic) = s2(j,k,l,1)
      end forall
    end if
    if id == 3 .and. bc(3)
      i1 = halo1 + 1
      i2 = halo1 + ncore - 1
      l = i1(3) + i - 1
      i1(3) = l
      i2(3) = l
      call dfnc( s2, op, v, x, h, ic, id, i1, i2 )
      forall( j=i1(1):i2(1), k=i1(2):i2(2) )
        s2(j,k,l,1) = dc2(i) * s2(j,k,l,1) + dc1(i) * g3(j,k,i,ic)
        g3(j,k,i,ic) = s2(j,k,l,1)
      end forall
    end if
    if id == 3 .and. bc(6)
      i1 = halo1 + 1
      i2 = halo1 + ncore - 1
      l = i2(3) - i + 1
      i1(3) = l
      i2(3) = l
      call dfnc( s2, op, v, x, h, ic, id, i1, i2 )
      forall( j=i1(1):i2(1), k=i1(2):i2(2) )
        s2(j,k,l,1) = dc2(i) * s2(j,k,l,1) + dc1(i) * g6(j,k,i,ic)
        g6(j,k,i,ic) = s2(j,k,l,1)
      end forall
    end if
  end do
  if ic == id
    w1(:,:,:,ic) = s2
  else
    w2(:,:,:,ix) = w2(:,:,:,ix) + s2
  end if
end do
end do

! Hook's Law, linear stress/strain relation
! W = lam*trace(G)*I + miu*(G + G^T)
s1 = lam .* sum( w1, 4 )
forall( i = 1:3 ) w1(:,:,:,i) = 2 * miu .* w1(:,:,:,i) + s1
forall( i = 1:3 ) w2(:,:,:,i) =     miu .* w2(:,:,:,i)

! Moment source
!if msrcradius, momentsrc, end

