!------------------------------------------------------------------------------!
! FAULT

module fault_m
contains
subroutine fault
use globals_m
use snormals_m
use zone_m
use binio_m

implicit none
save
real :: fs0, fd0, dc0, tn0, ts0
integer :: down(3), handed, istr, idip, iz
logical :: init = .true.

ifinit: if ( init ) then

init = .false.
if ( inrm == 0 ) return
if ( ip == 0 ) print '(a)', 'Initialize fault'

! Friction model
fs = 0.
fd = 0.
dc = 0.
co = 1e9
if ( fricdir /= '' ) then
  i1 = i1cell
  i2 = i2cell + 1
  i1(inrm) = 1
  i2(inrm) = 1
  call bread3( fricdir, 'fs', fs, i1, i2 )
  call bread3( fricdir, 'fd', fd, i1, i2 )
  call bread3( fricdir, 'dc', dc, i1, i2 )
  call bread3( fricdir, 'co', co, i1, i2 )
end if
do iz = 1, nfric
  call zone( i1, i2, ifric(iz,:), nn, noff, i0, inrm )
  i1 = max( i1, i1nodepml )
  i2 = min( i2, i2nodepml )
  i1(inrm) = 1
  i2(inrm) = 1
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  fs(j1:j2,k1:k2,l1:l2) = friction(iz,1)
  fd(j1:j2,k1:k2,l1:l2) = friction(iz,2)
  dc(j1:j2,k1:k2,l1:l2) = friction(iz,3)
  co(j1:j2,k1:k2,l1:l2) = friction(iz,4)
end do

! Prestress
t1 = 0;
t2 = 0;
if ( stressdir /= '' ) then
  s1 = 0.
  i1 = i1cell
  i2 = i2cell + 1
  i1(inrm) = 1
  i2(inrm) = 1
  call bread4( stressdir, 'xx', t1, i1, i2, 1 )
  call bread4( stressdir, 'yy', t1, i1, i2, 2 )
  call bread4( stressdir, 'zz', t1, i1, i2, 3 )
  call bread4( stressdir, 'yz', t2, i1, i2, 1 )
  call bread4( stressdir, 'zx', t2, i1, i2, 2 )
  call bread4( stressdir, 'xy', t2, i1, i2, 3 )
end if
do iz = 1, nstress
  call zone( i1, i2, istress(iz,:), nn, noff, i0, inrm )
  i1 = max( i1, i1nodepml )
  i2 = min( i2, i2nodepml )
  i1(inrm) = 1
  i2(inrm) = 1
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  t1(j1:j2,k1:k2,l1:l2,1) = stress(iz,1)
  t1(j1:j2,k1:k2,l1:l2,2) = stress(iz,2)
  t1(j1:j2,k1:k2,l1:l2,3) = stress(iz,3)
  t2(j1:j2,k1:k2,l1:l2,4) = stress(iz,4)
  t2(j1:j2,k1:k2,l1:l2,5) = stress(iz,5)
  t2(j1:j2,k1:k2,l1:l2,6) = stress(iz,6)
end do

! Pretraction
t3 = 0.
if ( tracdir /= '' ) then
  s1 = 0.
  i1 = i1cell
  i2 = i2cell + 1
  i1(inrm) = 1
  i2(inrm) = 1
  call bread4( tracdir, 'tn', t3, i1, i2, 1 )
  call bread4( tracdir, 'ts', t3, i1, i2, 2 )
  call bread4( tracdir, 'td', t3, i1, i2, 3 )
end if
do iz = 1, ntrac
  call zone( i1, i2, itrac(iz,:), nn, noff, i0, inrm )
  i1 = max( i1, i1nodepml )
  i2 = min( i2, i2nodepml )
  i1(inrm) = 1
  i2(inrm) = 1
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  t3(j1:j2,k1:k2,l1:l2,1) = traction(iz,1)
  t3(j1:j2,k1:k2,l1:l2,2) = traction(iz,2)
  t3(j1:j2,k1:k2,l1:l2,3) = traction(iz,3)
end do

! Normal vectors
i1 = i1node
i2 = i2node
i1(inrm) = i0(inrm)
i2(inrm) = i0(inrm)
call snormals( nrm, x, i1, i2 )
area = sqrt( sum( nrm * nrm, 4 ) )
f1 = 0.
where ( area /= 0. ) f1 = 1. / area
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

! Find orientations
if ( inrm /= idown ) then
  idip = idown
  istr = 6 - idip - inrm
else
  istr = mod( inrm, 3 ) + 1
  idip = 6 - istr - inrm
