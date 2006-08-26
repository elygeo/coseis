! Fault boundary condition
module m_fault
implicit none
contains

!------------------------------------------------------------------------------!
! Fault initialization
subroutine fault_init
use m_globals
use m_collective
use m_surfnormals
use m_util
real :: mus0, mud0, dc0, lc, tn0, ts0, ess, rctest, x1(3), x2(3), rr
integer :: i1(3), i2(3), i3(3), i4(3), i, j, k, l, j1, k1, l1, j2, k2, l2, iz

if ( ifn == 0 ) return
if ( master ) write( 0, * ) 'Fault initialization'

! Input
mus = 0.
mud = 0.
dc = 0.
co = 1e9
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
  select case( fieldin(iz) )
  case( 'mus' ); call scalario( 'r', 'data/mus', mus,   1, i1, i2, i3, i4, ifn )
  case( 'mud' ); call scalario( 'r', 'data/mud', mud,   1, i1, i2, i3, i4, ifn )
  case( 'dc'  ); call scalario( 'r', 'data/dc',  dc,    1, i1, i2, i3, i4, ifn )
  case( 'co'  ); call scalario( 'r', 'data/co',  co,    1, i1, i2, i3, i4, ifn )
  case( 'sxx' ); call vectorio( 'r', 'data/sxx', t1, 1, 1, i1, i2, i3, i4, ifn )
  case( 'syy' ); call vectorio( 'r', 'data/syy', t1, 2, 1, i1, i2, i3, i4, ifn )
  case( 'szz' ); call vectorio( 'r', 'data/szz', t1, 3, 1, i1, i2, i3, i4, ifn )
  case( 'syz' ); call vectorio( 'r', 'data/syz', t2, 1, 1, i1, i2, i3, i4, ifn )
  case( 'szx' ); call vectorio( 'r', 'data/szx', t2, 2, 1, i1, i2, i3, i4, ifn )
  case( 'sxy' ); call vectorio( 'r', 'data/szy', t2, 3, 1, i1, i2, i3, i4, ifn )
  case( 'tn'  ); call vectorio( 'r', 'data/tn',  t3, 1, 1, i1, i2, i3, i4, ifn )
  case( 'th'  ); call vectorio( 'r', 'data/th',  t3, 2, 1, i1, i2, i3, i4, ifn )
  case( 'td'  ); call vectorio( 'r', 'data/td',  t3, 3, 1, i1, i2, i3, i4, ifn )
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
  case( 'tn'  ); t3(j1:j2,k1:k2,l1:l2,1) = rr
  case( 'th'  ); t3(j1:j2,k1:k2,l1:l2,2) = rr
  case( 'td'  ); t3(j1:j2,k1:k2,l1:l2,3) = rr
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
  case( 'mus' ); call cube( mus, x, i1, i2, x1, x2, rr )
  case( 'mud' ); call cube( mud, x, i1, i2, x1, x2, rr )
  case( 'dc'  ); call cube( dc,  x, i1, i2, x1, x2, rr )
  case( 'co'  ); call cube( co,  x, i1, i2, x1, x2, rr )
  case( 'sxx' ); f1 = t1(:,:,:,1); call cube( f1, x, i1, i2, x1, x2, rr ); t1(:,:,:,1) = f1
  case( 'syy' ); f1 = t1(:,:,:,2); call cube( f1, x, i1, i2, x1, x2, rr ); t1(:,:,:,2) = f1
  case( 'szz' ); f1 = t1(:,:,:,3); call cube( f1, x, i1, i2, x1, x2, rr ); t1(:,:,:,3) = f1
  case( 'syz' ); f1 = t2(:,:,:,1); call cube( f1, x, i1, i2, x1, x2, rr ); t2(:,:,:,1) = f1
  case( 'szx' ); f1 = t2(:,:,:,2); call cube( f1, x, i1, i2, x1, x2, rr ); t2(:,:,:,2) = f1
  case( 'sxy' ); f1 = t2(:,:,:,3); call cube( f1, x, i1, i2, x1, x2, rr ); t2(:,:,:,3) = f1
  case( 'tn'  ); f1 = t3(:,:,:,1); call cube( f1, x, i1, i2, x1, x2, rr ); t3(:,:,:,1) = f1
  case( 'th'  ); f1 = t3(:,:,:,2); call cube( f1, x, i1, i2, x1, x2, rr ); t3(:,:,:,2) = f1
  case( 'td'  ); f1 = t3(:,:,:,3); call cube( f1, x, i1, i2, x1, x2, rr ); t3(:,:,:,3) = f1
  end select
end select
end do

! Sanity check
if ( any( t3(:,:,:,1) > 0.) ) write( 0, * ) 'warning: positive normal traction'

! Lock fault in PML region
i1 = max( i1pml + 1, 1 )
i2 = min( i2pml - 1, nm )
i1(ifn) = 1
i2(ifn) = 1
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
f1 = co
co = 1e9
co(j1:j2,k1:k2,l1:l2) = f1(j1:j2,k1:k2,l1:l2)

! Normal vectors
i1 = i1node
i2 = i2node
i1(ifn) = ihypo(ifn)
i2(ifn) = ihypo(ifn)
call surfnormals( nhat, x, i1, i2 )
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

