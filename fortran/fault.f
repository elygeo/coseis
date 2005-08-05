!------------------------------------------------------------------------------!
! FAULT

module fault_m

implicit none
private
real, public :: uslip(:,:,:), vslip(:,:,:), trup(:,:,:)
real :: fs(:,:,:), fd(:,:,:), dc(:,:,:), cohes(:,:,:), s0(:,:,:,:), &
  tt0nsd(:,:,:,:), r(:,:,:), str(:,:,:,:), dip(:,:,:,:), tt0(:,:,:,:)
integer :: i, j, k, l, nf(3), sc(3)

contains

subroutine fault_init

use snormals_m

write(*,*) 'Initialize fault'
nf = nm
nf(nrmdim) = 1
j = nf(1)
k = nf(2)
l = nf(3)
allocate( fs(j,k,l), fd(j,k,l), dc(j,k,l), cohes(j,k,l), s0(j,k,l,6), &
  tt0nsd(j,k,l,3), uslip(j,k,l), vslip(j,k,l), trup(j,k,l), r(j,k,l,3), &
  str(j,k,l,3), dip(j,k,l,3), tt0(j,k,l,3), c(j,k,l) )
fs     = 0.
fd     = 0.
dc     = 0.
cohes  = 1e9
s0     = 0.
tt0nsd = 0.
uslip  = 0.
vslip  = 0.
trup   = 0.
r      = 0.
str    = 0.
dip    = 0.
tt0    = 0.

do iz = 1, nfric
  zoneselect( frici(iz,:), halo, np, hypocenter, nrmdim, i1, i2 )
  i1 = max( i1, i1pml )
  i2 = min( i2, i2pml )
  i1(nrmdim) = 1
  i2(nrmdim) = 1
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    fs(j,k,l)    = friction(iz,1)
    fd(j,k,l)    = friction(iz,2)
    dc(j,k,l)    = friction(iz,3)
    cohes(j,k,l) = friction(iz,4)
  end forall
end do
do iz = 1, ntrac
  zoneselect( traci(iz,:), halo, np, hypocenter, nrmdim, i1, i2 )
  i1 = max( i1, i1pml )
  i2 = min( i2, i2pml )
  i1(nrmdim) = 1
  i2(nrmdim) = 1
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    tt0nsd(j,k,l,1) = traction(iz,1)
    tt0nsd(j,k,l,2) = traction(iz,2)
    tt0nsd(j,k,l,3) = traction(iz,3)
  end forall
end do
do iz = 1, nstress
  zoneselect( stressi(iz,:), halo, np, hypocenter, nrmdim, i1, i2 )
  i1 = max( i1, i1pml )
  i2 = min( i2, i2pml )
  i1(nrmdim) = 1
  i2(nrmdim) = 1
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    s0(j,k,l,1) = stress(iz,1)
    s0(j,k,l,2) = stress(iz,2)
    s0(j,k,l,3) = stress(iz,3)
    s0(j,k,l,4) = stress(iz,4)
    s0(j,k,l,5) = stress(iz,5)
    s0(j,k,l,6) = stress(iz,6)
  end forall
end do
i1 = halo + (/ 1 1 1 /)
i2 = halo + np
i1(nrmdim) = 1
i2(nrmdim) = 1
j = i1(1):i2(1)
k = i1(2):i2(2)
l = i1(3):i2(3)
i1(nrmdim) = hypocenter(nrmdim)
i2(nrmdim) = hypocenter(nrmdim)
j1 = i1(1):i2(1)
k1 = i1(2):i2(2)
l1 = i1(3):i2(3)
call snormals( x, i1, i2, nrm )
area = sqrt( sum( nrm * nrm, 4 ) )
where ( area /= 0 ) tmp = 1 / area
forall ( i = 1:3 ) nrm(j,k,l,i) = nrm(j,k,l,i) * tmp
if ( nrmdim /= downdim ) then
  dipdim = downdim
  strdim = 6 - dipdim - nrmdim
else
  strdim = mod( nrmdim, 3 ) + 1
  dipdim = 6 - strdim - nrmdim
end if
down = (/ 0, 0, 0 /)
down(downdim) = 1
sc = (/ 0, 1, -1, -1, 0, 1, 1, -1, 0 /)
handed = c(3*(nrmdim-1),strdim)
str(:,:,:,1) = down(2) * nrm(:,:,:,3) - down(3) * nrm(:,:,:,2)
str(:,:,:,2) = down(3) * nrm(:,:,:,1) - down(1) * nrm(:,:,:,3)
str(:,:,:,3) = down(1) * nrm(:,:,:,2) - down(2) * nrm(:,:,:,1)
tmp = sqrt( sum( str(j,k,l,:) * str(j,k,l,:), 4 ) )
where ( tmp /= 0 ) tmp = handed / tmp
forall ( i = 1:3 ) str(j,k,l,i) = str(j,k,l,i) * tmp
dip(:,:,:,1) = nrm(2) * str(:,:,:,3) - nrm(3) * str(:,:,:,2)
dip(:,:,:,2) = nrm(3) * str(:,:,:,1) - nrm(1) * str(:,:,:,3)
dip(:,:,:,3) = nrm(1) * str(:,:,:,2) - nrm(2) * str(:,:,:,1)
tmp = sqrt( sum( dip(j,k,l,:) * dip(j,k,l,:), 4 ) )
where ( tmp /= 0 ) tmp = handed / tmp
forall ( i = 1:3 ) dip(j,k,l,i) = dip(j,k,l,i) * tmp
sc = (/ 1, 6, 5,; 6, 2, 4,; 5, 4, 3 /)
forall( i = 1:3 )
  tt0(j,k,l,i) = ...
    s0(j,k,l,c(1,i)) * nrm(j,k,l,1) + ...
    s0(j,k,l,c(2,i)) * nrm(j,k,l,2) + ...
    s0(j,k,l,c(3,i)) * nrm(j,k,l,3) + ...
    tt0nsd(j,k,l,nrmdim) * nrm(j,k,l,i) + ...
    tt0nsd(j,k,l,strdim) * str(j,k,l,i) + ...
    tt0nsd(j,k,l,dipdim) * dip(j,k,l,i)
