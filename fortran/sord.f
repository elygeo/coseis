!==============================================================================!
! SORD
!------------------------------------------------------------------------------!

program main

implicit none
real dt, dx
real, allocatable :: dn1, dn2
real, allocatable, dimension(:,:,:,:) :: x, u, v, w1, w2, s1, s2, &
  rho, lam, miu, yc, yn, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
integer n(3), halo, np(3), npml, bc(6), nop
integer, allocatable :: opi1(:,:), opi2(:,:) 
character, allocatable :: oper

np = (/ 41 41 41 /)
nt = 100
dx = 100
dt = .007
halo = 1
npe = (/ 1 1 1 /)

open( 9, file='inputs' status='old' )
do
  read( 9,'(a)', end=10 ) buff
  read( buff, * ) key
  selectcase( key )
  case( 'parallel' )
    read( buff, * ) a, npe
  case( 'n' )
    read( buff, * ) a, n
  case( 'bc' )
    read( buff ) a, bc
  case( 'out' )
    nout = nout + 1
  case( 'nrmdim' )
  end select
end do
10 continue
close( 9 )

halo = 1
np = n(1:3)
nt = n(4)
if( nrmdim /= 0 ) np(nrmdim) = np(nrmdim) + 1
nl = ceiling( np / npe )
n = nl + 2 * halo
j = n(1)
k = n(2)
l = n(3)
allocate( x(j,k,l,3), u(j,k,l,3), v(j,k,l,3), w1(j,k,l,3), w2(j,k,l,3), &
          s1(j,k,l), s2(j,k,l), rho(j,k,l), lam(j,k,l), miu(j,k,l), &
          yc(j,k,l), yn(j,k,l) )
if( nrmdim /= 0 ) then
  n = nl + 2 * halo
  n(nrmdim) = 1
  j = n(1)
  k = n(2)
  l = n(3)
  allocate( fs(j,k,l), fd(j,k,l), dc(j,k,l), cohes(j,k,l), &
            s0(j,k,l,6), t0nsd(j,k,l,3) )
  fs(:,:,:) = 0
  fd(:,:,:) = 0
  dc(:,:,:) = 0
  cohes(:,:,:) = 1e9
  s0(:,:,:,6) = 0
  t0nsd(:,:,:,3) = 0
end if
  

