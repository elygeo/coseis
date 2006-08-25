! Material model
module m_material
implicit none
contains

subroutine material
use m_globals
use m_collectiveio
use m_zone
use m_bc
real :: x1(3), x2(3)
integer :: i1(3), i2(3), i3(3), i4(3), i, j, k, l, &
  j1, k1, l1, j2, k2, l2, iz, idoublenode

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
i3 = max( i1, i1node )
i4 = min( i2, i2node )

select case( intype(iz) )
case( 'z' )
  j1 = i3(1); j2 = i4(1)
  k1 = i3(2); k2 = i4(2)
  l1 = i3(3); l2 = i4(3)
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
    if ( ihypo(i) < i3(i) ) then
      if ( ihypo(i) >= i1(i) ) i1(i) = i1(i) + 1
    else
      if ( ihypo(i) <  i2(i) ) i2(i) = i2(i) - 1
      if ( ihypo(i) <= i4(i) ) idoublenode = i
      if ( ihypo(i) <  i4(i) ) i4(i) = i4(i) - 1
    end if
  end if
  j1 = i3(1); j2 = i4(1)
  k1 = i3(2); k2 = i4(2)
  l1 = i3(3); l2 = i4(3)
  select case( fieldin(iz) )
  case( 'rho' )
    call scalario( 'r', 'data/rho', mr, 1, i1, i2, i3, i4, 0 )
    select case( idoublenode )
    case( 1 ); j = ihypo(1); mr(j+1:j2+1,:,:) = mr(j:j2,:,:)
    case( 2 ); k = ihypo(2); mr(:,k+1:k2+1,:) = mr(:,k:k2,:)
    case( 3 ); l = ihypo(3); mr(:,:,l+1:l2+1) = mr(:,:,l:l2)
    end select
  case( 'vp'  )
    call scalario( 'r', 'data/vp', s1, 1, i1, i2, i3, i4, 0 )
    select case( idoublenode )
    case( 1 ); j = ihypo(1); s1(j+1:j2+1,:,:) = s1(j:j2,:,:)
    case( 2 ); k = ihypo(2); s1(:,k+1:k2+1,:) = s1(:,k:k2,:)
    case( 3 ); l = ihypo(3); s1(:,:,l+1:l2+1) = s1(:,:,l:l2)
    end select
  case( 'vs'  )
    call scalario( 'r', 'data/vs', s2, 1, i1, i2, i3, i4, 0 )
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

! Fill halo
call scalarbc( s1, ibc1, ibc2, nhalo )
call scalarbc( s2, ibc1, ibc2, nhalo )
call scalarswaphalo( s1, nhalo )
call scalarswaphalo( s2, nhalo )

! Hypocenter values
if ( master ) then
  j = ihypo(1)
  k = ihypo(2)
  l = ihypo(3)
  rho0 = mr(j,k,l)
  vp0  = s1(j,k,l)
  vs0  = s2(j,k,l)
end if

! Viscosity
if ( vdamp > 0. ) then
  where( s2 > 0. ) gam = vdamp / s2
  where( gam > .8 ) gam = .8
  gam = dt * gam
else
  gam = dt * viscosity(1)
end if

! Lame parameters
mu  = mr * s2 * s2
lam = mr * ( s1 * s1 ) - 2. * mu

end subroutine

end module

