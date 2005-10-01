!------------------------------------------------------------------------------!
! Fault boundary condition

module fault_m
use globals_m
use collectiveio_m
use surfnormals_m
use zone_m
contains
subroutine fault

implicit none
save
real :: mus0, mud0, dc0, lc, tn0, ts0, s, rctest
integer :: i, j, k, l, i1(3), j1, k1, l1, i2(3), j2, k2, l2, &
  j3, k3, l3, j4, k4, l4, iz, side
logical :: init = .true.

if ( ifn == 0 ) return

ifinit: if ( init ) then !-----------------------------------------------------!

init = .false.
if ( master ) print '(a)', 'Initialize fault'

! Test if fault plane exists on this processor
if ( ihypo(ifn) < i1node(ifn) .or. ihypo(ifn) > i2node(ifn) ) then
  ifn = 0
  return
end if

! Input
mus = 0.
mud = 0.
dc = 0.
co = 1e9
t1 = 0.
t2 = 0.
t3 = 0.

doiz: do iz = 1, nin
ifreadfile: if ( readfile(iz) ) then
  i1 = i1node
  i2 = i2node
  i1(ifn) = 1
  i2(ifn) = 1
  select case( fieldin(iz) )
  case( 'mus' ); call ioscalar( 'r', 'data/mus', mus,   i1, i2, nn, nnoff, 0 )
  case( 'mud' ); call ioscalar( 'r', 'data/mud', mud,   i1, i2, nn, nnoff, 0 )
  case( 'dc'  ); call ioscalar( 'r', 'data/dc',  dc,    i1, i2, nn, nnoff, 0 )
  case( 'co'  ); call ioscalar( 'r', 'data/co',  co,    i1, i2, nn, nnoff, 0 )
  case( 'sxx' ); call iovector( 'r', 'data/sxx', t1, 1, i1, i2, nn, nnoff, 0 )
  case( 'syy' ); call iovector( 'r', 'data/syy', t1, 2, i1, i2, nn, nnoff, 0 )
  case( 'szz' ); call iovector( 'r', 'data/szz', t1, 3, i1, i2, nn, nnoff, 0 )
  case( 'syz' ); call iovector( 'r', 'data/syz', t2, 1, i1, i2, nn, nnoff, 0 )
  case( 'szx' ); call iovector( 'r', 'data/szx', t2, 2, i1, i2, nn, nnoff, 0 )
  case( 'sxy' ); call iovector( 'r', 'data/szy', t2, 3, i1, i2, nn, nnoff, 0 )
  case( 'tn'  ); call iovector( 'r', 'data/tn',  t3, 1, i1, i2, nn, nnoff, 0 )
  case( 'th'  ); call iovector( 'r', 'data/th',  t3, 2, i1, i2, nn, nnoff, 0 )
  case( 'td'  ); call iovector( 'r', 'data/td',  t3, 3, i1, i2, nn, nnoff, 0 )
  end select
else
  i1 = max( i1in(iz,:), i1node )
  i2 = min( i2in(iz,:), i2node )
  i1(ifn) = 1
  i2(ifn) = 1
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  select case ( fieldin(iz) )
  case( 'mus' ); mus(j1:j2,k1:k2,l1:l2)  = inval(iz)
  case( 'mud' ); mud(j1:j2,k1:k2,l1:l2)  = inval(iz)
  case( 'dc'  ); dc(j1:j2,k1:k2,l1:l2)   = inval(iz)
  case( 'co'  ); co(j1:j2,k1:k2,l1:l2)   = inval(iz)
  case( 'sxx' ); t1(j1:j2,k1:k2,l1:l2,1) = inval(iz)
  case( 'syy' ); t1(j1:j2,k1:k2,l1:l2,2) = inval(iz)
  case( 'szz' ); t1(j1:j2,k1:k2,l1:l2,3) = inval(iz)
  case( 'syz' ); t2(j1:j2,k1:k2,l1:l2,1) = inval(iz)
  case( 'szx' ); t2(j1:j2,k1:k2,l1:l2,2) = inval(iz)
  case( 'sxy' ); t2(j1:j2,k1:k2,l1:l2,3) = inval(iz)
  case( 'tn'  ); t3(j1:j2,k1:k2,l1:l2,1) = inval(iz)
  case( 'th'  ); t3(j1:j2,k1:k2,l1:l2,2) = inval(iz)
  case( 'td'  ); t3(j1:j2,k1:k2,l1:l2,3) = inval(iz)
  end select