! Strike vectors
t1(:,:,:,1) = nhat(:,:,:,2) * upvector(3) - nhat(:,:,:,3) * upvector(2)
t1(:,:,:,2) = nhat(:,:,:,3) * upvector(1) - nhat(:,:,:,1) * upvector(3)
t1(:,:,:,3) = nhat(:,:,:,1) * upvector(2) - nhat(:,:,:,2) * upvector(1)
f1 = sqrt( sum( t1 * t1, 4 ) )
where ( f1 /= 0. ) f1 = 1. / f1
do i = 1, 3
  t1(:,:,:,i) = t1(:,:,:,i) * f1
end do

! Dip vectors
t2(:,:,:,1) = nhat(:,:,:,2) * t1(:,:,:,3) - nhat(:,:,:,3) * t1(:,:,:,2)
t2(:,:,:,2) = nhat(:,:,:,3) * t1(:,:,:,1) - nhat(:,:,:,1) * t1(:,:,:,3)
t2(:,:,:,3) = nhat(:,:,:,1) * t1(:,:,:,2) - nhat(:,:,:,2) * t1(:,:,:,1)
f1 = sqrt( sum( t2 * t2, 4 ) )
where ( f1 /= 0. ) f1 = 1. / f1
do i = 1, 3
  t2(:,:,:,i) = t2(:,:,:,i) * f1
end do

! Total pretraction
do i = 1, 3
  t0(:,:,:,i) = t0(:,:,:,i) + &
    t3(:,:,:,1) * nhat(:,:,:,i) + &
    t3(:,:,:,2) * t1(:,:,:,i) + &
    t3(:,:,:,3) * t2(:,:,:,i)
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
  t2(:,:,:,i) = x(j1:j2,k1:k2,l1:l2,i) - xhypo(i)
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
  open( 1, file='faultmeta.m', status='replace' )
  write( 1, * ) 'mus0   = ', mus0,   '; % static friction at hypocenter'
  write( 1, * ) 'mud0   = ', mud0,   '; % dynamic friction at hypocenter'
  write( 1, * ) 'dc0    = ', dc0,    '; % dc at hypocenter'
  write( 1, * ) 'tn0    = ', tn0,    '; % normal traction at hypocenter'
  write( 1, * ) 'ts0    = ', ts0,    '; % shear traction at hypocenter'
  write( 1, * ) 'ess    = ', ess,    '; % strength paramater'
  write( 1, * ) 'lc     = ', lc,     '; % breakdown width'
  write( 1, * ) 'rctest = ', rctest, '; % rcrit for spontaneous rupture'
  close( 1 )
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
real :: r1

! If the two sides of the fault are split accross domains, than we must retrieve
! the correct solution from the processor that contains both sides. Corrisponding
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

! Zero slip velocity condition
f1 = dt * area * ( mr(j1:j2,k1:k2,l1:l2) + mr(j3:j4,k3:k4,l3:l4) )
where ( f1 /= 0. ) f1 = 1. / f1
do i = 1, 3
  t1(:,:,:,i) = t0(:,:,:,i) + f1 * &
    ( v(j3:j4,k3:k4,l3:l4,i) + dt * w1(j3:j4,k3:k4,l3:l4,i) &
    - v(j1:j2,k1:k2,l1:l2,i) - dt * w1(j1:j2,k1:k2,l1:l2,i) )
end do

! Decompose traction to normal and shear components
tn = sum( t1 * nhat, 4 )
do i = 1, 3
  t2(:,:,:,i) = tn * nhat(:,:,:,i)
end do
t3 = t1 - t2
ts = sqrt( sum( t3 * t3, 4 ) )

! Slip-weakening friction law
where ( tn > 0. ) tn = 0.
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
  t3(:,:,:,i) = f2 * t3(:,:,:,i)
end do

! Total traction
t1 = t2 + t3

! Save for output
tn = sum( t1 * nhat, 4 )
ts = f2 * ts
t1 = 0.
t2 = 0.
f1 = 0.
f2 = 0.

! Update acceleration
do i = 1, 3
  f2 = area * ( t1(:,:,:,i) - t0(:,:,:,i) )
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
f2 = sum( t1 * t2, 4 ) * area
call sethalo( f2, 0., i1node, i2node )
call psum( r1, dt * sum( f2 ), ifn )
efric = efric + r1

! Strain enegry
t2 = u(j3:j4,k3:k4,l3:l4,:) - u(j1:j2,k1:k2,l1:l2,:)
f2 = sum( ( t0 + t1 ) * t2, 4 ) * area
call sethalo( f2, 0., i1node, i2node )
call psum( estrain, -.5 * sum( f2 ), ifn )

! Moment
f2 = muf * area * sqrt( sum( t2 * t2, 4 ) )
call sethalo( f2, 0., i1node, i2node )
call psum( m0, sum( f2 ), ifn )

! Slip acceleration
t2 = w1(j3:j4,k3:k4,l3:l4,:) - w1(j1:j2,k1:k2,l1:l2,:)
f2 = sqrt( sum( t2 * t2, 4 ) )

end subroutine

end module

