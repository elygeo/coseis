!------------------------------------------------------------------------------!
! MATMODEL - Material model setup

module matmodel_m
contains
subroutine matmodel
use globals_m
use dfnc_m
use zone_m
use bread_m

implicit none
integer :: iz
real :: matmin(3), matmax(3), hmean(3), tune, c1, c2, c3, damp, dampn, dampc, courant, pmlp

if ( ip == 0 ) print '(a)', 'Material model'

! Material arrays
rho = 0.
s1 = 0.
s2 = 0.
if ( matdir /= '' ) then
  i1 = i1cell
  i2 = i2cell + 1
  call bread( rho, matdir, 'rho', i1, i2 )
  call bread( s1,  matdir, 'vp',  i1, i2 )
  call bread( s2,  matdir, 'vs',  i1, i2 )
else
  do iz = 1, nmat
    call zone( i1, i2, imat(iz,:), nn, offset, hypocenter, nrmdim )
    i1 = max( i1, i1cell )
    i2 = min( i2, i2cell + 1 )
    j1 = i1(1); j2 = i2(1)
    k1 = i1(2); k2 = i2(2)
    l1 = i1(3); l2 = i2(3)
    rho(j1:j2,k1:k2,l1:l2) = material(iz,1)
    s1(j1:j2,k1:k2,l1:l2)  = material(iz,2)
    s2(j1:j2,k1:k2,l1:l2)  = material(iz,3)
  end do
end if

! Material extremes TODO: make global
matmin(1) = minval( rho, rho > 0. ); matmax(1) = maxval( rho )
matmin(2) = minval( s1, s1 > 0. );   matmax(2) = maxval( s1 )
matmin(3) = minval( s2, s2 > 0. );   matmax(3) = maxval( s2 )

! Check Courant stability condition. TODO: make general
courant = dt * matmax(2) * sqrt( 3. ) / dx
if ( ip == 0 ) print '(a,es11.4)', '  Courant: 1 >', courant

! Lame parameters
s2 = rho * s2 * s2
s1 = rho * ( s1 * s1 ) - 2. * s2

! Save mu at hypocenter
if ( hypop ) then
  i1 = hypocenter
  if ( hypop ) mu0 = mu( i1(1), i1(2), i1(3) )
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
  call zone( i1, i2, ioper(iz,:), nn, offset, hypocenter, nrmdim )
  i1 = max( i1, i1cell )
  i2 = min( i2 - 1, i2cell )
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
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
rho = rho * s1
where ( rho /= 0. ) rho = 1. / rho

s1 = 0.
s2 = 0.

! PML damping
c1 =  8. / 15.
c2 = -3. / 100.
c3 =  1. / 1500.
tune = 3.5
pmlp = 2
hmean = 2. * matmin * matmax / ( matmin + matmax )
damp = tune * hmean(3) / dx * ( c1 + ( c2 + c3 * npml ) * npml ) / npml ** pmlp
do i = 1, npml
  dampn = damp *   i ** pmlp
  dampc = damp * ( i ** pmlp + ( i - 1 ) ** pmlp ) / 2.
  dn1(npml-i+1) = - 2. * dampn        / ( 2. + dt * dampn )
  dc1(npml-i+1) = ( 2. - dt * dampc ) / ( 2. + dt * dampc )
  dn2(npml-i+1) =   2.                / ( 2. + dt * dampn )
  dc2(npml-i+1) =   2. * dt           / ( 2. + dt * dampc )
end do

end subroutine
end module

