! Material model
module m_material
implicit none
contains

subroutine material
use m_globals
use m_collectiveio
use m_diffnc
use m_bc
use m_zone
real :: x1(3), x2(3)
integer :: i1(3), i2(3), i1l(3), i2l(3), &
  i, j, k, l, j1, k1, l1, j2, k2, l2, iz, idoublenode

if ( master ) write( 0, * ) 'Material model'

! Input
mr = 0.
s1 = 0.
s2 = 0.

! Loop over input zones

doiz: do iz = 1, nin

! Indices
i1 = i1in(iz,:)
i2 = i2in(iz,:)
call zone( i1, i2, nn, nnoff, ihypo, faultnormal )
i1l = max( i1, i1node )
i2l = min( i2, i2node )

select case( intype(iz) )
case( 'z' )
  j1 = i1l(1); j2 = i2l(1)
  k1 = i1l(2); k2 = i2l(2)
  l1 = i1l(3); l2 = i2l(3)
  select case( fieldin(iz) )
  case( 'rho' ); mr(j1:j2,k1:k2,l1:l2) = inval(iz)
  case( 'vp'  ); s1(j1:j2,k1:k2,l1:l2) = inval(iz)
  case( 'vs'  ); s2(j1:j2,k1:k2,l1:l2) = inval(iz)
  end select
case( 'c' )
  x1 = x1in(iz,:)
  x2 = x2in(iz,:)
  select case( fieldin(iz) )
  case( 'rho' ); call cube( mr, x, i1, i2, x1, x2, inval(iz) )
  case( 'vp'  ); call cube( s1, x, i1, i2, x1, x2, inval(iz) )
  case( 'vs'  ); call cube( s2, x, i1, i2, x1, x2, inval(iz) )
  end select
case( 'r' )
  idoublenode = 0
  if ( faultnormal /= 0 ) then
    i = abs( faultnormal )
    if ( ihypo(i) < i1l(i) ) then
      if ( ihypo(i) >= i1(i) ) i1(i) = i1(i) + 1
    else
      if ( ihypo(i) <  i2(i) ) i2(i) = i2(i) - 1
      if ( ihypo(i) <= i2l(i) ) idoublenode = i
      if ( ihypo(i) <  i2l(i) ) i2l(i) = i2l(i) - 1
    end if
  end if
  j1 = i1l(1); j2 = i2l(1)
  k1 = i1l(2); k2 = i2l(2)
  l1 = i1l(3); l2 = i2l(3)
  select case( fieldin(iz) )
  case( 'rho' )
    call scalario( 'r', 'data/rho', mr, 1, i1, i2, i1l, i2l, 0 )
    select case( idoublenode )
    case( 1 ); j = ihypo(1); mr(j+1:j2+1,:,:) = mr(j:j2,:,:)
    case( 2 ); k = ihypo(2); mr(:,k+1:k2+1,:) = mr(:,k:k2,:)
    case( 3 ); l = ihypo(3); mr(:,:,l+1:l2+1) = mr(:,:,l:l2)
    end select
  case( 'vp'  )
    call scalario( 'r', 'data/vp', s1, 1, i1, i2, i1l, i2l, 0 )
    select case( idoublenode )
    case( 1 ); j = ihypo(1); s1(j+1:j2+1,:,:) = s1(j:j2,:,:)
    case( 2 ); k = ihypo(2); s1(:,k+1:k2+1,:) = s1(:,k:k2,:)
    case( 3 ); l = ihypo(3); s1(:,:,l+1:l2+1) = s1(:,:,l:l2)
    end select
  case( 'vs'  )
    call scalario( 'r', 'data/vs', s2, 1, i1, i2, i1l, i2l, 0 )
    select case( idoublenode )
    case( 1 ); j = ihypo(1); s2(j+1:j2+1,:,:) = s2(j:j2,:,:)
    case( 2 ); k = ihypo(2); s2(:,k+1:k2+1,:) = s2(:,k:k2,:)
    case( 3 ); l = ihypo(3); s2(:,:,l+1:l2+1) = s2(:,:,l:l2)
    end select
  end select
end select

end do doiz

! Extrema
if ( any( mr /= mr ) .or. any( s1 /= s1 ) .or. any( s2 /= s2 ) ) then
  stop 'NaNs in velocity model!'
end if
where ( mr < rho1 ) mr = rho1
where ( mr > rho2 ) mr = rho2
where ( s1 < vp1 ) s1 = vp1
where ( s1 > vp2 ) s1 = vp2
where ( s2 < vs1 ) s2 = vs1
where ( s2 > vs2 ) s2 = vs2
i1 = i1node
i2 = i2node
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
call pmin( rho1, minval( mr(j1:j2,k1:k2,l1:l2) ) )
call pmax( rho2, maxval( mr(j1:j2,k1:k2,l1:l2) ) )
call pmin( vp1,  minval( s1(j1:j2,k1:k2,l1:l2) ) )
call pmax( vp2,  maxval( s1(j1:j2,k1:k2,l1:l2) ) )
call pmin( vs1,  minval( s2(j1:j2,k1:k2,l1:l2) ) )
call pmax( vs2,  maxval( s2(j1:j2,k1:k2,l1:l2) ) )

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

! Harmonic average Lame parameters onto cell centers
call scalarbc( s1, ibc1, ibc2, nhalo )
call scalarbc( s2, ibc1, ibc2, nhalo )
call scalarswaphalo( s1, nhalo )
call scalarswaphalo( s2, nhalo )
lam = 0.
mu = 0.
i1 = i1cell
i2 = i2cell
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
where( s1 > 0. ) s1 = 1. / s1
where( s2 > 0. ) s2 = 1. / s2
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
where( lam > 0. ) lam = 1. / lam
where( mu  > 0. ) mu  = 1. / mu

! Cell volume
s1 = 0.
call diffnc( s1, 'g', x, x, dx, 1, 1, i1cell, i2cell )
select case( ifn )
case( 1 ); j = ihypo(1); s1(j,:,:) = 0.; lam(j,:,:) = 0.; mu(j,:,:) = 0.
case( 2 ); k = ihypo(2); s1(:,k,:) = 0.; lam(:,k,:) = 0.; mu(:,k,:) = 0.
case( 3 ); l = ihypo(3); s1(:,:,l) = 0.; lam(:,:,l) = 0.; mu(:,:,l) = 0.
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
call scalarbc( mr, ibc1, ibc2, nhalo )
call scalarswaphalo( mr, nhalo )

s1 = 0.
s2 = 0.

end subroutine

end module

