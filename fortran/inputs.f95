!------------------------------------------------------------------------------!
! INPUTS

subroutine inputs
use globals
use utils

implicit none
integer :: iostat
character(256) :: a, key, switch = 'default', switchcase = 'default'

if ( verb > 0 ) print '(a)', 'Reading input file'
np = 1
ip = 0
ng = 21
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
imat(1,:)    = (/ 1, 1, 1,   -1, -1, -1 /)
ifric(1,:)   = (/ 1, 1, 1,   -1, -1, -1 /)
itrac(1,:)   = (/ 1, 1, 1,   -1, -1, -1 /)
istress(1,:) = (/ 1, 1, 1,   -1, -1, -1 /)
viscosity = (/ .0, .3 /)
hypocenter = 0
msrcradius = 0.
checkpoint = -1
npml = 0
bc = (/ 1, 1, 0,   1, 1, 1 /)
open( 9, file='in', status='old' )
loop: do
  read( 9,'(a)', iostat=iostat ) a
  if ( iostat /= 0 ) exit loop
  if ( a == ' ' ) cycle loop
  read( a, * ) key
  if ( key(1:1) == '#' .or. key(1:1) == '!' .or. key(1:1) == '%' ) cycle loop
  select case( key )
  case( 'switch' );     read( a, * ) key, switch
  case( 'case' );       read( a, * ) key, switchcase
  end select
  if ( switch /= switchcase ) cycle loop
  select case( key )
  case( 'n' );          read( a, * ) key, ng, nt
  case( 'dx' );         read( a, * ) key, dx
  case( 'dt' );         read( a, * ) key, dt
  case( 'bc' );         read( a, * ) key, bc
  case( 'npml' );       read( a, * ) key, npml
  case( 'grid' );       read( a, * ) key, grid
  case( 'viscosity' );  read( a, * ) key, viscosity
  case( 'nrmdim' );     read( a, * ) key, nrmdim
  case( 'hypocenter' ); read( a, * ) key, hypocenter
  case( 'rcrit' );      read( a, * ) key, rcrit
  case( 'nclramp' );    read( a, * ) key, nclramp
  case( 'locknodes' )
    nlock = nlock + 1
    read( a, * ) key, locknodes(nlock,:), ilock(nlock,:)
  case( 'material' )
    nmat = nmat + 1
    read( a, * ) key, material(nmat,:), imat(nmat,:)
  case( 'friction' )
    nfric = nfric + 1
    read( a, * ) key, friction(nfric,:), ifric(nfric,:)
  case( 'traction' )
    ntrac = ntrac + 1
    read( a, * ) key, traction(ntrac,:), itrac(ntrac,:)
  case( 'stress' )
    nstress = nstress + 1
    read( a, * ) key, stress(nstress,:), istress(nstress,:)
  case( 'out' )
    nout = nout + 1
    read( a, * ) key, outvar(nout), outint(nout), iout(nout,:)
  case( 'checkpoint' ); read( a, * ) key, checkpoint
  case( 'nprocs' );     read( a, * ) key, np
  case( 'verbose' );    read( a, * ) key, verb
  case( 'switch' )
  case( 'case' )
  case( '' )
  case default; print '(a)', 'bad key: ' // trim( key ); stop
  end select
end do loop
close( 9 )

if( any( hypocenter == 0 ) ) hypocenter = ng / 2 + mod( ng, 2 )
if( nrmdim /= 0 ) ng(nrmdim) = ng(nrmdim) + 1
nhalo = 1
offset = -nhalo
i1node = 1
i2node = ng
i1cell = 1
i2cell = ng - 1
i1nodepml = i1node + bc(1:3) * npml
i2nodepml = i2node - bc(4:6) * npml
i1cellpml = i1cell + bc(1:3) * npml
i2cellpml = i2cell - bc(4:6) * npml

end subroutine