open( 9, file='inputs' status='old' )
do
  read( 9,'(a)', end=10 ) buff
  if ( buff .eq. ' ' ) cycle
  read( buff, * ) key
  if ( key(1:1) .eq. '#' .or. key(1:1) .eq. '!' .or. key(1:1) .eq. '%' ) cycle
 
  selectcase( key )
  case( 'parallel' )
  case( 'n' )
  case( 'dx' )
    read( buff, * ) a, dx
  case( 'dt' )
    read( buff, * ) a, dt
  case( 'hypocenter' )
    read( buff, * ) a, hypocenter
  case( 'material' )
    read( buff, * ) a, rho0, vp, vs, beta0, i1, i2
    call zoneselect( i1, i2, halo, nl, offset, hypocenter )
    miu0 = rho0 * vs * vs
    lam0 = rho0 * ( vp * vp - 2 * vs * vs )
    yc0  = miu0 * ( lam0 + miu0 ) / 6 / ( lam0 + 2 * miu0 ) * 4 / dx ^ 2
    forall( j=i1(1):i2(1)-1, k=i1(2):i2(2)-1, l=i1(3):i2(3)-1 )
      s1(j,k,l)  = rho0
      lam(j,k,l) = lam0
      miu(j,k,l) = miu0
      yc(j,k,l)  = yc0
    end forall
  case( 'friction' )
    read( buff, * ) a, smin0, smax0, d00, t00, cohes0, i1, i2
    call zoneselect( i1, i2, ng, nl, offset, hypocenter )
    forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
      smin(j,k,l)  = smin0
      smax(j,k,l)  = smax0
      t0(j,k,l,1)  = t00(1)
      t0(j,k,l,2)  = t00(2)
      t0(j,k,l,3)  = t00(3)
      d0(j,k,l)    = d00
      cohes(j,k,l) = cohes0
    end forall
  case( 'out' )
    nout = nout + 1
    read( buff, * ) a, outvar(nout), outint(nout), i1, i2
    call zoneselect( i1, i2, ng, nl, offset, hypocenter )
    do i = 1, 3
      outgi1(i,nout) = i1(i)
      outgi2(i,nout) = i2(i)
    end do
  case( 'checkpoint' )
    read( buff, * ) a, checkpoint
  case default
    error( 'unrecognized input type: ' // key )
  end select
end do
20 continue

maxvel = max( maxvel, vp0(1) )
if ( checkpoint .eq. 0 )  checkpoint = ti2 + 1
do i = 1, 3
  mype3d(i) = 0
  core1(i) = 1
  core2(i) = ng(i)
  nl(i) = ng(i)
  offset(i) = 0
end do

if ( nfault .gt. m3s ) error( 'nfault too big' )
if ( min( h(1), h(2), h(3) ) / maxvel .le. h(4) ) error( 'courant condition' )
do i = 1, nfault
  if ( kind0(i) .lt. 0 .or. kind0(i) .gt. 2 ) error( 'kind must be 0, 1 or 2' )
end do

return
end

function error( string )
character*(*) string
write(0,*) 'DFM error: ', string
stop
end


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
      call dfcn( s2, op, w1, x, dx, ic, id, i1, i2 )
    else
      call dfcn( s2, op, w2, x, dx, ix, id, i1, i2 )
    end if
  end do
  i1 = halo + 1
  i2 = halo + np
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
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p2(j,i,l,ic)
        p2(j,i,l,ic) = p2(j,i,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if id == 2 .and. bc(5)
      k = i2(2) - i + 1
      forall( j=i1(1):i2(1), l=i1(3):i2(3) )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p5(j,i,l,ic)
        p5(j,i,l,ic) = p5(j,i,l,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if id == 3 .and. bc(3)
      l = i1(3) + i - 1
      forall( j=i1(1):i2(1), k=i1(2):i2(2) )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p3(j,k,i,ic)
        p3(j,k,i,ic) = p3(j,k,i,ic) + dt * s2(j,k,l,1)
      end forall
    end if
    if id == 3 .and. bc(6)
      l = i2(3) - i + 1
      forall( j=i1(1):i2(1), k=i1(2):i2(2) )
        s2(j,k,l) = dn2(i) * s2(j,k,l) + dn1(i) * p6(j,k,i,ic)
        p6(j,k,i,ic) = p6(j,k,i,ic) + dt * s2(j,k,l,1)
      end forall
    end if
  end do
  if ic == id
    w1(:,:,:,ic) = s2(:,:,:)
  else
    w1(:,:,:,ic) = w1(:,:,:,ic) + s2(:,:,:)
  end if
end do
end do

! Newton's Law, dV = F / m * dt
forall( i=1:3 ) w1(:,:,:,i) = w1(:,:,:,i) * rho(:,:,:)

! Hourglass correction
i1 = halo + 1
i2 = halo + np
s1(:,:,:) = 0
s2(:,:,:) = 0
w2(:,:,:,:) = u(:,:,:,:) + gamma(2) * v(:,:,:,:)
do ic = 1, 3
do iq = 1, 4
  hgnc( s1, w2, ic, iq, i1, i2 - 1 )
  s1(:,:,:) = yc(:,:,:) * s1(:,:,:)
  hgcn( s2, s1, 1, iq, i1, i2 )
  s2(:,:,:) = yn(:,:,:) * s2(:,:,:)
  w1(:,:,:,ic) = w1(:,:,:,ic) - s2(:,:,:)
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
v(:,:,:,:) = v(:,:,:,:) + w1(:,:,:,:)

! if planewavedim, planewave, end

! STEPW

! Gadient
! G = grad(U + gamma*V)    non PML region
! G' + DG = gradV          PML region
s2(:,:,:) = 0
w2(:,:,:,:) = 0
do ic = 1, 3
s1(:,:,:) = u(:,:,:,ic) + gamma(1) .* v(:,:,:,ic)
do id = 1, 3
  ix = 6 - ic - id
  do iz = 1, size( oper, 1 )
    op = oper(iz)
    i1 = opi1(iz,:)
    i2 = opi2(iz,:) - 1
    i1 = max( i1, i1pml )
    i2 = min( i2, i2pml - 1 )
    call dfnc( s2, op, s1, x, dx, 1, id, i1, i2 )
  end do
  op = operator(1)
  do i = 1, npml
    if id /= 1 .and. bc(1)
      i1 = halo + 1
      i2 = halo + np - 1
      j = i1(1) + i - 1
      i1(1) = j
      i2(1) = j
      call dfnc( s2, op, u, x, dx, ic, id, i1, i2 )
    end if
    if id /= 1 .and. bc(4)
      i1 = halo + 1
      i2 = halo + np - 1
      j = i2(1) - i + 1
      i1(1) = j
      i2(1) = j
      call dfnc( s2, op, u, x, dx, ic, id, i1, i2 )
    end if
    if id /= 2 .and. bc(2)
      i1 = halo + 1
      i2 = halo + np - 1
      k = i1(2) + i - 1
      i1(2) = k
      i2(2) = k
      call dfnc( s2, op, u, x, dx, ic, id, i1, i2 )
    end if
    if id /= 2 .and. bc(5)
      i1 = halo + 1
      i2 = halo + np - 1
      k = i2(2) - i + 1
      i1(2) = k
      i2(2) = k
      call dfnc( s2, op, u, x, dx, ic, id, i1, i2 )
    end if
    if id /= 3 .and. bc(3)
      i1 = halo + 1
      i2 = halo + np - 1
      l = i1(3) + i - 1
      i1(3) = l
      i2(3) = l
      call dfnc( s2, op, u, x, dx, ic, id, i1, i2 )
    end if
    if id /= 3 .and. bc(6)
      i1 = halo + 1
      i2 = halo + np - 1
      l = i2(3) - i + 1
      i1(3) = l
      i2(3) = l
      call dfnc( s2, op, u, x, dx, ic, id, i1, i2 )
    end if
  end do
  do i = 1, npml
    if id == 1 .and. bc(1)
      i1 = halo + 1
      i2 = halo + np - 1
      j = i1(1) + i - 1
      i1(1) = j
      i2(1) = j
      call dfnc( s2, op, v, x, dx, ic, id, i1, i2 )
      forall( k=i1(2):i2(2), l=i1(3):i2(3) )
        s2(j,k,l) = dc2(i) * s2(j,k,l) + dc1(i) * g1(i,k,l,ic)
        g1(i,k,l,ic) = s2(j,k,l)
      end forall
    end if
    if id == 1 .and. bc(4)
      i1 = halo + 1
      i2 = halo + np - 1
      j = i2(1) - i + 1
      i1(1) = j
      i2(1) = j
      call dfnc( s2, op, v, x, dx, ic, id, i1, i2 )
      forall( k=i1(2):i2(2), l=i1(3):i2(3) )
        s2(j,k,l) = dc2(i) * s2(j,k,l) + dc1(i) * g4(i,k,l,ic)
        g4(i,k,l,ic) = s2(j,k,l)
      end forall
    end if
    if id == 2 .and. bc(2)
      i1 = halo + 1
      i2 = halo + np - 1
      k = i1(2) + i - 1
      i1(2) = k
      i2(2) = k
      call dfnc( s2, op, v, x, dx, ic, id, i1, i2 )
      forall( j=i1(1):i2(1), l=i1(3):i2(3) )
        s2(j,k,l) = dc2(i) * s2(j,k,l) + dc1(i) * g2(j,i,l,ic)
        g2(j,i,l,ic) = s2(j,k,l)
      end forall
    end if
    if id == 2 .and. bc(5)
      i1 = halo + 1
      i2 = halo + np - 1
      k = i2(2) - i + 1
      i1(2) = k
      i2(2) = k
      call dfnc( s2, op, v, x, dx, ic, id, i1, i2 )
      forall( j=i1(1):i2(1), l=i1(3):i2(3) )
        s2(j,k,l) = dc2(i) * s2(j,k,l) + dc1(i) * g5(j,i,l,ic)
        g5(j,i,l,ic) = s2(j,k,l)
      end forall
    end if
    if id == 3 .and. bc(3)
      i1 = halo + 1
      i2 = halo + np - 1
      l = i1(3) + i - 1
      i1(3) = l
      i2(3) = l
      call dfnc( s2, op, v, x, dx, ic, id, i1, i2 )
      forall( j=i1(1):i2(1), k=i1(2):i2(2) )
        s2(j,k,l) = dc2(i) * s2(j,k,l) + dc1(i) * g3(j,k,i,ic)
        g3(j,k,i,ic) = s2(j,k,l)
      end forall
    end if
    if id == 3 .and. bc(6)
      i1 = halo + 1
      i2 = halo + np - 1
      l = i2(3) - i + 1
      i1(3) = l
      i2(3) = l
      call dfnc( s2, op, v, x, dx, ic, id, i1, i2 )
      forall( j=i1(1):i2(1), k=i1(2):i2(2) )
        s2(j,k,l) = dc2(i) * s2(j,k,l) + dc1(i) * g6(j,k,i,ic)
        g6(j,k,i,ic) = s2(j,k,l)
      end forall
    end if
  end do
  if ic == id
    w1(:,:,:,ic) = s2(:,:,:)
  else
    w2(:,:,:,ix) = w2(:,:,:,ix) + s2(:,:,:)
  end if
end do
end do

! Hook's Law, linear stress/strain relation
! W = lam*trace(G)*I + miu*(G + G^T)
s1(:,:,:) = lam(:,:,:) * ( w1(:,:,:,1) + w1(:,:,:,2) + w(:,:,:,3) )
forall( i = 1:3 )
  w1(:,:,:,i) = 2 * miu(:,:,:) * w1(:,:,:,i) + s1(:,:,:)
  w2(:,:,:,i) =     miu(:,:,:) * w2(:,:,:,i)
end forall

! Moment source
!if msrcradius, momentsrc, end

