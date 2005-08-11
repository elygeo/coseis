!------------------------------------------------------------------------------!
! FAULT

module fault_m

implicit none
private
real, public :: uslip(:,:,:), vslip(:,:,:), trup(:,:,:)
real :: fs(:,:,:), fd(:,:,:), dc(:,:,:), cohes(:,:,:), &
  nrm(:,:,:,:), area(:,:,:), r(:,:,:), tt0(:,:,:,:), tmp(:,:,:)
integer :: i, j, k, l, nf(3), n(3)

contains

subroutine fault_init

use snormals_m

real ::  w0(:,:,:), str(:,:,:,:), dip(:,:,:,:)

print '(a)', 'Initialize fault'
nm = shape( x )
npf = np
npf(nrmdim) = 1
nmf = npf + 2 * halo
j = nmf(1)
k = nmf(2)
l = nmf(3)
allocate( uslip(j,k,l), vslip(j,k,l), trup(j,k,l), &
  fs(j,k,l), fd(j,k,l), dc(j,k,l), cohes(j,k,l), &
  nrm(j,k,l,3), area(j,k,l), r(j,k,l), tt0(j,k,l,3), tmp(j,k,l), &
  w0(j,k,l,6), str(j,k,l,3), dip(j,k,l,3) )
uslip = 0.
vslip = 0.
trup = 0.
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
fs = 0.
fd = 0.
dc = 0.
cohes = 1e9
do iz = 1, nfric
  zoneselect( frici(iz,:), halo, np, hypocenter, nrmdim, i1, i2 )
  i1 = max( i1, i1pml )
  i2 = min( i2, i2pml )
  i1(nrmdim) = 1
  i2(nrmdim) = 1
  j1 = i1(1); k1 = i1(2); l1 = i1(3)
  j2 = i2(1); k2 = i2(2); l2 = i2(3)
  fs(j1:j2,k1:k2,l1:l2)    = friction(iz,1)
  fd(j1:j2,k1:k2,l1:l2)    = friction(iz,2)
  dc(j1:j2,k1:k2,l1:l2)    = friction(iz,3)
  cohes(j1:j2,k1:k2,l1:l2) = friction(iz,4)
end do
! normal vectors
i1 = halo + (/ 1, 1, 1 /)
i2 = halo + np
call snormals( x, i1, i2, nrm )
area = sqrt( sum( nrm * nrm, 4 ) )
tmp = 0.
where ( area /= 0. ) tmp = 1. / area
do i = 1, 3
  nrm(:,:,:,i) = nrm(:,:,:,i) * tmp
end do
! strike vectors
str(:,:,:,1) = down(2) * nrm(:,:,:,3) - down(3) * nrm(:,:,:,2)
str(:,:,:,2) = down(3) * nrm(:,:,:,1) - down(1) * nrm(:,:,:,3)
str(:,:,:,3) = down(1) * nrm(:,:,:,2) - down(2) * nrm(:,:,:,1)
tmp = sqrt( sum( str * str, 4 ) )
where ( tmp /= 0. ) tmp = handed / tmp
do i = 1, 3
  str(:,:,:,i) = str(:,:,:,i) * tmp
end do
! dip vectors
dip(:,:,:,1) = nrm(2) * str(:,:,:,3) - nrm(3) * str(:,:,:,2)
dip(:,:,:,2) = nrm(3) * str(:,:,:,1) - nrm(1) * str(:,:,:,3)
dip(:,:,:,3) = nrm(1) * str(:,:,:,2) - nrm(2) * str(:,:,:,1)
tmp = sqrt( sum( dip * dip, 4 ) )
where ( tmp /= 0. ) tmp = handed / tmp
do i = 1, 3
  dip(:,:,:,i) = dip(:,:,:,i) * tmp
