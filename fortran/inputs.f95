!------------------------------------------------------------------------------!
! INPUTS

subroutine inputs
use globals
use utils

implicit none
integer :: iostat
character(256) :: buff, key, a

if ( verb > 0 ) print '(a)', 'Reading input file'
npe3 = 1
ipe = 0
npg = 21
nt = 20
dx = 100.
dt = .007
nu = .25
rho0 = 2670.
vp = 6000.
vs = sqrt( vp * vp * ( nu - .5 ) / ( nu - 1 ) )  ! 3464.1
grid = 'constant'
nrmdim = 2
vrup = .9 * vs
rcrit = 1000.
nclramp = 10
material(1,:) = (/ rho0, vp, vs /)
friction(1,:) = (/ .6, .5,   .25, 0. /)
traction(1,:) = (/ -70e6, -120e6, 0. /)
stress(1,:) = 0.
nmat  = 1
nfric = 1
ntrac = 1
nstress = 1
nlock = 0
nout = 0
imat(1,:)    = (/ 1, 1, 1,   -1, -1, -1/)
ifric(1,:)   = (/ 1, 1, 1,   -1, -1, -1/)
itrac(1,:)   = (/ 1, 1, 1,   -1, -1, -1/)
istress(1,:) = (/ 1, 1, 1,   -1, -1, -1/)
viscosity = (/ .0, .3 /)
hypocenter = 0
msrcradius = 0.
checkpoint = -1
npml = 0
bc = (/ 1, 1, 0,   1, 1, 1 /)
open( 9, file='inputs', status='old' )
loop: do
  read( 9,'(a)', iostat=iostat ) buff
  if ( iostat /= 0 ) exit loop
  if ( buff == ' ' ) cycle loop
  read( buff, * ) key
  if ( key(1:1) == '#' .or. key(1:1) == '!' .or. key(1:1) == '%' ) cycle loop
  selectcase( key )
  case( '' )
  case( 'nprocs' );     read( buff, * ) a, npe3
  case( 'n' );          read( buff, * ) a, npg, nt
  case( 'nrmdim' );     read( buff, * ) a, nrmdim
  case( 'npml' );       read( buff, * ) a, npml
  case( 'grid' );       read( buff, * ) a, grid
  case( 'rcrit' );      read( buff, * ) a, rcrit
  case( 'hypocenter' ); read( buff, * ) a, hypocenter
  case( 'viscosity' );  read( buff, * ) a, viscosity
  case( 'nclramp' );    read( buff, * ) a, nclramp
  case( 'dx' );         read( buff, * ) a, dx
  case( 'dt' );         read( buff, * ) a, dt
  case( 'bc' );         read( buff, * ) a, bc
  case( 'checkpoint' ); read( buff, * ) a, checkpoint
  case( 'locknodes' )
    nlock = nlock + 1
    read( buff, * ) a, locknodes(nlock,:), ilock(nlock,:)
  case( 'out' )
    nout = nout + 1
    read( buff, * ) a, outvar(nout), outint(nout), iout(nout,:)
  case( 'material' )
    nmat = nmat + 1
    read( buff, * ) a, material(nmat,:), imat(nmat,:)
  case( 'friction' )
    nfric = nfric + 1
    read( buff, * ) a, friction(nfric,:), ifric(nfric,:)
  case( 'traction' )
    ntrac = ntrac + 1
    read( buff, * ) a, traction(ntrac,:), itrac(ntrac,:)
  case( 'stress' )
    nstress = nstress + 1
    read( buff, * ) a, stress(nstress,:), istress(nstress,:)
  case default; print '(a)', 'bad key: ' // trim( key ); stop
  end select
end do loop
close( 9 )

if( any( hypocenter == 0 ) ) hypocenter = npg / 2 + mod( npg, 2 )
if( nrmdim /= 0 ) npg(nrmdim) = npg(nrmdim) + 1
nhalo = 1
i1node = 1
i2node = npg
i1cell = 1
i2cell = npg - 1
i1nodepml = i1node + bc(1:3) * npml
i2nodepml = i2node - bc(4:6) * npml
i1cellpml = i1cell + bc(1:3) * npml
i2cellpml = i2cell - bc(4:6) * npml

end subroutine

