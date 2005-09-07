!------------------------------------------------------------------------------!
! FAULT

module fault_m
contains
subroutine fault
use globals_m
use snormals_m
use zone_m

implicit none
save
real :: fs0, fd0, dc0, tn0, ts0
integer :: down(3), handed, strdim, dipdim, iz, &
  j3, j4, k3, k4, l3, l4, &
  j5, j6, k5, k6, l5, l6
logical :: init = .true.

inittrue: if ( init ) then

init = .false.
if ( nrmdim == 0 ) return
if ( ip == 0 ) print '(a)', 'Initialize fault'

! Friction model
fs = 0.
fd = 0.
dc = 0.
co = 1e9
if ( fricdir /= '' ) then
  i1 = i1cell
  i2 = i2cell + 1
  i2(nrmdim) = 1
  call bread( 'fs', fricdir, i1, i2 )
  call bread( 'fd', fricdir, i1, i2 )
  call bread( 'dc', fricdir, i1, i2 )
  call bread( 'co', fricdir, i1, i2 )
else
  do iz = 1, nfric
    call zone( i1, i2, ifric(iz,:), nn, offset, hypocenter, nrmdim )
    i1 = max( i1, i1nodepml )
    i2 = min( i2, i2nodepml )
    i1(nrmdim) = 1
    i2(nrmdim) = 1
    j1 = i1(1); j2 = i2(1)
    k1 = i1(2); k2 = i2(2)
    l1 = i1(3); l2 = i2(3)
    fs(j1:j2,k1:k2,l1:l2) = friction(iz,1)
    fd(j1:j2,k1:k2,l1:l2) = friction(iz,2)
    dc(j1:j2,k1:k2,l1:l2) = friction(iz,3)
    co(j1:j2,k1:k2,l1:l2) = friction(iz,4)
  end do
end if

! Prestress
t1 = 0.
t2 = 0.
if ( stressdir /= '' ) then
  i1 = i1cell
  i2 = i2cell + 1
  i2(nrmdim) = 1
  call bread( 'xx', stressdir, i1, i2 )
  call bread( 'yy', stressdir, i1, i2 )
  call bread( 'zz', stressdir, i1, i2 )
  call bread( 'yz', stressdir, i1, i2 )
  call bread( 'zx', stressdir, i1, i2 )
  call bread( 'xy', stressdir, i1, i2 )
else
  do iz = 1, nstress
    call zone( i1, i2, istress(iz,:), nn, offset, hypocenter, nrmdim )
    i1 = max( i1, i1nodepml )
    i2 = min( i2, i2nodepml )
    i1(nrmdim) = 1
    i2(nrmdim) = 1
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
end if

! Pretraction
t3 = 0.
if ( tracdir == '' ) then
  i1 = i1cell
  i2 = i2cell + 1
  i2(nrmdim) = 1
  call bread( 'tn', tracdir, i1, i2 )
  call bread( 'ts', tracdir, i1, i2 )
  call bread( 'td', tracdir, i1, i2 )
else
  do iz = 1, ntrac
    call zone( i1, i2, itrac(iz,:), nn, offset, hypocenter, nrmdim )
    i1 = max( i1, i1nodepml )
    i2 = min( i2, i2nodepml )
    i1(nrmdim) = 1
    i2(nrmdim) = 1
    j1 = i1(1); j2 = i2(1)
    k1 = i1(2); k2 = i2(2)
    l1 = i1(3); l2 = i2(3)
    t3(j1:j2,k1:k2,l1:l2,1) = traction(iz,1)
    t3(j1:j2,k1:k2,l1:l2,2) = traction(iz,2)
    t3(j1:j2,k1:k2,l1:l2,3) = traction(iz,3)
  end do
end if

! Normal vectors
i1 = i1node
i2 = i2node
i1(nrmdim) = hypocenter(nrmdim)
i2(nrmdim) = hypocenter(nrmdim)
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
if ( nrmdim /= downdim ) then
  dipdim = downdim
  strdim = 6 - dipdim - nrmdim
else
  strdim = mod( nrmdim, 3 ) + 1
  dipdim = 6 - strdim - nrmdim
end if
down = (/ 0, 0, 0 /)
down(downdim) = 1
handed = mod( strdim - nrmdim + 1, 3 ) - 1

! Strike vectors
t1 = 0.
t1(:,:,:,1) = down(2) * nrm(:,:,:,3) - down(3) * nrm(:,:,:,2)
t1(:,:,:,2) = down(3) * nrm(:,:,:,1) - down(1) * nrm(:,:,:,3)
t1(:,:,:,3) = down(1) * nrm(:,:,:,2) - down(2) * nrm(:,:,:,1)
f1 = sqrt( sum( t1 * t1, 4 ) )
where ( f1 /= 0. ) f1 = handed / f1
do i = 1, 3
  t1(:,:,:,i) = t1(:,:,:,i) * f1
