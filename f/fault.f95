!------------------------------------------------------------------------------!
! FAULT

module fault_m
contains
subroutine fault
use globals_m
use snormals_m
use binio_m

implicit none
save
real :: mus0, mud0, dc0, dctest, tn0, ts0, s, rctest, vector(3)
integer :: i, j, k, l, i1(3), j1, k1, l1, i1(3), j2, k2, l2, &
  j3, k3, l3, j4, k4, l4, iz, idip, istr
logical :: init = .true.

ifinit: if ( init ) then

init = .false.
if ( ifn == 0 ) return
if ( ip == 0 ) print '(a)', 'Initialize fault'

! Input
mus = 0.
mud = 0.
dc = 0.
co = 1e9
t1 = 0.
t2 = 0.
t3 = 0.
doi: do i = 1, nin
ifreadfile: if ( readfile(i) ) then
  i1 = i1node
  i2 = i2node
  i1(ifn) = 1
  i2(ifn) = 1
  select case ( fieldin(i) )
  case ( 'mus'  ); call pread3( 'data/mus',  mus, i1, i2 )
  case ( 'mud'  ); call pread3( 'data/mud',  mud, i1, i2 )
  case ( 'dc'   ); call pread3( 'data/dc',   dc, i1, i2 )
  case ( 'co'   ); call pread3( 'data/co',   co, i1, i2 )
  case ( 'sxx'  ); call pread4( 'data/sxx',  t1, i1, i2, 1 )
  case ( 'syy'  ); call pread4( 'data/syy',  t1, i1, i2, 2 )
  case ( 'szz'  ); call pread4( 'data/szz',  t1, i1, i2, 3 )
  case ( 'syz'  ); call pread4( 'data/syz',  t2, i1, i2, 1 )
  case ( 'szx'  ); call pread4( 'data/szx',  t2, i1, i2, 2 )
  case ( 'sxy'  ); call pread4( 'data/szy',  t2, i1, i2, 3 )
  case ( 'tnrm' ); call pread4( 'data/tnrm', t3, i1, i2, 1 )
  case ( 'tstr' ); call pread4( 'data/tstr', t3, i1, i2, 2 )
  case ( 'tdip' ); call pread4( 'data/tdip', t3, i1, i2, 3 )
  end select
else
  i1 = max( i1in(i,:), i1node )
  i2 = min( i2in(i,:), i2node )
  i1(ifn) = 1
  i2(ifn) = 1
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  select case ( fieldin(i) )
  case ( 'mus'  ); mus(j1:j2,k1:k2,l1:l2)  = inval(i)
  case ( 'mud'  ); mud(j1:j2,k1:k2,l1:l2)  = inval(i)
  case ( 'dc'   ); dc(j1:j2,k1:k2,l1:l2)   = inval(i)
  case ( 'co'   ); co(j1:j2,k1:k2,l1:l2)   = inval(i)
  case ( 'sxx'  ); t1(j1:j2,k1:k2,l1:l2,1) = inval(i)
  case ( 'syy'  ); t1(j1:j2,k1:k2,l1:l2,2) = inval(i)
  case ( 'szz'  ); t1(j1:j2,k1:k2,l1:l2,3) = inval(i)
  case ( 'syz'  ); t2(j1:j2,k1:k2,l1:l2,1) = inval(i)
  case ( 'szx'  ); t2(j1:j2,k1:k2,l1:l2,2) = inval(i)
  case ( 'sxy'  ); t2(j1:j2,k1:k2,l1:l2,3) = inval(i)
  case ( 'tnrm' ); t3(j1:j2,k1:k2,l1:l2,1) = inval(i)
  case ( 'tstr' ); t3(j1:j2,k1:k2,l1:l2,2) = inval(i)
  case ( 'tdip' ); t3(j1:j2,k1:k2,l1:l2,3) = inval(i)
  end select
end if ifreadfile
end do doi

! Normal vectors
i1 = i1node
i2 = i2node
i1(ifn) = ihypo(ifn)
i2(ifn) = ihypo(ifn)
call snormals( nrm, x, i1, i2 )
area = sqrt( sum( nrm * nrm, 4 ) )
f1 = area
where ( f1 /= 0. ) f1 = 1. / f1
do i = 1, 3
  nrm(:,:,:,i) = nrm(:,:,:,i) * f1
end do

! Resolve prestress onto fault
do i = 1, 3
  j = mod( i , 3 ) + 1
  k = mod( i + 1, 3 ) + 1
  t0(:,:,:,i) = &
    t1(:,:,:,i) * nrm(:,:,:,i) + &
    t2(:,:,:,j) * nrm(:,:,:,k) + &
    t2(:,:,:,k) * nrm(:,:,:,j)
end do

! Coordinate system
idip = abs( upward )
if ( idip /= ifn ) then
  istr = 6 - ifn - idip
else
  istr = mod( ifn, 3 ) + 1
  idip = 6 - ifn - istr
end if

! Strike vectors
upvector = 0.
upvector(idip) = 1.
t1(:,:,:,1) = upvector(2) * nrm(:,:,:,3) - upvector(3) * nrm(:,:,:,2)
t1(:,:,:,2) = upvector(3) * nrm(:,:,:,1) - upvector(1) * nrm(:,:,:,3)
t1(:,:,:,3) = upvector(1) * nrm(:,:,:,2) - upvector(2) * nrm(:,:,:,1)
f1 = sqrt( sum( t1 * t1, 4 ) )
where ( f1 /= 0. ) f1 = 1. / f1
do i = 1, 3
  t1(:,:,:,i) = t1(:,:,:,i) * f1