end if ifreadfile
end do doiz

! Normal vectors
side = sign( 1, faultnormal )
i1 = i1node
i2 = i2node
i1(ifn) = ihypo(ifn)
i2(ifn) = ihypo(ifn)
call surfnormals( nhat, x, i1, i2 )
area = sqrt( sum( nhat * nhat, 4 ) )
f1 = area
where ( f1 /= 0. ) f1 = side / f1
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
r = sqrt( sum( t3 * t3, 4 ) )

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
  s = ( tn0 * mus0 - ts0 ) / ( ts0 - tn0 * mud0 )
  lc =  dc0 * ( rho * vs * vs ) / tn0 / ( mus0 - mud0 )
  rctest = rho * vs * vs * tn0 * ( mus0 - mud0 ) * dc0 &
    / ( ts0 - tn0 * mud0 ) ** 2
  open(  9, file='out/faultmeta.m', status='replace' )
  write( 9, * ) ' mus0   = ', mus0,   '; % static friction at hypocenter'
  write( 9, * ) ' mud0   = ', mud0,   '; % dynamic friction at hypocenter'
  write( 9, * ) ' dc0    = ', dc0,    '; % dc at hypocenter'
  write( 9, * ) ' tn0    = ', tn0,    '; % normal traction at hypocenter'
  write( 9, * ) ' ts0    = ', ts0,    '; % shear traction at hypocenter'
  write( 9, * ) ' s      = ', s,      '; % strength paramater'
  write( 9, * ) ' lc     = ', lc,     '; % breakdown width'
  write( 9, * ) ' rctest = ', rctest, '; % rcrit for spontaneous rupture'
  close( 9 )
end if

return

end if ifinit !----------------------------------------------------------------!

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
  t3(:,:,:,i) = t0(:,:,:,i) + f1 * side * &
    ( v(j3:j4,k3:k4,l3:l4,i) + dt * w1(j3:j4,k3:k4,l3:l4,i) &
    - v(j1:j2,k1:k2,l1:l2,i) - dt * w1(j1:j2,k1:k2,l1:l2,i) )
end do

! Decompose traction to normal and shear components
tn = sum( t3 * nhat, 4 )
if ( any( tn > 0. ) ) print *, 'Fault opening!'
do i = 1, 3
  t1(:,:,:,i) = tn * nhat(:,:,:,i)
end do
t2 = t3 - t1
ts = sqrt( sum( t2 * t2, 4 ) )

! Slip-weakening friction law
where( tn > 0. ) tn = 0.
f1 = mud
where( sl < dc ) f1 = f1 + ( 1. - sl / dc ) * ( mus - mud )
f1 = -tn * f1 + co

! Nucleation
if ( rcrit > 0. .and. vrup > 0. ) then
  f2 = 1.
  if ( trelax > 0. ) f2 = min( ( t - r / vrup ) / trelax, 1. )
  f2 = ( 1. - f2 ) * ts + f2 * ( -tn * mud + co )
  where ( r < min( rcrit, t * vrup ) .and. f2 < f1 ) f1 = f2
end if

! Shear traction bounded by friction
f2 = 1.
where ( ts > f1 ) f2 = f1 / ts

! Update acceleration
do i = 1, 3
  f1 = area * side * ( t1(:,:,:,i) + f2 * t2(:,:,:,i) - t0(:,:,:,i) )
  w1(j1:j2,k1:k2,l1:l2,i) = w1(j1:j2,k1:k2,l1:l2,i) + f1 * mr(j1:j2,k1:k2,l1:l2)
  w1(j3:j4,k3:k4,l3:l4,i) = w1(j3:j4,k3:k4,l3:l4,i) - f1 * mr(j3:j4,k3:k4,l3:l4)
end do

end subroutine
end module

