!------------------------------------------------------------------------------!
! MATMODEL - Material model setup

module matmodel_m
contains
subroutine matmodel
use globals_m
use dfnc_m
use zone_m
use binio_m

implicit none
integer :: iz

if ( ip == 0 ) print '(a)', 'Material model'

! Material arrays
mr = 0.
s1 = 0.
s2 = 0.
if ( matdir /= '' ) then
  i1 = i1cell
  i2 = i2cell + 1
  call bread3( matdir, 'rho', mr, i1, i2 )
  call bread3( matdir, 'vp',  s1, i1, i2 )
  call bread3( matdir, 'vs',  s2, i1, i2 )
end if
do iz = 1, nmat
  call zone( i1, i2, imat(iz,:), nn, offset, hypocenter, nrmdim )
  i1 = max( i1, i1cell )
  i2 = min( i2, i2cell + 1 )
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  mr(j1:j2,k1:k2,l1:l2) = material(iz,1)
  s1(j1:j2,k1:k2,l1:l2)  = material(iz,2)
  s2(j1:j2,k1:k2,l1:l2)  = material(iz,3)
end do

! Material extremes
matmin(1) = minval( mr, mr > 0. ); matmax(1) = maxval( mr )
matmin(2) = minval( s1, s1 > 0. ); matmax(2) = maxval( s1 )
matmin(3) = minval( s2, s2 > 0. ); matmax(3) = maxval( s2 )

! Lame parameters
s2 = mr * s2 * s2
s1 = mr * ( s1 * s1 ) - 2. * s2

! Save mu at hypocenter
if ( hypop ) then
  i1 = hypocenter
  if ( hypop ) mu0 = s2( i1(1), i1(2), i1(3) )
end if

! Average Lame parameters onto cell centers
lam = 0.
mu = 0.
i1 = i1cell
i2 = i2cell
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  lam(j,k,l) = 0.125 * &
    ( s1(j,k,l) + s1(j+1,k+1,l+1) &
    + s1(j+1,k,l) + s1(j,k+1,l+1) &
    + s1(j,k+1,l) + s1(j+1,k,l+1) &
    + s1(j,k,l+1) + s1(j+1,k+1,l) )
  mu(j,k,l) = 0.125 * &
    ( s2(j,k,l) + s2(j+1,k+1,l+1) &
    + s2(j+1,k,l) + s2(j,k+1,l+1) &
    + s2(j,k+1,l) + s2(j+1,k,l+1) &
    + s2(j,k,l+1) + s2(j+1,k+1,l) )
end forall

! Cell volume
s2 = 0.
do iz = 1, noper
  i1 = max( i1oper(iz,:),     i1cell )
  i2 = min( i2oper(iz,:) - 1, i2cell )
  call dfnc( s2, oper(iz), x, x, dx, 1, 1, i1, i2 )
end do
if ( nrmdim /=0 ) then
  i = hypocenter(nrmdim)
  select case( nrmdim )
  case( 1 ); s2(i,:,:) = 0;
  case( 2 ); s2(:,i,:) = 0;
  case( 3 ); s2(:,:,i) = 0;
  end select
end if

! Node volume
s1 = 0.
i1 = i1node
i2 = i2node
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  s1(j,k,l) = 0.125 * &
    ( s2(j,k,l) + s2(j-1,k-1,l-1) &
    + s2(j-1,k,l) + s2(j,k-1,l-1) &
    + s2(j,k-1,l) + s2(j-1,k,l-1) &
    + s2(j,k,l-1) + s2(j-1,k-1,l) )
end forall

! Hourglass constant - FIXME off by factor of 8?
y = 6. * dx * dx * ( lam + 2. * mu )
where ( y /= 0. ) y = 4. * mu * ( lam + mu ) / y * s2

! Divide Lame parameters by cell volume
where ( s2 /= 0. ) s2 = 1. / s2
lam = lam * s2
mu = mu * s2

! Node mass ratio
mr = mr * s1
where ( mr /= 0. ) mr = 1. / mr

s1 = 0.
s2 = 0.

end subroutine
end module

