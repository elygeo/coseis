!------------------------------------------------------------------------------!
! MATERIAL

module material_m
contains
subroutine material
use globals_m
use parallelio_m
use diffnc_m
use zone_m

implicit none
integer :: i, j, k, l, i1(3), j1, k1, l1, i2(3), j2, k2, l2, iz

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

doi: do i = 1, nin

ifreadfile: if ( readfile(i) ) then

i1 = i1cell
i2 = i2cell + 1
select case ( fieldin(i) )
case ( 'rho' ); call ioscalar( 'r', 'data/rho', mr, i1, i2, n, noff )
case ( 'vp'  ); call ioscalar( 'r', 'data/vp',  s1, i1, i2, n, noff )
case ( 'vs'  ); call ioscalar( 'r', 'data/vs',  s2, i1, i2, n, noff )
end select
if ( ifn /= 0 ) then
if ( ihypo(ifn) >= i1(ifn) .and. ihypo(ifn) < i2(ifn) ) then
  i = ihypo(ifn)
  select case( ifn )
  case( 1 )
    mr(i+1:j2,:,:,:) = mr(i:j2-1,:,:,:)
    s1(i+1:j2,:,:,:) = s1(i:j2-1,:,:,:)
    s2(i+1:j2,:,:,:) = s2(i:j2-1,:,:,:)
  case( 2 )
    mr(:,i+1:k2,:,:) = mr(:,i:k2-1,:,:)
    s1(:,i+1:k2,:,:) = s1(:,i:k2-1,:,:)
    s2(:,i+1:k2,:,:) = s2(:,i:k2-1,:,:)
  case( 3 )
    mr(:,:,i+1:l2,:) = mr(:,:,i:l2-1,:)
    s1(:,:,i+1:l2,:) = s1(:,:,i:l2-1,:)
    s2(:,:,i+1:l2,:) = s2(:,:,i:l2-1,:)
  end select
end if
end if
rho = minval( mr, mr > 0. )
vp = minval( s1, s1 > 0. )
vs = minval( s2, s2 > 0. )
if ( rho < rho1 ) print *, 'Warning: rho excedes min: ', rho, rho1
if ( vp < vp1 )   print *, 'Warning: vp excedes min: ',  vp, vp1
if ( vs < vs1 )   print *, 'Warning: vs excedes min: ',  vs, vs1
rho = maxval( mr )
vp  = maxval( s1 )
vs  = maxval( s2 )
if ( rho > rho2 ) print *, 'Warning: rho excedes max: ', rho, rho2
if ( vp > vp2 )   print *, 'Warning: vp excedes max: ',  vp, vp2
if ( vs > vs2 )   print *, 'Warning: vs excedes max: ',  vs, vs2

else

call zone( i1in(i,:), i2in(i,:), nn, nnoff, ihypo, ifn )
i1 = max( i1in(i,:), i1cell )
i2 = min( i2in(i,:), i2cell + 1 )
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
select case ( fieldin(i) )
case ( 'rho' )
  mr(j1:j2,k1:k2,l1:l2) = inval(i)
  rho1 = min( rho1, inval(i) )
  rho2 = max( rho2, inval(i) )
case ( 'vp'  )
  s1(j1:j2,k1:k2,l1:l2) = inval(i)
  vp1 = min( rho1, inval(i) )
  vp2 = max( rho2, inval(i) )
case ( 'vs'  )
  s2(j1:j2,k1:k2,l1:l2) = inval(i)
  vs1 = min( rho1, inval(i) )
  vs2 = max( rho2, inval(i) )
end select

end if ifreadfile

end do doi

! Fault plane split nodes

! Hypocenter values
if ( master ) then
  j = ihypo(1)
  k = ihypo(2)
  l = ihypo(3)
  rho = mr(j,k,l)
  vp  = s1(j,k,l)
  vs  = s2(j,k,l)
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
s2 = 0.
do iz = 1, noper
  i1 = max( i1oper(iz,:),     i1cell )
  i2 = min( i2oper(iz,:) - 1, i2cell )
  call diffnc( s2, oper(iz), x, x, dx, 1, 1, i1, i2 )
end do
if ( ifn /=0 ) then
  i = ihypo(ifn)
  select case( ifn )
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

! Hourglass constant
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

