! material model
module m_material
implicit none
contains

subroutine material
use m_globals
use m_collective
use m_util
use m_fieldio
real :: vstats(8), gvstats(8), r, rho_, vp_, vs_, gam_, courant
integer :: i1(3), i2(3)

if ( master ) write( *, '(a)' ) 'Material model'

! init
mr = 0.0
lam = 0.0
mu = 0.0
gam = 0.0

! inputs
call fieldio( '<', 'rho', mr  )
call fieldio( '<', 'vp',  lam  )
call fieldio( '<', 'vs',  mu  )
call fieldio( '<', 'gam', gam )
s1 = lam
s2 = mu

! limits
if ( rho1 > 0.0 ) mr = max( mr, rho1 )
if ( rho2 > 0.0 ) mr = min( mr, rho2 )
if ( vp1  > 0.0 ) s1 = max( s1, vp1 )
if ( vp2  > 0.0 ) s1 = min( s1, vp2 )
if ( vs1  > 0.0 ) s2 = max( s2, vs1 )
if ( vs2  > 0.0 ) s2 = min( s2, vs2 )

! velocity dependent viscosity
if ( vdamp > 0.0 ) then
    gam = s2
    call invert( gam )
    gam = gam * vdamp
end if

! limits
if ( gam1 > 0.0 ) gam = max( gam, gam1 )
if ( gam2 > 0.0 ) gam = min( gam, gam2 )

! averages
vstats = 0.0
i1 = max( i1core, i1bc )
i2 = min( i2core, i2bc - 1 )
call set_halo( mr,  0.0, i1, i2 )
call set_halo( s1,  0.0, i1, i2 )
call set_halo( s2,  0.0, i1, i2 )
call set_halo( gam, 0.0, i1, i2 )
vstats(1) = sum( mr  )
vstats(2) = sum( s1  )
vstats(3) = sum( s2  )
vstats(4) = sum( gam )
call rreduce1( gvstats, vstats, 'sum', ip3root )
rho_ = gvstats(1) / product( nn - 1 )
vp_  = gvstats(2) / product( nn - 1 )
vs_  = gvstats(3) / product( nn - 1 )
gam_ = gvstats(4) / product( nn - 1 )

! fill halo
call scalar_swap_halo( mr,  nhalo )
call scalar_swap_halo( s1,  nhalo )
call scalar_swap_halo( s2,  nhalo )
call scalar_swap_halo( gam, nhalo )

! extrema
call set_halo( mr,  huge(r), i1cell, i2cell )
call set_halo( s1,  huge(r), i1cell, i2cell )
call set_halo( s2,  huge(r), i1cell, i2cell )
call set_halo( gam, huge(r), i1cell, i2cell )
vstats(1) = -minval( mr  )
vstats(2) = -minval( s1  )
vstats(3) = -minval( s2  )
vstats(4) = -minval( gam )
call set_halo( mr,  0.0, i1cell, i2cell )
call set_halo( s1,  0.0, i1cell, i2cell )
call set_halo( s2,  0.0, i1cell, i2cell )
call set_halo( gam, 0.0, i1cell, i2cell )
vstats(5) = maxval( mr  )
vstats(6) = maxval( s1  )
vstats(7) = maxval( s2  )
vstats(8) = maxval( gam )
call rreduce1( gvstats, vstats, 'allmax', (/0, 0, 0/) )
rho1 = -gvstats(1)
vp1  = -gvstats(2)
vs1  = -gvstats(3)
gam1 = -gvstats(4)
rho2 =  gvstats(5)
vp2  =  gvstats(6)
vs2  =  gvstats(7)
gam2 =  gvstats(8)

! stats
if ( master ) then
    courant = dt * vp2 * 3.0 / sqrt( sum( dx * dx ) )
    open( 1, file='stats/material.py', status='replace' )
    write( 1, "( 'courant = ',g15.7 )" ) courant
    write( 1, "( 'rho_    = ',g15.7 )" ) rho_
    write( 1, "( 'rho1    = ',g15.7 )" ) rho1
    write( 1, "( 'rho2    = ',g15.7 )" ) rho2
    write( 1, "( 'vp_     = ',g15.7 )" ) vp_
    write( 1, "( 'vp1     = ',g15.7 )" ) vp1
    write( 1, "( 'vp2     = ',g15.7 )" ) vp2
    write( 1, "( 'vs_     = ',g15.7 )" ) vs_
    write( 1, "( 'vs1     = ',g15.7 )" ) vs1
    write( 1, "( 'vs2     = ',g15.7 )" ) vs2
    write( 1, "( 'gam_    = ',g15.7 )" ) gam_
    write( 1, "( 'gam1    = ',g15.7 )" ) gam1
    write( 1, "( 'gam2    = ',g15.7 )" ) gam2
    close( 1 )
end if

! lame' parameters
mu  = mr * s2 * s2
lam = mr * s1 * s1 - 2.0 * mu

! hourglass constant
yy = 12.0 * (lam + 2.0 * mu)
call invert( yy )
yy = yy * sqrt( sum( dx * dx ) / 3.0 ) * mu * (lam + mu)
!yy = 0.3 / 16.0 * ( lam + 2.0 * mu ) * sqrt( sum( dx * dx ) / 3.0 ) ! like Ma & Liu, 2006

! output
call fieldio( '>', 'rho', mr  )
call fieldio( '>', 'vp',  s1  )
call fieldio( '>', 'vs',  s2  )
call fieldio( '>', 'gam', gam )
call fieldio( '>', 'mu',  mu  )
call fieldio( '>', 'lam', lam )
call fieldio( '>', 'yy',  yy  )

end subroutine

!------------------------------------------------------------------------------!

! calculate pml damping parameters
subroutine pml
use m_globals
integer :: i
real :: c1, c2, c3, damp, dampn, dampc, tune

if ( npml < 1 ) return
c1 =  8.0 / 15.0
c2 = -3.0 / 100.0
c3 =  1.0 / 1500.0
tune = 3.5
if ( vpml <= 0.0 ) vpml = 2.0 * vs1 * vs2 / (vs1 + vs2)
damp = tune * vpml / sqrt( sum( dx * dx ) / 3.0 ) * (c1 + (c2 + c3 * npml) * npml) / npml ** ppml
do i = 1, npml
    dampn = damp *  i ** ppml
    dampc = damp * (i ** ppml + (i - 1) ** ppml) * 0.5
    dn1(npml-i+1) = -2.0 * dampn       / (2.0 + dt * dampn)
    dc1(npml-i+1) = (2.0 - dt * dampc) / (2.0 + dt * dampc)
    dn2(npml-i+1) =  2.0               / (2.0 + dt * dampn)
    dc2(npml-i+1) =  2.0 * dt          / (2.0 + dt * dampc)
end do

end subroutine

end module

