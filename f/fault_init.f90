! Fault initialization
module m_fault_init
implicit none
contains

subroutine fault_init
use m_globals
use m_collectiveio
use m_bc
use m_tictoc
use m_surfnormals
use m_zone
real :: mus0, mud0, dc0, lc, tn0, ts0, ess, rctest, x1(3), x2(3), rr
integer :: i1(3), i2(3), i1l(3), i2l(3), i, j, k, l, j1, k1, l1, j2, k2, l2, iz

if ( ifn == 0 ) return
if ( master ) call toc( 'Fault initialization' )

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
  i1l = i1node
  i2l = i2node
  i1(ifn) = 1
  i2(ifn) = 1
  i1l(ifn) = 1
  i2l(ifn) = 1
  select case( fieldin(iz) )
  case( 'mus' ); call scalario( 'r', 'data/mus', mus,   1, i1, i2, i1l, i2l, ifn )
  case( 'mud' ); call scalario( 'r', 'data/mud', mud,   1, i1, i2, i1l, i2l, ifn )
  case( 'dc'  ); call scalario( 'r', 'data/dc',  dc,    1, i1, i2, i1l, i2l, ifn )
  case( 'co'  ); call scalario( 'r', 'data/co',  co,    1, i1, i2, i1l, i2l, ifn )
  case( 'sxx' ); call vectorio( 'r', 'data/sxx', t1, 1, 1, i1, i2, i1l, i2l, ifn )
  case( 'syy' ); call vectorio( 'r', 'data/syy', t1, 2, 1, i1, i2, i1l, i2l, ifn )
  case( 'szz' ); call vectorio( 'r', 'data/szz', t1, 3, 1, i1, i2, i1l, i2l, ifn )
  case( 'syz' ); call vectorio( 'r', 'data/syz', t2, 1, 1, i1, i2, i1l, i2l, ifn )
  case( 'szx' ); call vectorio( 'r', 'data/szx', t2, 2, 1, i1, i2, i1l, i2l, ifn )
  case( 'sxy' ); call vectorio( 'r', 'data/szy', t2, 3, 1, i1, i2, i1l, i2l, ifn )
  case( 'tn'  ); call vectorio( 'r', 'data/tn',  t3, 1, 1, i1, i2, i1l, i2l, ifn )
  case( 'th'  ); call vectorio( 'r', 'data/th',  t3, 2, 1, i1, i2, i1l, i2l, ifn )
  case( 'td'  ); call vectorio( 'r', 'data/td',  t3, 3, 1, i1, i2, i1l, i2l, ifn )
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
if ( any( t3(:,:,:,1) > 0.) ) stop 'normal traction must be negative'

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
  t3(:,:,:,i) = x(j1:j2,k1:k2,l1:l2,i) - xhypo(i)
end do
rhypo = sqrt( sum( t3 * t3, 4 ) )

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
  open(  9, file='faultmeta.m', status='replace' )
  write( 9, * ) 'mus0   = ', mus0,   '; % static friction at hypocenter'
  write( 9, * ) 'mud0   = ', mud0,   '; % dynamic friction at hypocenter'
  write( 9, * ) 'dc0    = ', dc0,    '; % dc at hypocenter'
  write( 9, * ) 'tn0    = ', tn0,    '; % normal traction at hypocenter'
  write( 9, * ) 'ts0    = ', ts0,    '; % shear traction at hypocenter'
  write( 9, * ) 'ess    = ', ess,    '; % strength paramater'
  write( 9, * ) 'lc     = ', lc,     '; % breakdown width'
  write( 9, * ) 'rctest = ', rctest, '; % rcrit for spontaneous rupture'
  close( 9 )
end if

end subroutine

end module