end if
down = (/ 0, 0, 0 /)
down(idown) = 1
handed = mod( istr - inrm + 1, 3 ) - 1

! Strike vectors
t1(:,:,:,1) = down(2) * nrm(:,:,:,3) - down(3) * nrm(:,:,:,2)
t1(:,:,:,2) = down(3) * nrm(:,:,:,1) - down(1) * nrm(:,:,:,3)
t1(:,:,:,3) = down(1) * nrm(:,:,:,2) - down(2) * nrm(:,:,:,1)
f1 = sqrt( sum( t1 * t1, 4 ) )
where ( f1 /= 0. ) f1 = handed / f1
do i = 1, 3
  t1(:,:,:,i) = t1(:,:,:,i) * f1
end do

! Dip vectors
t2(:,:,:,1) = nrm(:,:,:,2) * t1(:,:,:,3) - nrm(:,:,:,3) * t1(:,:,:,2)
t2(:,:,:,2) = nrm(:,:,:,3) * t1(:,:,:,1) - nrm(:,:,:,1) * t1(:,:,:,3)
t2(:,:,:,3) = nrm(:,:,:,1) * t1(:,:,:,2) - nrm(:,:,:,2) * t1(:,:,:,1)
f1 = sqrt( sum( t2 * t2, 4 ) )
where ( f1 /= 0. ) f1 = handed / f1
do i = 1, 3
  t2(:,:,:,i) = t2(:,:,:,i) * f1
end do

! Total pretraction
do i = 1, 3
  t0(:,:,:,i) = t0(:,:,:,i) + &
    t3(:,:,:,inrm) * nrm(:,:,:,i) + &
    t3(:,:,:,istr) * t1(:,:,:,i) + &
    t3(:,:,:,idip) * t2(:,:,:,i)
end do

! Hypocentral radius
i1 = 1
i2 = nf
i1(inrm) = i0(inrm)
i2(inrm) = i0(inrm)
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
do i = 1, 3
  t3(:,:,:,i) = x(j1:j2,k1:k2,l1:l2,i) - x0(i)
end do
r = sqrt( sum( t3 * t3, 4 ) )

! Output some info
if ( hypop ) then
  i1 = i0
  i1(inrm) = 1
  j = i1(1)
  k = i1(2)
  l = i1(3)
  fs0 = fs(j,k,l)
  fd0 = fd(j,k,l)
  dc0 = dc(j,k,l)
  tn0 = sum( t0(j,k,l,:) * nrm(j,k,l,:) )
  ts0 = sqrt( sum( ( t0(j,k,l,:) - tn0 * nrm(j,k,l,:) ) ** 2. ) )
  tn0 = max( -tn0, 0. )
  print '(a,es12.4)', '  S:    ', ( tn0 * fs0 - ts0 ) / ( ts0 - tn0 * fd0 )
  print '(2(a,es12.4,x))', '  dc:   ', dc0, '>', 3 * dx * tn0 * ( fs0 - fd0 ) / mu0
  print '(2(a,es12.4,x))', '  rcrit:', rcrit, '>', mu0 * tn0 * ( fs0 - fd0 ) * dc0 / ( ts0 - tn0 * fd0 ) ** 2
end if

return

end if ifinit

!------------------------------------------------------------------------------!

if ( inrm == 0 ) return

! Indices
i1 = 1
i2 = nf
i1(inrm) = i0(inrm)
i2(inrm) = i0(inrm)
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1(inrm) = i0(inrm) + 1
i2(inrm) = i0(inrm) + 1
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
f1 = fd
where( us < dc ) f1 = f1 + ( 1. - us / dc ) * ( fs - fd )
f1 = f1 * -tn + co

! Nucleation
if ( rcrit > 0. .and. vrup > 0. ) then
  f2 = 1.
  if ( nramp > 0 ) f2 = min( ( it * dt - r / vrup ) / ( nramp * dt ), 1. )
  f2 = ( 1. - f2 ) * ts + f2 * ( fd * -tn + co )
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

! Update slip velocity
t2 = v(j3:j4,k3:k4,l3:l4,:) + dt * w1(j3:j4,k3:k4,l3:l4,:) &
   - v(j1:j2,k1:k2,l1:l2,:) - dt * w1(j1:j2,k1:k2,l1:l2,:)
vs = sqrt( sum( t2 * t2, 4 ) )

! Rupture time
if ( truptol > 0. ) then
  where ( trup == 0. .and. vs > truptol ) trup = ( it + .5 ) * dt
end if

end subroutine
end module

