! Fault boundary condition
module m_fault
implicit none
contains

! Fault initialization
subroutine fault_init
use m_globals
use m_collective
use m_surfnormals
use m_util
real :: x1(3), x2(3), rr
integer :: i1(3), i2(3), i3(3), i4(3), i, j, k, l, j1, k1, l1, j2, k2, l2, iz

if ( ifn == 0 ) return
if ( master ) write( 0, * ) 'Fault initialization'

! Input
mus = 0.
mud = 0.
dc = 0.
co = huge( 0. )
t1 = 0.
t2 = 0.
t3 = 0.

do iz = 1, nin
select case( intype(iz) )
case( 'r' )
  i1 = 1  + nnoff
  i2 = nn + nnoff
  i3 = i1node
  i4 = i2node
  i1(ifn) = 1
  i2(ifn) = 1
  i3(ifn) = 1
  i4(ifn) = 1
  rr = 0.
  select case( fieldin(iz) )
  case( 'mus' ); call scalario( 'r', 'data/mus', rr, mus, i1, i2, i3, i4,    1, ifn, chunk0 )
  case( 'mud' ); call scalario( 'r', 'data/mud', rr, mud, i1, i2, i3, i4,    1, ifn, chunk0 )
  case( 'dc'  ); call scalario( 'r', 'data/dc',  rr, dc,  i1, i2, i3, i4,    1, ifn, chunk0 )
  case( 'co'  ); call scalario( 'r', 'data/co',  rr, co,  i1, i2, i3, i4,    1, ifn, chunk0 )
  case( 'sxx' ); call vectorio( 'r', 'data/sxx', rr, t1,  i1, i2, i3, i4, 1, 1, ifn, chunk0 )
  case( 'syy' ); call vectorio( 'r', 'data/syy', rr, t1,  i1, i2, i3, i4, 2, 1, ifn, chunk0 )
  case( 'szz' ); call vectorio( 'r', 'data/szz', rr, t1,  i1, i2, i3, i4, 3, 1, ifn, chunk0 )
  case( 'syz' ); call vectorio( 'r', 'data/syz', rr, t2,  i1, i2, i3, i4, 1, 1, ifn, chunk0 )
  case( 'szx' ); call vectorio( 'r', 'data/szx', rr, t2,  i1, i2, i3, i4, 2, 1, ifn, chunk0 )
  case( 'sxy' ); call vectorio( 'r', 'data/szy', rr, t2,  i1, i2, i3, i4, 3, 1, ifn, chunk0 )
  case( 'ts1' ); call vectorio( 'r', 'data/ts1', rr, t3,  i1, i2, i3, i4, 1, 1, ifn, chunk0 )
  case( 'ts2' ); call vectorio( 'r', 'data/ts2', rr, t3,  i1, i2, i3, i4, 2, 1, ifn, chunk0 )
  case( 'tn'  ); call vectorio( 'r', 'data/tn',  rr, t3,  i1, i2, i3, i4, 3, 1, ifn, chunk0 )
  end select
case( 'z' )
  rr = inval(iz)
  i1 = i1in(iz,:)
  i2 = i2in(iz,:)
  call zone( i1, i2, nn, nnoff, ihypo, faultnormal )
  i1 = max( i1, i1node )
  i2 = min( i2, i2node )
  i1(ifn) = 1
  i2(ifn) = 1
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  select case ( fieldin(iz) )
  case( 'mus' ); mus(j1:j2,k1:k2,l1:l2)  = rr
  case( 'mud' ); mud(j1:j2,k1:k2,l1:l2)  = rr
  case( 'dc'  ); dc(j1:j2,k1:k2,l1:l2)   = rr
  case( 'co'  ); co(j1:j2,k1:k2,l1:l2)   = rr
  case( 'sxx' ); t1(j1:j2,k1:k2,l1:l2,1) = rr
  case( 'syy' ); t1(j1:j2,k1:k2,l1:l2,2) = rr
  case( 'szz' ); t1(j1:j2,k1:k2,l1:l2,3) = rr
  case( 'syz' ); t2(j1:j2,k1:k2,l1:l2,1) = rr
  case( 'szx' ); t2(j1:j2,k1:k2,l1:l2,2) = rr
  case( 'sxy' ); t2(j1:j2,k1:k2,l1:l2,3) = rr
  case( 'ts1' ); t3(j1:j2,k1:k2,l1:l2,1) = rr
  case( 'ts2' ); t3(j1:j2,k1:k2,l1:l2,2) = rr
  case( 'tn'  ); t3(j1:j2,k1:k2,l1:l2,3) = rr
  end select
