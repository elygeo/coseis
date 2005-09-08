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

if ( ip == 0 ) print '(a)', 'Material Model'

! Material arrays
rho = 0.
s1 = 0.
s2 = 0.
if ( matdir /= '' ) then
  i1 = i1cell
  i2 = i2cell + 1
  call bread( 'rho', matdir, i1, i2 )
  call bread( 'vp',  matdir, i1, i2 )
  call bread( 'vs',  matdir, i1, i2 )
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
matmin(1) = minval( rho ); matmax(1) = maxval( rho )
matmin(2) = minval( s1  ); matmax(2) = maxval( s1  )
matmin(3) = minval( s2  ); matmax(3) = maxval( s2  )

! Cells
i1 = i1cell
i2 = i2cell
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

! Lame parameters
s2 = rho * s2 * s2
s1 = rho * ( s1 * s1 ) - 2. * s2
mu  = 0.
lam = 0.
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

! Check Courant stability condition. TODO: make general, global
courant = dt * matmax(2) * sqrt( 3. ) / dx
if ( ip == 0 ) print '(a,es11.4)', '  Courant: 1 >', courant

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

! Make sure cell volumes and Y are zero on the fault
if ( nrmdim /=0 ) then
  i = hypocenter(nrmdim)
  select case( nrmdim )
  case( 1 ); s2(i,:,:) = 0; y(i,:,:) = 0
  case( 2 ); s2(:,i,:) = 0; y(:,i,:) = 0
  case( 3 ); s2(:,:,i) = 0; y(:,:,i) = 0
  end select
end if

! Ghost cell volumes are NOT zero for PML
i2 = i2cell + 1
j1 = i2(1); j2 = i2(1) - 1
k1 = i2(2); k2 = i2(2) - 1
l1 = i2(3); l2 = i2(3) - 1
if( bc(1) == 1 ) s2(1,:,: ) = s2(2,:,: )
if( bc(4) == 1 ) s2(j1,:,:) = s2(j2,:,:)
if( bc(2) == 1 ) s2(:,1,: ) = s2(:,2,: )
if( bc(5) == 1 ) s2(:,k1,:) = s2(:,k2,:)
if( bc(3) == 1 ) s2(:,:,1 ) = s2(:,:,2 )
if( bc(6) == 1 ) s2(:,:,l1) = s2(:,:,l2)

! Nodes
i1 = i1node
i2 = i2node
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

! Node volume
s1 = 0.
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  s1(j,k,l) = 0.125 * &
  ( s2(j,k,l) + s2(j-1,k-1,l-1) &
  + s2(j-1,k,l) + s2(j,k-1,l-1) &
  + s2(j,k-1,l) + s2(j-1,k,l-1) &
  + s2(j,k,l-1) + s2(j-1,k-1,l) )
end forall

! Hourglass constant
y = 0.
where ( lam /= 0. .and. mu /= 0 ) 
   y = mu * ( lam + mu ) / ( lam + 2. * mu ) * dx / 12.
end where

! Save mu at hypocenter
i1 = hypocenter
if ( hypop ) mu0 = mu( i1(1), i1(2), i1(3) )

! Divide by volumes
where ( s1 /= 0. .and. rho /= 0. )
  rho = 1. / rho / s1
end where
where ( s2 /= 0. )
  lam = lam / s2
  mu = mu / s2
end where

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