end do
tt0nsd = 0.
do iz = 1, ntrac
  zoneselect( traci(iz,:), halo, npf, hypocenter, nrmdim, i1, i2 )
  i1 = max( i1, i1pml )
  i2 = min( i2, i2pml )
  i1(nrmdim) = 1
  i2(nrmdim) = 1
  j1 = i1(1); k1 = i1(2); l1 = i1(3)
  j2 = i2(1); k2 = i2(2); l2 = i2(3)
  tt0nsd(j1:j2,k1:k2,l1:l2,1) = traction(iz,1)
  tt0nsd(j1:j2,k1:k2,l1:l2,2) = traction(iz,2)
  tt0nsd(j1:j2,k1:k2,l1:l2,3) = traction(iz,3)
end do
do i = 1, 3
  tt0(:,:,:,i) = &
    tt0nsd(:,:,:,nrmdim) * nrm(:,:,:,i) + &
    tt0nsd(:,:,:,strdim) * str(:,:,:,i) + &
    tt0nsd(:,:,:,dipdim) * dip(:,:,:,i)
end do
w0 = 0.
do iz = 1, nstress
  zoneselect( stressi(iz,:), halo, npf, hypocenter, nrmdim, i1, i2 )
  i1 = max( i1, i1pml )
  i2 = min( i2, i2pml )
  i1(nrmdim) = 1
  i2(nrmdim) = 1
  j1 = i1(1); k1 = i1(2); l1 = i1(3)
  j2 = i2(1); k2 = i2(2); l2 = i2(3)
  w0(j1:j2,k1:k2,l1:l2,1) = stress(iz,1)
  w0(j1:j2,k1:k2,l1:l2,2) = stress(iz,2)
  w0(j1:j2,k1:k2,l1:l2,3) = stress(iz,3)
  w0(j1:j2,k1:k2,l1:l2,4) = stress(iz,4)
  w0(j1:j2,k1:k2,l1:l2,5) = stress(iz,5)
  w0(j1:j2,k1:k2,l1:l2,6) = stress(iz,6)
end do
do a = 1, 3
  b = mod( a , 3 ) + 4
  c = mod( a + 1, 3 ) + 4
  tt0(:,:,:,a) = tt0(:,:,:,a) + &
    w0(:,:,:,a) * nrm(:,:,:,a) + &
    w0(:,:,:,b) * nrm(:,:,:,c) + &
    w0(:,:,:,c) * nrm(:,:,:,b)
