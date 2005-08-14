!------------------------------------------------------------------------------!
! SETUP

subroutine inputs
use globals
character*256 buff, key, a

npe3d = 1
npg = 21
nt = 20
dx = 100.
dt = .007
nu = .25
rho0 = 2670.
vp = 6000.
vs = sqrt( vp ^ 2 * ( nu - .5 ) / ( nu - 1 ) )  ! 3464.1
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
nout = 0
mati(1,:)    = (/ 1, 1, 1,   -1, -1, -1/)
frici(1,:)   = (/ 1, 1, 1,   -1, -1, -1/)
traci(1,:)   = (/ 1, 1, 1,   -1, -1, -1/)
stressi(1,:) = (/ 1, 1, 1,   -1, -1, -1/)
viscosity = (/ .0, .3 /)
hypocenter = 0
msrcradius = 0.
checkpoint = -1
npml = 0
bc = (/ 1, 1, 0,   1, 1, 1 /)
open( 9, file='inputs' status='old' )
loop: do
  read( 9,'(a)', iostat=iostat ) buff
  if ( iostat /= 0 ) exit loop
  if ( buff == ' ' ) cycle loop
  read( buff, * ) key
  if ( key(1:1) == '#' .or. key(1:1) == '!' .or. key(1:1) == '%' ) cycle loop
  selectcase( key )
  case( '' )
  case( 'nprocs' );     read( buff, * ) a, npe3d
  case( 'n' );          read( buff, * ) a, npg, nt
  case( 'nrmdim' );     read( buff, * ) a, nrmdim
  case( 'hypocenter' ); read( buff, * ) a, hypocenter
  case( 'dx' );         read( buff, * ) a, dx
  case( 'dt' );         read( buff, * ) a, dt
  case( 'bc' );         read( buff, * ) a, bc
  case( 'checkpoint' ); read( buff, * ) a, checkpoint
  case( 'out' )
    nout = nout + 1
    read( buff, * ) a, outvar(nout), outint(nout), outi(nout,:)
  case( 'material' )
    nmat = nmat + 1
    read( buff, * ) a, material(nmat,:), mati(nmat,:)
  case( 'friction' )
    nfric = nfric + 1
    read( buff, * ) a, friction(nfric,:), frici(nfric,:)
  case( 'traction' )
    ntrac = ntrac + 1
    read( buff, * ) a, traction(ntrac,:), traci(ntrac,:)
  case( 'stress' )
    nstress = nstress + 1
    read( buff, * ) a, stress(nstress,:), stressi(nstress,:)
  case default; stop( 'unrecognized input type: ' // key )
  end select
end do loop
close( 9 )
halo = 1
edge = 1
i1p = 1
i2p = npg

end subroutine