case( 'c' )
  rr = inval(iz)
  x1 = x1in(iz,:)
  x2 = x2in(iz,:)
  i1 = 1
  i2 = nm
  i1(ifn) = ihypo(ifn)
  i2(ifn) = ihypo(ifn)
  select case ( fieldin(iz) )
  case( 'mus' ); call cube( mus, w1, i1, i2, x1, x2, rr )
  case( 'mud' ); call cube( mud, w1, i1, i2, x1, x2, rr )
  case( 'dc'  ); call cube( dc,  w1, i1, i2, x1, x2, rr )
  case( 'co'  ); call cube( co,  w1, i1, i2, x1, x2, rr )
  case( 'sxx' ); f1 = t1(:,:,:,1); call cube( f1, w1, i1, i2, x1, x2, rr ); t1(:,:,:,1) = f1
  case( 'syy' ); f1 = t1(:,:,:,2); call cube( f1, w1, i1, i2, x1, x2, rr ); t1(:,:,:,2) = f1
  case( 'szz' ); f1 = t1(:,:,:,3); call cube( f1, w1, i1, i2, x1, x2, rr ); t1(:,:,:,3) = f1
  case( 'syz' ); f1 = t2(:,:,:,1); call cube( f1, w1, i1, i2, x1, x2, rr ); t2(:,:,:,1) = f1
  case( 'szx' ); f1 = t2(:,:,:,2); call cube( f1, w1, i1, i2, x1, x2, rr ); t2(:,:,:,2) = f1
  case( 'sxy' ); f1 = t2(:,:,:,3); call cube( f1, w1, i1, i2, x1, x2, rr ); t2(:,:,:,3) = f1
  case( 'ts1' ); f1 = t3(:,:,:,1); call cube( f1, w1, i1, i2, x1, x2, rr ); t3(:,:,:,1) = f1
  case( 'ts2' ); f1 = t3(:,:,:,2); call cube( f1, w1, i1, i2, x1, x2, rr ); t3(:,:,:,2) = f1
  case( 'tn'  ); f1 = t3(:,:,:,3); call cube( f1, w1, i1, i2, x1, x2, rr ); t3(:,:,:,3) = f1
  end select
end select
end do

! Normal traction check
i1 = maxloc( t3(:,:,:,3) )
rr = t3(i1(1),i1(2),i1(3),3)
i1(ifn) = ihypo(ifn)
i1 = i1 - nnoff
if ( rr > 0. ) write( 0, * ) 'warning: positive normal traction: ', rr, i1

! Lock fault in PML region
i1 = max( i1pml + 1, 1 )
i2 = min( i2pml - 1, nm )
i1(ifn) = 1
i2(ifn) = 1
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
f1 = co
co = huge( 0. )
co(j1:j2,k1:k2,l1:l2) = f1(j1:j2,k1:k2,l1:l2)

! Normal vectors
i1 = i1node
i2 = i2node
i1(ifn) = ihypo(ifn)
i2(ifn) = ihypo(ifn)
call surfnormals( nhat, w1, i1, i2 )
area = sign( 1, faultnormal ) * sqrt( sum( nhat * nhat, 4 ) )
f1 = area
where ( f1 /= 0. ) f1 = 1. / f1
do i = 1, 3
  nhat(:,:,:,i) = nhat(:,:,:,i) * f1
end do

! Resolve prestress onto fault
do i = 1, 3
  j = modulo( i , 3 ) + 1
  k = modulo( i + 1, 3 ) + 1
  t0(:,:,:,i) = &
    t1(:,:,:,i) * nhat(:,:,:,i) + &
    t2(:,:,:,j) * nhat(:,:,:,k) + &
    t2(:,:,:,k) * nhat(:,:,:,j)
end do

! Ts2 vector
t2(:,:,:,1) = nhat(:,:,:,2) * slipvector(3) - nhat(:,:,:,3) * slipvector(2)
t2(:,:,:,2) = nhat(:,:,:,3) * slipvector(1) - nhat(:,:,:,1) * slipvector(3)
t2(:,:,:,3) = nhat(:,:,:,1) * slipvector(2) - nhat(:,:,:,2) * slipvector(1)
f1 = sqrt( sum( t2 * t2, 4 ) )
where ( f1 /= 0. ) f1 = 1. / f1
do i = 1, 3
  t2(:,:,:,i) = t2(:,:,:,i) * f1
end do