end do

! Dip vectors
t2(:,:,:,1) = t1(:,:,:,2) * nrm(:,:,:,3) - t1(:,:,:,3) * nrm(:,:,:,2)
t2(:,:,:,2) = t1(:,:,:,3) * nrm(:,:,:,1) - t1(:,:,:,1) * nrm(:,:,:,3)
t2(:,:,:,3) = t1(:,:,:,1) * nrm(:,:,:,2) - t1(:,:,:,2) * nrm(:,:,:,1)
f1 = sqrt( sum( t2 * t2, 4 ) )
where ( f1 /= 0. ) f1 = 1. / f1
do i = 1, 3
  t2(:,:,:,i) = t2(:,:,:,i) * f1
end do

! Total pretraction
do i = 1, 3
  t0(:,:,:,i) = t0(:,:,:,i) + &
    t3(:,:,:,ifn)  * nrm(:,:,:,i) + &
    t3(:,:,:,istr) * t1(:,:,:,i) + &
    t3(:,:,:,idip) * t2(:,:,:,i)
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
if ( all( i1hypo >= i1node .and. i1hypo <= i2node ) ) then
  i1 = ihypo
  i1(ifn) = 1
  j = i1(1)
  k = i1(2)
  l = i1(3)
  mus0 = mus(j,k,l)
  mud0 = mud(j,k,l)
  dc0 = dc(j,k,l)
  tn0 = sum( t0(j,k,l,:) * nrm(j,k,l,:) )
  ts0 = sqrt( sum( ( t0(j,k,l,:) - tn0 * nrm(j,k,l,:) ) ** 2. ) )
  tn0 = max( -tn0, 0. )
  s = ( tn0 * mus0 - ts0 ) / ( ts0 - tn0 * mud0 )
  dctest = 3 * abs( dx ) * tn0 * ( mus0 - mud0 ) / ( rho * vs * vs )
  rctest = rho * vs * vs * tn0 * ( mus0 - mud0 ) * dc0 &
    / ( ts0 - tn0 * mud0 ) ** 2
  open(  9, file='out/faultmeta.m', status='new' )
  write( 9, * ) 'mus0   = ', mus0,   ';% static friction at hypocenter'
  write( 9, * ) 'mud0   = ', mud0,   ';% dynamic friction at hypocenter'
  write( 9, * ) 'dc0    = ', dc0,    ';% dc at hypocenter'
  write( 9, * ) 'dctest = ', dctest, ';% breakdown resolution test'
  write( 9, * ) 'tn0    = ', tn0,    ';% normal traction at hypocenter'
  write( 9, * ) 'ts0    = ', ts0,    ';% shear traction at hypocenter'
  write( 9, * ) 's      = ', s,      ';% strength paramater'
  write( 9, * ) 'rctest = ', rctest, ';% remmomended rcrit for nucleation'
  close( 9 )
end if

return

end if ifinit

!------------------------------------------------------------------------------!

if ( ifn == 0 ) return

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
  t3(:,:,:,i) = t0(:,:,:,i) + f1 * &
    ( v(j3:j4,k3:k4,l3:l4,i) + dt * w1(j3:j4,k3:k4,l3:l4,i) &
    - v(j1:j2,k1:k2,l1:l2,i) - dt * w1(j1:j2,k1:k2,l1:l2,i) )
end do

! Decompose traction to normal and shear components
tn = sum( t3 * nrm, 4 )
do i = 1, 3
  t1(:,:,:,i) = tn * nrm(:,:,:,i)
end do
t2 = t3 - t1
ts = sqrt( sum( t2 * t2, 4 ) )

! Friction Law
where( tn > 0. ) tn = 0.
f1 = mud
where( sl < dc ) f1 = f1 + ( 1. - sl / dc ) * ( mus - mud )
f1 = f1 * -tn + co

! Nucleation
if ( rcrit > 0. .and. vrup > 0. ) then
  f2 = 1.
  if ( trelax > 0. ) f2 = min( ( it * dt - r / vrup ) / trelax, 1. )
  f2 = ( 1. - f2 ) * ts + f2 * ( mud * -tn + co )
  where ( r < min( rcrit, it * dt * vrup ) .and. f2 < f1 ) f1 = f2
end if
if ( any( f1 <= 0. ) ) print *, 'Fault opening!'

! Shear traction bounded by friction
f2 = 1.
where ( ts > f1 ) f2 = f1 / ts

! Update acceleration
do i = 1, 3
  f1 = area * ( t1(:,:,:,i) + f2 * t2(:,:,:,i) - t0(:,:,:,i) )
  w1(j1:j2,k1:k2,l1:l2,i) = w1(j1:j2,k1:k2,l1:l2,i) + f1 * mr(j1:j2,k1:k2,l1:l2)
  w1(j3:j4,k3:k4,l3:l4,i) = w1(j3:j4,k3:k4,l3:l4,i) - f1 * mr(j3:j4,k3:k4,l3:l4)
end do

! FIXME probably should do locked nodes here or move time integration out
! Time integratioin for slip velocity
t1 = v(j3:j4,k3:k4,l3:l4,:) + dt * w1(j3:j4,k3:k4,l3:l4,:) &
   - v(j1:j2,k1:k2,l1:l2,:) - dt * w1(j1:j2,k1:k2,l1:l2,:)
sv = sqrt( sum( t1 * t1, 4 ) )

! Rupture time
if ( truptol > 0. ) then
  where ( trup == 0. .and. vs > truptol ) trup = t
end if

end subroutine
end module

