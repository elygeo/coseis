! Material model
module material_m
use globals_m
use collectiveio_m
use diffnc_m
use zone_m
contains
subroutine material

implicit none
integer :: i, j, k, l, i1(3), j1, k1, l1, i2(3), j2, k2, l2, iz, &
  n(3), noff(3), idoublenode

if ( master ) print '(a)', 'Material model'

! Input
mr = 0.
s1 = 0.
s2 = 0.
rho1 = 1e9
rho2 = 0.
vp1 = 1e9
vp2 = 0.
vs1 = 1e9
vs2 = 0.

! Single node indexing
n = nn
noff = nnoff
idoublenode = 0
if ( ifn /= 0 ) then
  n(ifn) = n(ifn) - 1
  if ( ihypo(ifn) < i1node(ifn) ) then
    noff = noff + 1
  else if ( ihypo(ifn) < i2node(ifn) ) then
    idoublenode = ifn
  end if
end if

! Loop over input zones
doiz: do iz = 1, nin

! Indices
i1 = i1in(iz,:)
i2 = i2in(iz,:)
call zone( i1, i2, nn, nnoff, ihypo, ifn )
i1 = max( i1, i1node )
i2 = min( i2, i2node )
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

select case( fieldin(iz) )
case( 'rho' )
  if ( .not. readfile(iz) ) then
    mr(j1:j2,k1:k2,l1:l2) = inval(iz)
    rho1 = min( rho1, inval(iz) )
    rho2 = max( rho2, inval(iz) )
  else
    call ioscalar( 'r', 'data/rho', mr, i1, i2, n, noff, 0 )
    select case( idoublenode )
    case( 1 ); j = ihypo(1); mr(j+1:j2,:,:) = mr(j:j2-1,:,:)
    case( 2 ); k = ihypo(2); mr(:,k+1:k2,:) = mr(:,k:k2-1,:)
    case( 3 ); l = ihypo(3); mr(:,:,l+1:l2) = mr(:,:,l:l2-1)
    end select
    where ( mr < rho1 ) mr = rho1
    where ( mr > rho1 ) mr = rho2
  end if
case( 'vp'  )
  if ( .not. readfile(iz) ) then
    s1(j1:j2,k1:k2,l1:l2) = inval(iz)
    vp1 = min( vp1, inval(iz) )
    vp2 = max( vp2, inval(iz) )
  else
    call ioscalar( 'r', 'data/vp', s1, i1, i2, n, noff, 0 )
    select case( idoublenode )
    case( 1 ); j = ihypo(1); s1(j+1:j2,:,:) = s1(j:j2-1,:,:)
    case( 2 ); k = ihypo(2); s1(:,k+1:k2,:) = s1(:,k:k2-1,:)
    case( 3 ); l = ihypo(3); s1(:,:,l+1:l2) = s1(:,:,l:l2-1)
    end select
    where ( s1 < vp1 ) s1 = vp1
    where ( s1 > vp2 ) s1 = vp2
  end if
case( 'vs'  )
  if ( .not. readfile(iz) ) then
    s2(j1:j2,k1:k2,l1:l2) = inval(iz)
    vs1 = min( vs1, inval(iz) )
    vs2 = max( vs2, inval(iz) )
  else
    call ioscalar( 'r', 'data/vs', s2, i1, i2, n, noff, 0 )
    select case( idoublenode )
    case( 1 ); j = ihypo(1); s2(j+1:j2,:,:) = s2(j:j2-1,:,:)
    case( 2 ); k = ihypo(2); s2(:,k+1:k2,:) = s2(:,k:k2-1,:)
    case( 3 ); l = ihypo(3); s2(:,:,l+1:l2) = s2(:,:,l:l2-1)
    end select
    where ( s2 < vs1 ) s2 = vs1
    where ( s2 > vs2 ) s2 = vs2
  end if
end select

end do doiz

call swaphaloscalar( mr, nhalo )
call swaphaloscalar( s1, nhalo )
call swaphaloscalar( s2, nhalo )

! Hypocenter values
if ( master ) then
  j = ihypo(1)
  k = ihypo(2)
  l = ihypo(3)
  rho0 = mr(j,k,l)
  vp0  = s1(j,k,l)
  vs0  = s2(j,k,l)
end if

! Lame parameters
s2 = mr * s2 * s2
s1 = mr * ( s1 * s1 ) - 2. * s2

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
s1 = 0.
call diffnc( s1, 'g', x, x, dx, 1, 1, i1cell, i2cell )
j = ihypo(1)
k = ihypo(2)
l = ihypo(3)
select case( idoublenode )
case( 1 ); s1(j,:,:) = 0.
case( 2 ); s1(:,k,:) = 0.
case( 3 ); s1(:,:,l) = 0.
end select

! Node volume
s2 = 0.
i1 = i1node
i2 = i2node
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  s2(j,k,l) = 0.125 * &
    ( s1(j,k,l) + s1(j-1,k-1,l-1) &
    + s1(j-1,k,l) + s1(j,k-1,l-1) &
    + s1(j,k-1,l) + s1(j-1,k,l-1) &
    + s1(j,k,l-1) + s1(j-1,k-1,l) )
end forall

! Hourglass constant
y = 6. * dx * dx * ( lam + 2. * mu )
where ( y /= 0. ) y = 4. * mu * ( lam + mu ) / y * s1

! Divide Lame parameters by cell volume
where ( s1 /= 0. ) s1 = 1. / s1
lam = lam * s1
mu = mu * s1

! Node mass ratio
mr = mr * s2
where ( mr /= 0. ) mr = 1. / mr

s1 = 0.
s2 = 0.

end subroutine
end module