! Ts1 vector
t1(:,:,:,1) = t2(:,:,:,2) * nhat(:,:,:,3) - t2(:,:,:,3) * nhat(:,:,:,2)
t1(:,:,:,2) = t2(:,:,:,3) * nhat(:,:,:,1) - t2(:,:,:,1) * nhat(:,:,:,3)
t1(:,:,:,3) = t2(:,:,:,1) * nhat(:,:,:,2) - t2(:,:,:,2) * nhat(:,:,:,1)
f1 = sqrt( sum( t1 * t1, 4 ) )
where ( f1 /= 0. ) f1 = 1. / f1
do i = 1, 3
  t1(:,:,:,i) = t1(:,:,:,i) * f1
end do

! Total pretraction
do i = 1, 3
  t0(:,:,:,i) = t0(:,:,:,i) + &
    t3(:,:,:,1) * t1(:,:,:,i) + &
    t3(:,:,:,2) * t2(:,:,:,i) + &
    t3(:,:,:,3) * nhat(:,:,:,i)
end do

! Hypocentral radius
i1 = 1
i2 = nm
i1(ifn) = ihypo(ifn)
i2(ifn) = ihypo(ifn)
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
do i = 1, 3
  t2(:,:,:,i) = w1(j1:j2,k1:k2,l1:l2,i) - xhypo(i)
end do
rhypo = sqrt( sum( t2 * t2, 4 ) )

! Save for output
muf = mu(j1:j2,k1:k2,l1:l2)
tn = sum( t0 * nhat, 4 )
do i = 1, 3
  t2(:,:,:,i) = tn * nhat(:,:,:,i)
end do
t3 = t0 - t2
ts = sqrt( sum( t3 * t3, 4 ) )
f1 = 0.
f2 = 0.
t1 = 0.
t2 = 0.

! Halos
call scalarswaphalo( mus, nhalo )
call scalarswaphalo( mud, nhalo )
call scalarswaphalo( dc, nhalo )
call scalarswaphalo( co, nhalo )
call scalarswaphalo( area, nhalo )
call scalarswaphalo( rhypo, nhalo )
call vectorswaphalo( nhat, nhalo )
call vectorswaphalo( t0, nhalo )

! Metadata
if ( master ) then
  i1 = ihypo
  i1(ifn) = 1
  j = i1(1)
  k = i1(2)
  l = i1(3)
  mus0 = mus(j,k,l)
  mud0 = mud(j,k,l)
  dc0 = dc(j,k,l)
  tn0 = sum( t0(j,k,l,:) * nhat(j,k,l,:) )
  ts0 = sqrt( sum( ( t0(j,k,l,:) - tn0 * nhat(j,k,l,:) ) ** 2. ) )
  tn0 = max( -tn0, 0. )
  ess = ( tn0 * mus0 - ts0 ) / ( ts0 - tn0 * mud0 )
  lc =  dc0 * ( rho0 * vs0 ** 2. ) / tn0 / ( mus0 - mud0 )
  if ( tn0 * ( mus0 - mud0 ) == 0. ) lc = 0.
  rctest = rho0 * vs0 ** 2. * tn0 * ( mus0 - mud0 ) * dc0 &
    / ( ts0 - tn0 * mud0 ) ** 2
end if

end subroutine

!------------------------------------------------------------------------------!

! Fault boundary condition
subroutine fault
use m_globals
use m_collective
use m_bc
use m_util
integer :: i1(3), i2(3), i, j1, k1, l1, j2, k2, l2, j3, k3, l3, j4, k4, l4

! If the two sides of the fault are split across domains, than we must retrieve
! the correct solution from the processor that contains both sides. Corresponding
! sends are below.
if ( ifn == 0 ) then
  i = abs( faultnormal )
  if ( i /= 0 ) then
     if ( ibc1(i) == 9 .and. ihypo(i) == 0 ) then
       i1 = 1
       i2 = nm
       i1(i) = 1
       i2(i) = 1
       call vectorrecv( w1, i1, i2, -i )
     elseif ( ibc2(i) == 9 .and. ihypo(i) == nm(i) ) then
       i1 = 1
       i2 = nm
       i1(i) = nm(i)
       i2(i) = nm(i)
       call vectorrecv( w1, i1, i2, i )
     end if
  end if
  return
end if

! Indices
i1 = 1
i2 = nm
i1(ifn) = ihypo(ifn)
i2(ifn) = ihypo(ifn)
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1(ifn) = ihypo(ifn) + 1
i2(ifn) = ihypo(ifn) + 1
j3 = i1(1); j4 = i2(1)
k3 = i1(2); k4 = i2(2)
l3 = i1(3); l4 = i2(3)

