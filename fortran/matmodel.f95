!------------------------------------------------------------------------------!
! SETUP

subroutine matmodel
use globals
integer :: iz, i1(3), i2(3), j1, j2, k1, k2, l1, l2

if ( ipe == 0 ) print '(a)', 'Material Model'
matmax = material(1,1:3)
matmin = material(1,1:3)
do iz = 1, nmat
  call zoneselect( mati(iz,:), npg, i1p, i2p, offset, hypocenter, i1, i2 )
  rho0 = material(iz,1)
  vp   = material(iz,2)
  vs   = material(iz,3)
  matmax = max( matmax, material(iz,1:3) )
  matmin = min( matmin, material(iz,1:3) )
  miu0 = rho0 * vs * vs
  lam0 = rho0 * ( vp * vp - 2 * vs * vs )
  yc0  = miu0 * ( lam0 + miu0 ) / 6 / ( lam0 + 2 * miu0 ) * 4 / dx ^ 2
  !nu  = .5 * lam0 / ( lam0 + miu0 )
  j1 = i1(1); j2 = i2(1) - 1
  k1 = i1(2); k2 = i2(2) - 1
  l1 = i1(3); l2 = i2(3) - 1
  s1(j1:j2,k1:k2,l1:l2) = rho0
  lam(j1:j2,k1:k2,l1:l2) = lam0
  miu(j1:j2,k1:k2,l1:l2) = miu0
  yc(j1:j2,k1:k2,l1:l2) = yc0
end do
courant = dt * matmax(2) * sqrt( 3 ) / dx   ! TODO: check, make general
if ( ipe == 0 ) print *, 'courant: 1 > ', courant
gamma = dt * viscosity

do iz = 1, nop
  call zoneselect( operi(iz,:), npg, i1p, i2p, offset, hypocenter, i1, i2 )
  opi1(iz,:) = i1;
  opi2(iz,:) = i2;
  j1 = i1(1); j2 = i2(1) - 1
  k1 = i1(2); k2 = i2(2) - 1
  l1 = i1(3); l2 = i2(3) - 1
  dfnc( s2, oper(iz), x, x, dx, 1, 1, i1, i2 );
end do
i = hypocenter(nrmdim)
select case ( nrmdim )
case(1); s2(i,:,:) = 0; yc(i,:,:) = 0
case(2); s2(:,i,:) = 0; yc(:,i,:) = 0
case(3); s2(:,:,i) = 0; yc(:,:,i) = 0
end select

if bc(1), ji = i1(1); s1(ji,:,:) = s1(ji+1,:,:); s2(ji,:,:) = s1(ji+1,:,:); end
if bc(4), ji = i2(1); s1(ji,:,:) = s1(ji-1,:,:); s2(ji,:,:) = s1(ji-1,:,:); end
if bc(2), ki = i1(2); s1(:,ki,:) = s1(:,ki+1,:); s2(:,ki,:) = s1(:,ki+1,:); end
if bc(5), ki = i2(2); s1(:,ki,:) = s1(:,ki-1,:); s2(:,ki,:) = s1(:,ki-1,:); end
if bc(3), li = i1(3); s1(:,:,li) = s1(:,:,li+1); s2(:,:,li) = s1(:,:,li+1); end
if bc(6), li = i2(3); s1(:,:,li) = s1(:,:,li-1); s2(:,:,li) = s1(:,:,li-1); end



end subroutine

