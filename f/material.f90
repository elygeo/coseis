! Material model
module material_m
use globals_m
use collectiveio_m
use diffnc_m
use zone_m
contains
subroutine material

implicit none
integer :: i1(3), i2(3), i1l(3), i2l(3), &
  i, j, k, l, j1, k1, l1, j2, k2, l2, iz, idoublenode

if ( master ) then
  open( 9, file='log', position='append' )
  write( 9, * ) 'Material model'
  close( 9 )
end if

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

! Loop over input zones
doiz: do iz = 1, nin

! Indices
i1 = i1in(iz,:)
i2 = i2in(iz,:)
call zone( i1, i2, nn, nnoff, ihypo, ifn )
i1l = max( i1, i1node )
i2l = min( i2, i2node )

if ( .not. readfile(iz) ) then
  j1 = i1l(1); j2 = i2l(1)
  k1 = i1l(2); k2 = i2l(2)
  l1 = i1l(3); l2 = i2l(3)
  select case( fieldin(iz) )
  case( 'rho' )
    mr(j1:j2,k1:k2,l1:l2) = inval(iz)
    rho1 = min( rho1, inval(iz) )
    rho2 = max( rho2, inval(iz) )
  case( 'vp'  )
    s1(j1:j2,k1:k2,l1:l2) = inval(iz)
    vp1 = min( vp1, inval(iz) )
    vp2 = max( vp2, inval(iz) )
  case( 'vs'  )
    s2(j1:j2,k1:k2,l1:l2) = inval(iz)
    vs1 = min( vs1, inval(iz) )
    vs2 = max( vs2, inval(iz) )
  end select
else
  idoublenode = 0
  if ( ifn /= 0 ) then
    if ( ihypo(ifn) < i1l(ifn) ) then
      i1(ifn) = i1(ifn) + 1
    else
      if ( ihypo(ifn) <  i2(ifn)  ) i2(ifn) = i2(ifn) - 1
      if ( ihypo(ifn) <  i2l(ifn) ) i2l(ifn) = i2l(ifn) - 1
      if ( ihypo(ifn) <= i2l(ifn) ) idoublenode = ifn
    end if
  end if
  j1 = i1l(1); j2 = i2l(1)
  k1 = i1l(2); k2 = i2l(2)
  l1 = i1l(3); l2 = i2l(3)
  select case( fieldin(iz) )
  case( 'rho' )
    call ioscalar( 'r', 'data/rho', mr, i1, i2, i1l, i2l, 0 )
    select case( idoublenode )
    case( 1 ); j = ihypo(1); mr(j+1:j2+1,:,:) = mr(j:j2,:,:)
    case( 2 ); k = ihypo(2); mr(:,k+1:k2+1,:) = mr(:,k:k2,:)
    case( 3 ); l = ihypo(3); mr(:,:,l+1:l2+1) = mr(:,:,l:l2)
    end select
    where ( mr < rho1 ) mr = rho1
    where ( mr > rho1 ) mr = rho2
  case( 'vp'  )
    call ioscalar( 'r', 'data/vp', s1, i1, i2, i1l, i2l, 0 )
    select case( idoublenode )
    case( 1 ); j = ihypo(1); s1(j+1:j2+1,:,:) = s1(j:j2,:,:)
    case( 2 ); k = ihypo(2); s1(:,k+1:k2+1,:) = s1(:,k:k2,:)
    case( 3 ); l = ihypo(3); s1(:,:,l+1:l2+1) = s1(:,:,l:l2)
    end select
    where ( s1 < vp1 ) s1 = vp1
    where ( s1 > vp2 ) s1 = vp2
  case( 'vs'  )
    call ioscalar( 'r', 'data/vs', s2, i1, i2, i1l, i2l, 0 )
    select case( idoublenode )
    case( 1 ); j = ihypo(1); s2(j+1:j2+1,:,:) = s2(j:j2,:,:)
    case( 2 ); k = ihypo(2); s2(:,k+1:k2+1,:) = s2(:,k:k2,:)
    case( 3 ); l = ihypo(3); s2(:,:,l+1:l2+1) = s2(:,:,l:l2)
    end select
    where ( s2 < vs1 ) s2 = vs1
    where ( s2 > vs2 ) s2 = vs2
  end select
