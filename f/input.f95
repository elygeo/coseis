!------------------------------------------------------------------------------!
! INPUT

module input_m
contains
subroutine input( infile )
use globals_m

implicit none
character*(*), intent(in) :: infile
character(256) :: str
character(32) :: key1, key2, key3, switchcase = 'start', caseswitch = 'start'

nmat  = 0
nfric = 0
ntrac = 0
nstress = 0
nlock = 0
nout = 0
nin = 0

if ( ip == 0 ) print '(a,a)', 'Reading file: ', infile
open( 9, file=infile, status='old' )
loop: do
  read( 9,'(a)', iostat=i ) str
  if ( i /= 0 ) exit loop
  str = adjustl( str )
  if ( str(1:1) == '#' .or. str == ' ' ) cycle loop
  read( str // ' #', * ) key1, key2, key3
  select case( key1 )
  case( 'switch' );     switchcase = key2
  case( 'case' );       caseswitch = key2
  end select
  if ( caseswitch /= switchcase ) cycle loop
  select case( key1 )
  case( 'grid' );       grid       = key2
  case( 'srctimefcn' ); srctimefcn = key2
  case( 'n' );          read( str, * ) key1, nn, nt
  case( 'dx' );         read( str, * ) key1, dx
  case( 'dt' );         read( str, * ) key1, dt
  case( 'bc' );         read( str, * ) key1, bc
  case( 'npml' );       read( str, * ) key1, npml
  case( 'viscosity' );  read( str, * ) key1, viscosity
  case( 'nrmdim' );     read( str, * ) key1, nrmdim
  case( 'hypocenter' ); read( str, * ) key1, hypocenter
  case( 'rcrit' );      read( str, * ) key1, rcrit
  case( 'vrup' );       read( str, * ) key1, vrup
  case( 'nclramp' );    read( str, * ) key1, nclramp
  case( 'msrcradius' ); read( str, * ) key1, msrcradius
  case( 'moment' );     read( str, * ) key1, moment
  case( 'domp' );       read( str, * ) key1, domp
  case( 'locknodes' )
    nlock = nlock + 1
    read( str, * ) key1, locknodes(nlock,:), ilock(nlock,:)
  case( 'material' )
    nmat = nmat + 1
    read( str, * ) key1, material(nmat,:), imat(nmat,:)
  case( 'friction' )
    nfric = nfric + 1
    read( str, * ) key1, friction(nfric,:), ifric(nfric,:)
  case( 'traction' )
    ntrac = ntrac + 1
    read( str, * ) key1, traction(ntrac,:), itrac(ntrac,:)
  case( 'stress' )
    nstress = nstress + 1
    read( str, * ) key1, stress(nstress,:), istress(nstress,:)
  case( 'out' )
    nout = nout + 1
    read( str, * ) key1, outvar(nout), outit(nout), iout(nout,:)
  case( 'read' )
    select case( key2 )
    case( 'grid' );     griddir = key3
    case( 'material' ); matdir = key3
    case( 'friction' ); fricdir = key3
    case( 'traction' ); tracdir = key3
    case( 'stress' );   stressdir = key3
    case default; print '(3(a,x))', 'bad key:', key1, key2; stop
  case( 'checkpoint' ); read( str, * ) key1, checkpoint
  case( 'np' );         read( str, * ) key1, np
  case( 'switch' )
  case( 'case' )
  case( '' )
  case default; print '(2(a,x))', 'bad key:', key1; stop
  end select
end do loop
close( 9 )

end subroutine
end module