end do

! Dip vectors
t2 = 0.
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
    t3(:,:,:,nrmdim) * nrm(:,:,:,i) + &
    t3(:,:,:,strdim) * t1(:,:,:,i) + &
    t3(:,:,:,dipdim) * t2(:,:,:,i)
end do

! Hypocentral radius
i1 = 1
i2 = nm
i1(nrmdim) = hypocenter(nrmdim)
i2(nrmdim) = hypocenter(nrmdim)
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
do i = 1, 3
  t3(:,:,:,i) = x(j1:j2,k1:k2,l1:l2,i) - xhypo(i)
end do
r = sqrt( sum( t3 * t3, 4 ) )

! Output some info
if ( hypop ) then
  i1 = hypocenter
  i1(nrmdim) = 1
  j = i1(1)
  k = i1(2)
  l = i1(3)
  tn0 = sum( t0(j,k,l,:) * nrm(j,k,l,:) )
  ts0 = sqrt( sum( ( t0(j,k,l,:) - tn0 * nrm(j,k,l,:) ) ** 2. ) )
  tn0 = max( -tn0, 0. )
  fs0 = fs(j,k,l)
  fd0 = fd(j,k,l)
  dc0 = dc(j,k,l)
  print '(a,es10.2)', 'S:    ', ( tn0 * fs0 - ts0 ) / ( ts0 - tn0 * fd0 )
  print '(2(a,es10.2,x))', 'dc:   ', dc0, '>', 3 * dx * tn0 * ( fs0 - fd0 ) / mu0
  print '(2(a,es10.2,x))', 'rcrit:', rcrit, '>', mu0 * tn0 * ( fs0 - fd0 ) * dc0 / ( ts0 - tn0 * fd0 ) ** 2
end if

return

end if inittrue

!------------------------------------------------------------------------------!

if ( nrmdim == 0 ) return

! Indices
i1 = 1
i2 = nm
i1(nrmdim) = hypocenter(nrmdim)
i2(nrmdim) = hypocenter(nrmdim)
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1(nrmdim) = hypocenter(nrmdim) + 1
i2(nrmdim) = hypocenter(nrmdim) + 1
j3 = i1(1); j4 = i2(1)
k3 = i1(2); k4 = i2(2)
l3 = i1(3); l4 = i2(3)
i1(nrmdim) = 1
i2(nrmdim) = 1
j5 = i1(1); j6 = i2(1)
k5 = i1(2); k6 = i2(2)
l5 = i1(3); l6 = i2(3)

! Zero slip velocity condition
f1 = dt * area * ( rho(j1:j2,k1:k2,l1:l2) + rho(j3:j4,k3:k4,l3:l4) )
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
tn = -tn
where( tn < 0. ) tn = 0.
f1 = fd
where( uslip < dc ) f1 = f1 + ( 1. - uslip / dc ) * ( fs - fd )
f1 = f1 * tn + co

! Nucleation
if ( rcrit > 0. .and. vrup > 0. ) then
  f2 = 1.
  if ( nclramp > 0 ) f2 = min( ( it * dt - r / vrup ) / ( nclramp * dt ), 1. )
  f2 = ( 1. - f2 ) * ts + f2 * ( fd * tn + co )
  where ( r < min( rcrit, it * dt * vrup ) .and. f2 < f1 ) f1 = f2
end if
if ( any( f1 <= 0. ) ) print *, 'fault opening!'

! Shear traction bounded by friction
f2 = 1.
where ( ts > f1 ) f2 = f1 / ts

! Update acceleration
do i = 1, 3
  t3(:,:,:,i) = t1(:,:,:,i) + f2 * t2(:,:,:,i) - t0(:,:,:,i)
  w1(j1:j2,k1:k2,l1:l2,i) = &
  w1(j1:j2,k1:k2,l1:l2,i) + t3(:,:,:,i) * area * rho(j1:j2,k1:k2,l1:l2)
  w1(j3:j4,k3:k4,l3:l4,i) = &
  w1(j3:j4,k3:k4,l3:l4,i) + t3(:,:,:,i) * area * rho(j3:j4,k3:k4,l3:l4)
end do

! Vslip
t2 = v(j3:j4,k3:k4,l3:l4,:) + dt * w1(j3:j4,k3:k4,l3:l4,:) &
   - v(j1:j2,k1:k2,l1:l2,:) - dt * w1(j1:j2,k1:k2,l1:l2,:)
vslip = sqrt( sum( t2 * t2, 4 ) )

! Rupture time
if ( truptol > 0. ) then
  where ( trup == 0. .and. vslip > truptol ) trup = ( it + .5 ) * dt
end if

end subroutine
end module

