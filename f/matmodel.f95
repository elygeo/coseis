!------------------------------------------------------------------------------!
! MATMODEL - Material model setup

module matmodel_m
contains
subroutine matmodel
use globals_m
use zone_m
use dfnc_m

implicit none
integer :: iz
real :: matmin(3), matmax(3), hmean(3), tune, c1, c2, c3, damp, dampn, dampc, yc0, courant, pmlp

if ( verb > 0 ) print '(a)', 'Material Model'
matmax = material(1,1:3)
matmin = material(1,1:3)
s1 = 0.
do iz = 1, nmat
  call zone( i1, i2, imat(iz,:), nn, offset, hypocenter, nrmdim )
  i1 = max( i1, i1cell )
  i2 = min( i2 - 1, i2cell )
  rho0 = material(iz,1)
  vp   = material(iz,2)
  vs   = material(iz,3)
  matmax = max( matmax, material(iz,1:3) )
  matmin = min( matmin, material(iz,1:3) )
  miu0 = rho0 * vs * vs
  lam0 = rho0 * ( vp * vp - 2 * vs * vs )
  yc0  = miu0 * ( lam0 + miu0 ) / 6. / ( lam0 + 2. * miu0 ) * 4. / dx ** 2.
  !nu  = .5 * lam0 / ( lam0 + miu0 )
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  s1(j1:j2,k1:k2,l1:l2) = rho0
  lam(j1:j2,k1:k2,l1:l2) = lam0
  miu(j1:j2,k1:k2,l1:l2) = miu0
  yc(j1:j2,k1:k2,l1:l2) = yc0
end do
courant = dt * matmax(2) * sqrt( 3. ) / dx   ! TODO: check, make general
if ( verb > 0 ) print '(a,f5.2)', 'Courant: 1 > ', courant
gam = dt * viscosity

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
  case( 1 ); s2(i,:,:) = 0; yc(i,:,:) = 0
  case( 2 ); s2(:,i,:) = 0; yc(:,i,:) = 0
  case( 3 ); s2(:,:,i) = 0; yc(:,:,i) = 0
  end select
end if

i2 = nm - 1
j1 = i2(1); j2 = i2(1) - 1
k1 = i2(2); k2 = i2(2) - 1
l1 = i2(3); l2 = i2(3) - 1
if( bc(1) == 1 ) then; s1(1,:,: ) = s1(2,:,: ); s2(1,:,: ) = s2(2,:,: ); end if
if( bc(4) == 1 ) then; s1(j1,:,:) = s1(j2,:,:); s2(j1,:,:) = s2(j2,:,:); end if
if( bc(2) == 1 ) then; s1(:,1,: ) = s1(:,2,: ); s2(:,1,: ) = s2(:,2,: ); end if
if( bc(5) == 1 ) then; s1(:,k1,:) = s1(:,k2,:); s2(:,k1,:) = s2(:,k2,:); end if
if( bc(3) == 1 ) then; s1(:,:,1 ) = s1(:,:,2 ); s2(:,:,1 ) = s2(:,:,2 ); end if
if( bc(6) == 1 ) then; s1(:,:,l1) = s1(:,:,l2); s2(:,:,l1) = s2(:,:,l2); end if

i1 = i1node
i2 = i2node
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  yn(j,k,l) = 0.125 * &
  ( s1(j,k,l) + s1(j-1,k-1,l-1) &
  + s1(j-1,k,l) + s1(j,k-1,l-1) &
  + s1(j,k-1,l) + s1(j-1,k,l-1) &
  + s1(j,k,l-1) + s1(j-1,k-1,l) )
end forall
s1 = s1 * s2

forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  rho(j,k,l) = 0.125 * &
  ( s1(j,k,l) + s1(j-1,k-1,l-1) &
  + s1(j-1,k,l) + s1(j,k-1,l-1) &
  + s1(j,k-1,l) + s1(j-1,k,l-1) &
  + s1(j,k,l-1) + s1(j-1,k-1,l) )
end forall

where ( yn /= 0. )  yn  = 1. / yn
where ( rho /= 0. ) rho = 1. / rho
where ( s2 /= 0. )  s2  = 1. / s2
lam = lam * s2
miu = miu * s2

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

