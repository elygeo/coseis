! Material model
module m_material
implicit none
contains

subroutine material
use m_globals
use m_collective
use m_util
use m_bc
real :: x1(3), x2(3), stats(8), gstats(8), r
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
i3 = max( i1, i1core )
i4 = min( i2, i2core )
j1 = i3(1); j2 = i4(1)
k1 = i3(2); k2 = i4(2)
l1 = i3(3); l2 = i4(3)

select case( intype(iz) )
case( 'z' )
  select case( fieldin(iz) )
  case( 'rho' ); mr(j1:j2,k1:k2,l1:l2)  = inval(iz)
  case( 'vp'  ); s1(j1:j2,k1:k2,l1:l2)  = inval(iz)
  case( 'vs'  ); s2(j1:j2,k1:k2,l1:l2)  = inval(iz)
  case( 'gam' ); gam(j1:j2,k1:k2,l1:l2) = inval(iz)
  end select
case( 'c' )
  x1 = x1in(iz,:)
  x2 = x2in(iz,:)
  select case( fieldin(iz) )
  case( 'rho' ); call cube( mr,  w2, i3, i4, x1, x2, inval(iz) )
  case( 'vp'  ); call cube( s1,  w2, i3, i4, x1, x2, inval(iz) )
  case( 'vs'  ); call cube( s2,  w2, i3, i4, x1, x2, inval(iz) )
  case( 'gam' ); call cube( gam, w2, i3, i4, x1, x2, inval(iz) )
  end select
case( 'r' )
  i = mpin * 4
  select case( fieldin(iz) )
  case( 'rho' ); call rio3( -1, i, r, 'data/rho', mr,  i1, i2, i3, i4, 1, 1 )
  case( 'vp'  ); call rio3( -1, i, r, 'data/vp',  s1,  i1, i2, i3, i4, 1, 1 )
  case( 'vs'  ); call rio3( -1, i, r, 'data/vs',  s2,  i1, i2, i3, i4, 1, 1 )
  case( 'gam' ); call rio3( -1, i, r, 'data/gam', gam, i1, i2, i3, i4, 1, 1 )
  end select
end select

end do doiz

! Test for Nans
if ( any( mr  /= mr  ) .or. any( s1 /= s1 ) &
.or. any( gam /= gam ) .or. any( s2 /= s2 ) ) then
  stop 'NaNs in velocity model!'
end if

! Fill halo. Be very careful here! Boundary may extend into next to last processor.
! Use mirror BC at surface for re-sampling gam
i1 = 2
i2 = 2
call scalarswaphalo( mr,  nhalo )
call scalarswaphalo( s1,  nhalo )
call scalarswaphalo( s2,  nhalo )
call scalarswaphalo( gam, nhalo )
call scalarbc( mr,  i1, i2, i1bc, i2bc, 1 )
call scalarbc( s1,  i1, i2, i1bc, i2bc, 1 )
call scalarbc( s2,  i1, i2, i1bc, i2bc, 1 )
call scalarbc( gam, i1, i2, i1bc, i2bc, 1 )

! Limits
if ( rho1 > 0. ) where ( mr < rho1 ) mr = rho1
if ( rho2 > 0. ) where ( mr > rho2 ) mr = rho2
if ( vp1  > 0. ) where ( s1 < vp1  ) s1 = vp1
if ( vp2  > 0. ) where ( s1 > vp2  ) s1 = vp2
if ( vs1  > 0. ) where ( s2 < vs1  ) s2 = vs1
if ( vs2  > 0. ) where ( s2 > vs2  ) s2 = vs2

! Velocity dependent viscosity
if ( vdamp > 0. ) where( s2 > 0. ) gam = vdamp / s2

! Limits
if ( gam1 > 0. ) where ( gam < gam1 ) gam = gam1
if ( gam2 > 0. ) where ( gam > gam2 ) gam = gam2

! Stats
stats(1) =  maxval( mr  )
stats(2) =  maxval( s1  )
stats(3) =  maxval( s2  )
stats(4) =  maxval( gam )
i1 = 1
i2 = nm - 1
call scalarsethalo( mr,  stats(1), i1, i2 )
call scalarsethalo( s1,  stats(2), i1, i2 )
call scalarsethalo( s2,  stats(3), i1, i2 )
call scalarsethalo( gam, stats(4), i1, i2 )
stats(5) = -minval( mr  )
stats(6) = -minval( s1  )
stats(7) = -minval( s2  )
stats(8) = -minval( gam )
call rreduce1( gstats, stats, 'allmax', 0 )
rho2 =  gstats(1)
vp2  =  gstats(2)
vs2  =  gstats(3)
gam2 =  gstats(4)
rho1 = -gstats(5)
vp1  = -gstats(6)
vs1  = -gstats(7)
gam1 = -gstats(8)

! Hypocenter values
if ( master ) then
  j = ihypo(1)
  k = ihypo(2)
  l = ihypo(3)
  rho0 = mr(j,k,l)
  gam0 = gam(j,k,l)
  vp0  = s1(j,k,l)
  vs0  = s2(j,k,l)
end if

! Lame' parameters
mu  = mr * s2 * s2
lam = mr * ( s1 * s1 ) - 2. * mu

! Hourglass constant
yy = 12. * ( lam + 2. * mu )
where ( yy /= 0. ) yy = dx * mu * ( lam + mu ) / yy
!yy = .3 / 16. * ( lam + 2. * mu ) * dx ! like Ma & Liu, 2006

end subroutine

!------------------------------------------------------------------------------!

! Calculate PML damping parameters
subroutine pml
use m_globals
integer :: i
real :: hmean, tune, c1, c2, c3, damp, dampn, dampc, pmlp

if ( npml < 1 ) return
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