! Trial traction for zero velocity and zero displacement
f1 = dt * dt * area * ( mr(j1:j2,k1:k2,l1:l2) + mr(j3:j4,k3:k4,l3:l4) )
where ( f1 /= 0. ) f1 = 1. / f1
do i = 1, 3
  t1(:,:,:,i) = t0(:,:,:,i) + f1 * dt * &
    ( (  v(j3:j4,k3:k4,l3:l4,i) -  v(j1:j2,k1:k2,l1:l2,i) ) &
    + ( w1(j3:j4,k3:k4,l3:l4,i) - w1(j1:j2,k1:k2,l1:l2,i) ) * dt )
  t2(:,:,:,i) = t1(:,:,:,i) + f1 * &
      (  u(j3:j4,k3:k4,l3:l4,i) -  u(j1:j2,k1:k2,l1:l2,i) )
end do

! Shear and normal traction
tn = sum( t1 * nhat, 4 )
do i = 1, 3
  t1(:,:,:,i) = t1(:,:,:,i) - tn * nhat(:,:,:,i)
end do
ts = sqrt( sum( t1 * t1, 4 ) )
tn = min( 0., sum( t2 * nhat, 4 ) )

! Slip-weakening friction law
f1 = mud
where ( sl < dc ) f1 = f1 + ( 1. - sl / dc ) * ( mus - mud )
f1 = -tn * f1 + co

! Nucleation
if ( rcrit > 0. .and. vrup > 0. ) then
  f2 = 1.
  if ( trelax > 0. ) f2 = min( ( t - rhypo / vrup ) / trelax, 1. )
  f2 = ( 1. - f2 ) * ts + f2 * ( -tn * mud + co )
  where ( rhypo < min( rcrit, t * vrup ) .and. f2 < f1 ) f1 = f2
end if

! Shear traction bounded by friction
f2 = 1.
where ( ts > f1 ) f2 = f1 / ts
do i = 1, 3
  t1(:,:,:,i) = f2 * t1(:,:,:,i)
end do
ts = min( ts, f1 )

! Total traction
do i = 1, 3
  t3(:,:,:,i) = t1(:,:,:,i) + tn * nhat(:,:,:,i)
end do

! Update acceleration
do i = 1, 3
  f2 = area * ( t3(:,:,:,i) - t0(:,:,:,i) )
  w1(j1:j2,k1:k2,l1:l2,i) = w1(j1:j2,k1:k2,l1:l2,i) + f2 * mr(j1:j2,k1:k2,l1:l2)
  w1(j3:j4,k3:k4,l3:l4,i) = w1(j3:j4,k3:k4,l3:l4,i) - f2 * mr(j3:j4,k3:k4,l3:l4)
end do
call vectorbc( w1, ibc1, ibc2, nhalo )

! If a neighboring processor contains only one side of the fault, then we must
! send the correct fault wall solution to it.
i = ifn
if ( ibc1(i) == 9 .and. ihypo(i) == 2 * nhalo ) then
  i1 = 1
  i2 = nm
  i1(i) = 2 * nhalo
  i2(i) = 2 * nhalo
  call vectorsend( w1, i1, i2, -i )
elseif ( ibc2(i) == 9 .and. ihypo(i) == nm(i) - 2 * nhalo ) then
  i1 = 1
  i2 = nm
  i1(i) = nm(i) - 2 * nhalo + 1
  i2(i) = nm(i) - 2 * nhalo + 1
  call vectorsend( w1, i1, i2, i )
end if

! Friction + fracture energy
t2 = v(j3:j4,k3:k4,l3:l4,:) - v(j1:j2,k1:k2,l1:l2,:)
f2 = sum( t3 * t2, 4 ) * area
call scalarsethalo( f2, 0., i1node, i2node )
efric = efric + dt * sum( f2 )

! Strain energy
t2 = u(j3:j4,k3:k4,l3:l4,:) - u(j1:j2,k1:k2,l1:l2,:)
f2 = sum( ( t0 + t3 ) * t2, 4 ) * area
call scalarsethalo( f2, 0., i1node, i2node )
estrain = -.5 * sum( f2 )

! Moment
f2 = muf * area * sqrt( sum( t2 * t2, 4 ) )
call scalarsethalo( f2, 0., i1node, i2node )
moment = sum( f2 )

! Slip acceleration
t2 = w1(j3:j4,k3:k4,l3:l4,:) - w1(j1:j2,k1:k2,l1:l2,:)
f2 = sqrt( sum( t2 * t2, 4 ) )

end subroutine

end module

