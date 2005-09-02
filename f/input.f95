!------------------------------------------------------------------------------!
! INPUT

module input_m
contains
subroutine input( infile )
use globals_m

implicit none
character*(*), intent(in) :: infile
character(256) :: str, key, switch = 'default', switchcase = 'default'

nmat  = 0
nfric = 0
ntrac = 0
nstress = 0
nlock = 0
nout = 0

if ( verb > 0 ) print '(a,a)', 'Reading file: ', infile
open( 9, file=infile, status='old' )
loop: do
  read( 9,'(a)', iostat=i ) str
  if ( i /= 0 ) exit loop
  if ( str == ' ' ) cycle loop
  read( str, * ) key
  if ( key(1:1) == '#' ) cycle loop
  select case( key )
  case( 'switch' );     read( str, * ) key, switch
  case( 'case' );       read( str, * ) key, switchcase
  end select
  if ( switch /= switchcase ) cycle loop
  select case( key )
  case( 'n' );          read( str, * ) key, nn, nt
  case( 'dx' );         read( str, * ) key, dx
  case( 'dt' );         read( str, * ) key, dt
  case( 'bc' );         read( str, * ) key, bc
  case( 'npml' );       read( str, * ) key, npml
  case( 'grid' );       read( str, * ) key, grid
  case( 'viscosity' );  read( str, * ) key, viscosity
  case( 'nrmdim' );     read( str, * ) key, nrmdim
  case( 'hypocenter' ); read( str, * ) key, hypocenter
  case( 'rcrit' );      read( str, * ) key, rcrit
  case( 'vrup' );       read( str, * ) key, vrup
  case( 'nclramp' );    read( str, * ) key, nclramp
  case( 'msrcradius' ); read( str, * ) key, msrcradius
  case( 'moment' );     read( str, * ) key, moment
  case( 'srctimefcn' ); read( str, * ) key, srctimefcn
  case( 'domp' );       read( str, * ) key, domp
  case( 'locknodes' )
    nlock = nlock + 1
    read( str, * ) key, locknodes(nlock,:), ilock(nlock,:)
  case( 'material' )
    nmat = nmat + 1
    read( str, * ) key, material(nmat,:), imat(nmat,:)
  case( 'friction' )
    nfric = nfric + 1
    read( str, * ) key, friction(nfric,:), ifric(nfric,:)
  case( 'traction' )
    ntrac = ntrac + 1
    read( str, * ) key, traction(ntrac,:), itrac(ntrac,:)
  case( 'stress' )
    nstress = nstress + 1
    read( str, * ) key, stress(nstress,:), istress(nstress,:)
  case( 'out' )
    nout = nout + 1
    read( str, * ) key, outvar(nout), outit(nout), iout(nout,:)
  case( 'checkpoint' ); read( str, * ) key, checkpoint
  case( 'np' );         read( str, * ) key, np
  case( 'verbose' );    read( str, * ) key, verb
  case( 'switch' )
  case( 'case' )
  case( '' )
  case default; print '(a)', 'bad key: ' // trim( key ); stop
  end select
end do loop
close( 9 )

end subroutine
end module

