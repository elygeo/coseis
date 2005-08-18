!------------------------------------------------------------------------------!
! MATMODEL - Material model setup

subroutine matmodel

use globals
implicit none
integer :: iz
real :: matmin(3), matmax(3), hmean(3), tune, c1, c2, c3, damp, dampn, dampc, yc0, courant

if ( ipe == 0 ) print '(a)', 'Material Model'
i1 = i1node - nhalo
i2 = i2node + nhalo
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
allocate( &
  rho(j1:j2,k1:k2,l1:l2), &
   yn(j1:j2,k1:k2,l1:l2), &
  lam(j1:j2,k1:k2,l1:l2), &
  miu(j1:j2,k1:k2,l1:l2), &
   yc(j1:j2,k1:k2,l1:l2) )
matmax = material(1,1:3)
matmin = material(1,1:3)
do iz = 1, nmat
  call zoneselect( i1, i2, mati(iz,:), npg, hypocenter, nrmdim )
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
if ( ipe == 0 ) print *, 'courant: 1 > ', courant
gam = dt * viscosity

do iz = 1, noper
  call zoneselect( i1, i2, operi(iz,:), npg, hypocenter, nrmdim )
  i1 = max( i1, i1cell )
  i2 = min( i2 - 1, i2cell )
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  call dfnc( s2, oper(iz), x, x, dx, 1, 1, i1, i2 )
end do
i = hypocenter(nrmdim)
select case ( nrmdim )
case(1); s2(i,:,:) = 0; yc(i,:,:) = 0
case(2); s2(:,i,:) = 0; yc(:,i,:) = 0
case(3); s2(:,:,i) = 0; yc(:,:,i) = 0
end select

i1 = i1node - nhalo
i2 = i2node + nhalo
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
if(bc(1)==1) then; s1(j1,:,:) = s1(j1+1,:,:); s2(j1,:,:) = s2(j1+1,:,:); end if
if(bc(4)==1) then; s1(j2,:,:) = s1(j2-1,:,:); s2(j2,:,:) = s2(j2-1,:,:); end if
if(bc(2)==1) then; s1(:,k1,:) = s1(:,k1+1,:); s2(:,k1,:) = s2(:,k1+1,:); end if
if(bc(5)==1) then; s1(:,k2,:) = s1(:,k2-1,:); s2(:,k2,:) = s2(:,k2-1,:); end if
if(bc(3)==1) then; s1(:,:,l1) = s1(:,:,l1+1); s2(:,:,l1) = s2(:,:,l1+1); end if
if(bc(6)==1) then; s1(:,:,l2) = s1(:,:,l2-1); s2(:,:,l2) = s2(:,:,l2-1); end if

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
where ( yn /= 0. )  yn  = dt / yn
where ( rho /= 0. ) rho = dt / rho
where ( s2 /= 0. )  s2  = 1 / s2
lam = lam * s2
miu = miu * s2

! PML damping
j1 = i1node(1); j2 = i2node(1)
k1 = i1node(2); k2 = i2node(2)
l1 = i1node(3); l2 = i2node(3)
if ( bc(1) == 1 ) allocate( p1(1:npml,k1:k2,l1:l2,3) )
if ( bc(4) == 1 ) allocate( p4(1:npml,k1:k2,l1:l2,3) )
if ( bc(2) == 1 ) allocate( p2(j1:k2,1:npml,l1:l2,3) )
if ( bc(5) == 1 ) allocate( p5(j1:k2,1:npml,l1:l2,3) )
if ( bc(3) == 1 ) allocate( p3(j1:k2,k1:k2,1:npml,3) )
if ( bc(6) == 1 ) allocate( p6(j1:k2,k1:k2,1:npml,3) )
j1 = i1cell(1); j2 = i2cell(1)
k1 = i1cell(2); k2 = i2cell(2)
l1 = i1cell(3); l2 = i2cell(3)
if ( bc(1) == 1 ) allocate( g1(1:npml,k1:k2,l1:l2,3) )
if ( bc(4) == 1 ) allocate( g4(1:npml,k1:k2,l1:l2,3) )
if ( bc(2) == 1 ) allocate( g2(j1:k2,1:npml,l1:l2,3) )
if ( bc(5) == 1 ) allocate( g5(j1:k2,1:npml,l1:l2,3) )
if ( bc(3) == 1 ) allocate( g3(j1:k2,k1:k2,1:npml,3) )
if ( bc(6) == 1 ) allocate( g6(j1:k2,k1:k2,1:npml,3) )
allocate( dc1(npml), dn2(npml), dc1(npml), dc2(npml) )
c1 =  8. / 15.
c2 = -3. / 100.
c3 =  1. / 1500.
tune = 3.5
hmean = 2. * matmin * matmax / ( matmin + matmax )
damp = tune * hmean(3) / dx * ( c1 + ( c2 + c3 * npml ) * npml )
! FIXME chech this
do i = 1, npml
  dampn = damp * ( ( npml - i + 1. ) / npml ) ** 2.
  dampc = damp * .5 * ( ( 2. * ( npml - i ) + 1. ) / npml ) ** 2.
  dn1(i) = - 2. * dampn   / ( 2. + dt * dampn )
  dc1(i) = ( 2. - dt * dampc ) / ( 2. + dt * dampc )
  dn2(i) = 2. / ( 2. + dt * dampn )
  dc2(i) = 2. * dt / ( 2. + dt * dampc )
end do

end subroutine