end forall
forall( i = 1:3 )
  r(j,k,l,i) = x(j1,k1,l1,i) - x(hypocenter(1),hypocenter(2),hypocenter(3),i)
end forall
r  = sqrt( sum( r * r, 4 ) )
!if nm(1) == 4, r = repmat( r(j,:,:), [ 4 1 1 ] ); end ! 2D cases
!if nm(2) == 4, r = repmat( r(:,k,:), [ 1 4 1 ] ); end ! 2D cases
!if nm(3) == 4, r = repmat( r(:,:,l), [ 1 1 4 ] ); end ! 2D cases
i = hypocenter
i(nrmdim) = 1
j = i(1)
k = i(2)
l = i(3)
tn0 = sum( tt0(j,k,l,:) * nrm(j,k,l,:) )
ts0 = norm( shiftdim( tt0(j,k,l,:) - tn0 * nrm(j,k,l,:) ) )
tn0 = max( -tn0, 0 )
fs0 = fs(j,k,l)
fd0 = fd(j,k,l)
dc0 = dc(j,k,l)
write(*,*) 'S: %g\n', ( tn0 * fs0 - ts0 ) / ( ts0 - tn0 * fd0 )
write(*,*) 'dc: %g > %g\n', dc0, 3 * dx * tn0 * ( fs0 - fd0 ) / miu0
write(*,*) 'rcrit: %g > %g\n', rcrit, miu0 * tn0 * ( fs0 - fd0 ) * dc0 / ( ts0 - tn0 * fd0 ) ^ 2

end subroutine

subroutine fault

!tt0 = 5
!tw = 1
!tt0(2,:,hypocenter(2)) = exp(-((it*dt-tt0)/tw)^2)
i1 = (/ 1, 1, 1 /)
i2 = nm
i1(nrmdim) = hypocenter(nrmdim)
i2(nrmdim) = hypocenter(nrmdim)
j1 = i1(1):i2(1)
k1 = i1(2):i2(2)
l1 = i1(3):i2(3)
i1(nrmdim) = hypocenter(nrmdim) + 1
i2(nrmdim) = hypocenter(nrmdim) + 1
j2 = i1(1):i2(1)
k2 = i1(2):i2(2)
l2 = i1(3):i2(3)
! Zero slip velocity condition
tmp = area * ( rho(j1,k1,l1) + rho(j2,k2,l2) )
i = tmp ~= 0
tmp(i) = 1 / tmp(i)
forall( i = 1:3 ) tt(:,:,:,i) = tt0(:,:,:,i) + ...
    tmp * ( v(j2,k2,l2,i) - v(j1,k1,l1,i) + w1(j2,k2,l2,i) - w1(j1,k1,l1,i) )
tn = sum( tt * nrm, 4 )
forall( i = 1:3 ) tn3(:,:,:,i) = tn * nrm(:,:,:,i)
ts3 = tt - tn3
ts = sum( ts3 * ts3, 4 )
ts = sqrt( ts )
!if 0 ! Fault opening
!  forall( i = 1:3 )
!    tt(:,:,:,i) = tt(:,:,:,i) + tmp * ( u(j2,k2,l2,i) - u(j1,k1,l1,i) ) / dt
!  end forall
!  tn = sum( tt * nrm, 4 )
!  i = tn > cohes(i)
!  tn(i) = cohes(i)
!  forall( i = 1:3 )
!    tn3(:,:,:,i) = tn * nrm(:,:,:,i)
!  end forall
!end if
! Friction Law
cohes1 = cohes
tn1 = -tn
where( tn1 < 0 ) tn1 = 0
c = repmat( 1, size( dc ) )
c = 1
where( uslip < dc ) c = uslip / dc
ff = ( ( 1 - c ) * fs + c * fd ) * tn1 + cohes1
! Nucleation
if ( rcrit > 0 .and. vrup > 0 )
  c = 1
  if ( nclramp > 0 ) c = min( ( it * dt - r / vrup ) / ( nclramp * dt ), 1 )
  ff2 = ( 1 - c ) * ts + c * ( fd * tn1 + cohes1 )
  where ( r < min( rcrit, it * dt * vrup ) .and. ff2 < ff ) ff = ff2
end if
! Shear traction bounded by friction
c = repmat( 1, size( ff ) )
c = 1
!if find( ff <= 0 ), fprintf( 'fault opening!\n' ), end
where ( ts > ff ) c = ff / ts
forall ( i = 1:3 )
  tt(:,:,:,i) = -tt0(:,:,:,i) + tn3(:,:,:,i) + c * ts3(:,:,:,i)
  w1(j1,k1,l1,i) = w1(j1,k1,l1,i) + tt(:,:,:,i) * area * rho(j1,k1,l1)
  w1(j2,k2,l2,i) = w1(j2,k2,l2,i) - tt(:,:,:,i) * area * rho(j2,k2,l2)
end forall
vslip = v(j2,k2,l2,:) + w1(j2,k2,l2,:) - v(j1,k1,l1,:) - w1(j1,k1,l1,:)
vslip = sum( vslip * vslip, 4 )
vslip = sqrt( vslip )

if ( truptol > 0. ) where ( trup = 0 .and. vslip > truptol ) trup = ( it + .5 ) * dt

end subroutine

end module