end do
hypocloc = x(hypocenter(1),hypocenter(2),hypocenter(3))
forall( i=1:3, j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
  wf1(j,k,l,i) = x(j+j1,k+k1,l+l1,i) - hypoloc(i)
end forall
r = sqrt( sum( wf1 * wf1, 4 ) )
!if nm(1) == 4, r = repmat( r(j,:,:), [ 4 1 1 ] ); end ! 2D cases
!if nm(2) == 4, r = repmat( r(:,k,:), [ 1 4 1 ] ); end ! 2D cases
!if nm(3) == 4, r = repmat( r(:,:,l), [ 1 1 4 ] ); end ! 2D cases
i1 = hypocenter
i1(nrmdim) = 1
j = i1(1)
k = i1(2)
l = i1(3)
tn0 = sum( tt0(j,k,l,:) * nrm(j,k,l,:) )
ts0 = norm( shiftdim( tt0(j,k,l,:) - tn0 * nrm(j,k,l,:) ) )
tn0 = max( -tn0, 0. )
fs0 = fs(j,k,l)
fd0 = fd(j,k,l)
dc0 = dc(j,k,l)
print *, 'S', ( tn0 * fs0 - ts0 ) / ( ts0 - tn0 * fd0 )
print *, 'dc: ', dc0, '>', 3 * dx * tn0 * ( fs0 - fd0 ) / miu0
print *, 'rcrit: ', rcrit, '>', miu0 * tn0 * ( fs0 - fd0 ) * dc0 / ( ts0 - tn0 * fd0 ) ^ 2
i1 = (/ 1, 1, 1 /)
i2 = np + 2 * halo
i1(nrmdim) = hypocenter(nrmdim)
i2(nrmdim) = hypocenter(nrmdim)
j1 = i1(1); k1 = i1(2); l1 = i1(3)
j2 = i2(1); k2 = i2(2); l2 = i2(3)
i1(nrmdim) = hypocenter(nrmdim) + 1
i2(nrmdim) = hypocenter(nrmdim) + 1
j3 = i3(1); k3 = i3(2); l3 = i3(3)
j4 = i4(1); k4 = i4(2); l4 = i4(3)
j = nmf(1); k = nmf(2); l = nmf(3)
deallocate( tt0nsd, w0, str, dip )
allocate( tt(j,k,l,3), tn3(j,k,l,3), tn(j,k,l), ts3(j,k,l,3), ts(j,k,l), ff(j,k,l), ff2(j,k,l) )

end subroutine

subroutine fault( it dt nclramp vrup v w1 rho hypocenter )

! Zero slip velocity condition
tmp = area * ( rho(j1:j2,k1:k2,l1:l2) + rho(j3:j4,k3:k4,l3:l4) )
where ( tmp /= 0. ) tmp = 1. / tmp
do i = 1, 3
  tt(:,:,:,i) = tt0(:,:,:,i) + tmp * &
    ( v(j3:j4,k3:k4,l3:l4,i) + w1(j3:j4,k3:k4,l3:l4,i) &
    - v(j1:j2,k1:k2,l1:l2,i) - w1(j1:j2,k1:k2,l1:l2,i) )
end do
tn = sum( tt * nrm, 4 )
do i = 1, 3
  tn3(:,:,:,i) = tn * nrm(:,:,:,i)
end do
ts3 = tt - tn3
ts = sqrt( sum( ts3 * ts3, 4 ) )
!if 0 ! Fault opening 
!  forall( i=1:3 ) tt(:,:,:,i) = tt(:,:,:,i) + tmp * &
!    ( u(j3:j4,k3:k4,l3:l4,i) - u(j1:j2,k1:k2,l1:l2,i) ) / dt
!  tn = sum( tt * nrm, 4 )
!  where( tn > cohes ) tn = cohes
!  forall( i = 1:3 ) tn3(:,:,:,i) = tn * nrm(:,:,:,i)
!end if
! Friction Law
tn = -tn
where( tn < 0. ) tn = 0.
ff = fd
where( uslip < dc ) ff = ff + ( 1. - uslip / dc ) * ( fs - fd )
ff = ff * tn + cohes
! Nucleation
if ( rcrit > 0. .and. vrup > 0. )
  c = 1.
  if ( nclramp > 0 ) c = min( ( it * dt - r / vrup ) / ( nclramp * dt ), 1 )
  ff2 = ( 1 - c ) * ts + c * ( fd * tn + cohes )
  where ( r < min( rcrit, it * dt * vrup ) .and. ff2 < ff ) ff = ff2
end if
! Shear traction bounded by friction
!if find( ff <= 0 ), fprintf( 'fault opening!\n' ), end
tmp = 1.
where ( ts > ff ) tmp = ff / ts
do i = 1, 3
  tt(:,:,:,i) = -tt0(:,:,:,i) + tn3(:,:,:,i) + tmp * ts3(:,:,:,i)
  w1(j1:j2,k1:k2,l1:l2,i) = &
  w1(j1:j2,k1:k2,l1:l2,i) + tt(:,:,:,i) * area * rho(j1:j2,k1:k2,l1:l2)
  w1(j3:j4,k3:k4,l3:l4,i) = &
  w1(j3:j4,k3:k4,l3:l4,i) + tt(:,:,:,i) * area * rho(j3:j4,k3:k4,l3:l4)
end do
tt = v(j3:j4,k3:k4,l3:l4,:) + w1(j3:j4,k3:k4,l3:l4,:) &
   - v(j1:j2,k1:k2,l1:l2,:) - w1(j1:j2,k1:k2,l1:l2,:)
vslip = sqrt( sum( tt * tt, 4 ) )

if ( truptol > 0. ) where ( trup = 0. .and. vslip > truptol ) trup = ( it + .5 ) * dt

end subroutine

end module