end if

end do doiz

! Boundary conditions
i1 = i1node
i2 = i2node
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
do i = 1, nhalo
  if ( ibc1(1) == 2 ) then
    mr(j1-i,:,:) = mr(j1+1,:,:)
    s1(j1-i,:,:) = s1(j1+1,:,:)
    s2(j1-i,:,:) = s2(j1+1,:,:)
  elseif ( ibc1(1) == 3 ) then
    mr(j1-i,:,:) = mr(j1,:,:)
    s1(j1-i,:,:) = s1(j1,:,:)
    s2(j1-i,:,:) = s2(j1,:,:)
  end if
  if ( ibc2(1) == 2 ) then
    mr(j2+i,:,:) = mr(j2-1,:,:)
    s1(j2+i,:,:) = s1(j2-1,:,:)
    s2(j2+i,:,:) = s2(j2-1,:,:)
  elseif ( ibc2(1) == 3 ) then
    mr(j2+i,:,:) = mr(j2,:,:)
    s1(j2+i,:,:) = s1(j2,:,:)
    s2(j2+i,:,:) = s2(j2,:,:)
  end if
  if ( ibc1(2) == 2 ) then
    mr(:,k1-i,:) = mr(:,k1+1,:)
    s1(:,k1-i,:) = s1(:,k1+1,:)
    s2(:,k1-i,:) = s2(:,k1+1,:)
  elseif ( ibc1(2) == 3 ) then
    mr(:,k1-i,:) = mr(:,k1,:)
    s1(:,k1-i,:) = s1(:,k1,:)
    s2(:,k1-i,:) = s2(:,k1,:)
  end if
  if ( ibc2(2) == 2 ) then
    mr(:,k2+i,:) = mr(:,k2-1,:)
    s1(:,k2+i,:) = s1(:,k2-1,:)
    s2(:,k2+i,:) = s2(:,k2-1,:)
  elseif ( ibc2(2) == 3 ) then
    mr(:,k2+i,:) = mr(:,k2,:)
    s1(:,k2+i,:) = s1(:,k2,:)
    s2(:,k2+i,:) = s2(:,k2,:)
  end if
  if ( ibc1(3) == 2 ) then
    mr(:,:,l1-i) = mr(:,:,l1+1)
    s1(:,:,l1-i) = s1(:,:,l1+1)
    s2(:,:,l1-i) = s2(:,:,l1+1)
  elseif ( ibc1(3) == 3 ) then
    mr(:,:,l1-i) = mr(:,:,l1)
    s1(:,:,l1-i) = s1(:,:,l1)
    s2(:,:,l1-i) = s2(:,:,l1)
  end if
  if ( ibc2(3) == 2 ) then
    mr(:,:,l2+i) = mr(:,:,l2-1)
    s1(:,:,l2+i) = s1(:,:,l2-1)
    s2(:,:,l2+i) = s2(:,:,l2-1)
  elseif ( ibc2(3) == 3 ) then
    mr(:,:,l2+i) = mr(:,:,l2)
    s1(:,:,l2+i) = s1(:,:,l2)
    s2(:,:,l2+i) = s2(:,:,l2)
  end if
end do
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
select case( ifn )
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
call swaphaloscalar( s2, nhalo )

! Hourglass constant
y = 12. * ( lam + 2. * mu )
where ( y /= 0. ) y = dx * mu * ( lam + mu ) / y
! y = 12. * dx * dx * ( lam + 2. * mu )
! where ( y /= 0. ) y = s1 * mu * ( lam + mu ) / y

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

