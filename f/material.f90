! Material model
module m_material
implicit none
contains

subroutine material
use m_globals
use m_collective
use m_util
real :: x1(3), x2(3), stats(8), gstats(8), r, rr(3)
integer :: i1(3), i2(3), i3(3), i4(3), i, j1, k1, l1, j2, k2, l2, iz

if ( master ) write( 0, * ) 'Material model'

! Init
mr = 0.
s1 = 0.
s2 = 0.
gam = 0.

! Inputs
doiz: do iz = 1, nin
r = inval(iz)
x1 = x1in(iz,:)
x2 = x2in(iz,:)
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
case( 'r' )
  i = mpin * 4
  select case( fieldin(iz) )
  case( 'rho' ); call rio3( -1, i, r, 'data/rho', mr,  i1, i2, i3, i4, 1, 1 )
  case( 'vp'  ); call rio3( -1, i, r, 'data/vp',  s1,  i1, i2, i3, i4, 1, 1 )
  case( 'vs'  ); call rio3( -1, i, r, 'data/vs',  s2,  i1, i2, i3, i4, 1, 1 )
  case( 'gam' ); call rio3( -1, i, r, 'data/gam', gam, i1, i2, i3, i4, 1, 1 )
  end select
case( 'z' )
  select case( fieldin(iz) )
  case( 'rho' ); mr(j1:j2,k1:k2,l1:l2)  = r
  case( 'vp'  ); s1(j1:j2,k1:k2,l1:l2)  = r
  case( 'vs'  ); s2(j1:j2,k1:k2,l1:l2)  = r
  case( 'gam' ); gam(j1:j2,k1:k2,l1:l2) = r
  end select
case( 'c' )
  select case( fieldin(iz) )
  case( 'rho' ); call cube( mr,  w2, i3, i4, x1, x2, r )
  case( 'vp'  ); call cube( s1,  w2, i3, i4, x1, x2, r )
  case( 'vs'  ); call cube( s2,  w2, i3, i4, x1, x2, r )
  case( 'gam' ); call cube( gam, w2, i3, i4, x1, x2, r )
  end select
end select
end do doiz

! Test for endian problems
if ( any( mr  /= mr  ) .or. maxval( mr  ) > huge( r ) ) stop 'NaN/Inf in rho'
if ( any( s1  /= s1  ) .or. maxval( s1  ) > huge( r ) ) stop 'NaN/Inf in vp'
if ( any( s2  /= s2  ) .or. maxval( s2  ) > huge( r ) ) stop 'NaN/Inf in vs'
if ( any( gam /= gam ) .or. maxval( gam ) > huge( r ) ) stop 'NaN/Inf in gam'

! Limits
if ( rho1 > 0. ) mr = max( mr, rho1 )
if ( rho2 > 0. ) mr = min( mr, rho2 )
if ( vp1  > 0. ) s1 = max( s1, vp1 )
if ( vp2  > 0. ) s1 = min( s1, vp2 )
if ( vs1  > 0. ) s2 = max( s2, vs1 )
if ( vs2  > 0. ) s2 = min( s2, vs2 )

! Velocity dependent viscosity
if ( vdamp > 0. ) then
  gam = s2
  call invert( gam )
  gam = gam * vdamp
end if

! Limits
if ( gam1 > 0. ) gam = max( gam, gam1 )
if ( gam2 > 0. ) gam = min( gam, gam2 )

! Averages
stats = 0.
i1 = max( i1core, i1bc )
i2 = min( i2core, i2bc - 1 )
call scalarsethalo( mr,  0., i1, i2 )
call scalarsethalo( s1,  0., i1, i2 )
call scalarsethalo( s2,  0., i1, i2 )
call scalarsethalo( gam, 0., i1, i2 )
stats(1) = sum( mr  )
stats(2) = sum( s1  )
stats(3) = sum( s2  )
stats(4) = sum( gam )
call rreduce1( gstats, stats, 'sum', 0 )
rr = nn - 1
r = 1. / product( rr ) 
rho_ = r * gstats(1)
vp_  = r * gstats(2)
vs_  = r * gstats(3)
gam_ = r * gstats(4)

! Fill halo
call scalarswaphalo( mr,  nhalo )
call scalarswaphalo( s1,  nhalo )
call scalarswaphalo( s2,  nhalo )
call scalarswaphalo( gam, nhalo )

! Extrema
call scalarsethalo( mr,  huge(r), i1cell, i2cell )
call scalarsethalo( s1,  huge(r), i1cell, i2cell )
call scalarsethalo( s2,  huge(r), i1cell, i2cell )
call scalarsethalo( gam, huge(r), i1cell, i2cell )
stats(1) = -minval( mr  )
stats(2) = -minval( s1  )
stats(3) = -minval( s2  )
stats(4) = -minval( gam )
call scalarsethalo( mr,  0., i1cell, i2cell )
call scalarsethalo( s1,  0., i1cell, i2cell )
call scalarsethalo( s2,  0., i1cell, i2cell )
call scalarsethalo( gam, 0., i1cell, i2cell )
stats(5) = maxval( mr  )
stats(6) = maxval( s1  )
stats(7) = maxval( s2  )
stats(8) = maxval( gam )
call rreduce1( gstats, stats, 'allmax', 0 )
rho1 = -gstats(1)
vp1  = -gstats(2)
vs1  = -gstats(3)
gam1 = -gstats(4)
rho2 =  gstats(5)
vp2  =  gstats(6)
vs2  =  gstats(7)
gam2 =  gstats(8)

! Lame' parameters
mu  = mr * s2 * s2
lam = mr * ( s1 * s1 ) - 2. * mu

! Hourglass constant
yy = 12. * ( lam + 2. * mu )
call invert( yy )
yy = yy * dx * mu * ( lam + mu )
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

