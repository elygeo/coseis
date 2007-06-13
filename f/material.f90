! Material model
module m_material
implicit none
contains

subroutine material
use m_globals
use m_collective
use m_util
use m_bc
real :: x1(3), x2(3), stats(6), gstats(6), r
integer :: i1(3), i2(3), i3(3), i4(3), i, j, k, l, j1, k1, l1, j2, k2, l2, iz

if ( master ) write( 0, * ) 'Material model'

! Init
mr = 0.
s1 = 0.
s2 = 0.
gam = 0.

! Loop over input zones
doiz: do iz = 1, nin

! Indices
i1 = i1in(iz,:)
i2 = i2in(iz,:)
call zone( i1, i2, nn, nnoff, ihypo, faultnormal )
i2 = i2 - 1

select case( intype(iz) )
case( 'z' )
  i3 = max( i1, i1node )
  i4 = min( i2, i2cell )
  j1 = i3(1); j2 = i4(1)
  k1 = i3(2); k2 = i4(2)
  l1 = i3(3); l2 = i4(3)
  select case( fieldin(iz) )
  case( 'rho' ); mr(j1:j2,k1:k2,l1:l2)  = inval(iz)
  case( 'vp'  ); s1(j1:j2,k1:k2,l1:l2)  = inval(iz)
  case( 'vs'  ); s2(j1:j2,k1:k2,l1:l2)  = inval(iz)
  case( 'gam' ); gam(j1:j2,k1:k2,l1:l2) = inval(iz)
  end select
case( 'c' )
  i3 = i1node
  i4 = i2cell
  x1 = x1in(iz,:)
  x2 = x2in(iz,:)
  select case( fieldin(iz) )
  case( 'rho' ); call cube( mr,  w2, i3, i4, x1, x2, inval(iz) )
  case( 'vp'  ); call cube( s1,  w2, i3, i4, x1, x2, inval(iz) )
  case( 'vs'  ); call cube( s2,  w2, i3, i4, x1, x2, inval(iz) )
  case( 'gam' ); call cube( gam, w2, i3, i4, x1, x2, inval(iz) )
  end select
case( 'r' )
  i3 = max( i1, i1node )
  i4 = min( i2, i2cell )
  j1 = i3(1); j2 = i4(1)
  k1 = i3(2); k2 = i4(2)
  l1 = i3(3); l2 = i4(3)
  r = 0.
  i = 4 * mpin
  select case( fieldin(iz) )
  case( 'rho' ); call scalario( 'r', 'data/rho', r, mr,  i1, i2, i3, i4, 1, i )
  case( 'vp'  ); call scalario( 'r', 'data/vp',  r, s1,  i1, i2, i3, i4, 1, i )
  case( 'vs'  ); call scalario( 'r', 'data/vs',  r, s2,  i1, i2, i3, i4, 1, i )
  case( 'gam' ); call scalario( 'r', 'data/gam', r, gam, i1, i2, i3, i4, 1, i )
  end select
end select

end do doiz

if ( any( mr /= mr ) .or. any( s1 /= s1 ) .or. any( s2 /= s2 ) ) then
  stop 'NaNs in velocity model!'
end if

! Limits
where ( mr < rho1 ) mr = rho1
where ( mr > rho2 ) mr = rho2
where ( s1 < vp1 ) s1 = vp1
where ( s1 > vp2 ) s1 = vp2
where ( s2 < vs1 ) s2 = vs1
where ( s2 > vs2 ) s2 = vs2

! Extrema
stats(1) =  maxval( mr )
stats(2) =  maxval( s1 )
stats(3) =  maxval( s2 )
call scalarsethalo( mr, stats(1), i1cell, i2cell )
call scalarsethalo( s1, stats(2), i1cell, i2cell )
call scalarsethalo( s2, stats(3), i1cell, i2cell )
call scalarswaphalo( mr, nhalo )
call scalarswaphalo( gam, nhalo )
call scalarswaphalo( s1, nhalo )
call scalarswaphalo( s2, nhalo )
stats(4) = -minval( mr )
stats(5) = -minval( s1 )
stats(6) = -minval( s2 )
call rreduce1( gstats, stats, 'allmax', 0 )
rho2 =  gstats(1)
vp2  =  gstats(2)
vs2  =  gstats(3)
rho1 = -gstats(4)
vp1  = -gstats(5)
vs1  = -gstats(6)

! BCs
call scalarbc( mr,  ibc1, ibc2, nhalo, 1 )
call scalarbc( gam, ibc1, ibc2, nhalo, 1 )
call scalarbc( s1,  ibc1, ibc2, nhalo, 1 )
call scalarbc( s2,  ibc1, ibc2, nhalo, 1 )

! Hypocenter values
if ( master ) then
  j = ihypo(1)
  k = ihypo(2)
  l = ihypo(3)
  rho0 = mr(j,k,l)
  vp0  = s1(j,k,l)
  vs0  = s2(j,k,l)
end if

! Lame' parameters
mu  = mr * s2 * s2
lam = mr * ( s1 * s1 ) - 2. * mu

! Hourglass constant
y = 12. * ( lam + 2. * mu )
where ( y /= 0. ) y = dx * mu * ( lam + mu ) / y
!y = .3 / 16. * ( lam + 2. * mu ) * dx ! like Ma & Liu, 2006

! Viscosity
if ( vdamp > 0. ) then
  where( s2 > 0. ) gam = vdamp / s2
  where( gam > .8 ) gam = .8
end if

end subroutine

!------------------------------------------------------------------------------!

! Calculate PML damping parameters
subroutine pml
use m_globals
integer :: i
real :: hmean, tune, c1, c2, c3, damp, dampn, dampc, pmlp

c1 =  8. / 15.
c2 = -3. / 100.
c3 =  1. / 1500.
tune = 3.5
pmlp = 2.
!hmean = 2. * vp1 * vp2 / ( vp1 + vp2 )
hmean = 2. * vs1 * vs2 / ( vs1 + vs2 )
damp = tune * hmean / dx * ( c1 + ( c2 + c3 * npml ) * npml ) / npml ** pmlp
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

