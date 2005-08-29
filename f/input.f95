!------------------------------------------------------------------------------!
! INPUT

module input_m
contains
subroutine input
use globals_m

implicit none
integer :: iostat, ifile
character(256) :: a, key, switch = 'default', switchcase = 'default'

nmat  = 0
nfric = 0
ntrac = 0
nstress = 0
nlock = 0
nout = 0

if ( verb > 0 ) print '(a)', 'Reading input file'
outer: do ifile = 1, 2
select case( ifile )
case( 1 ); open( 9, file='in.defaults', status='old' )
case( 2 ); open( 9, file='in', status='old' )
end select
inner: do
  read( 9,'(a)', iostat=iostat ) a
  if ( iostat /= 0 ) exit inner
  if ( a == ' ' ) cycle inner
  read( a, * ) key
  if ( key(1:1) == '#' ) cycle inner
  select case( key )
  case( 'switch' );     read( a, * ) key, switch
  case( 'case' );       read( a, * ) key, switchcase
  end select
  if ( switch /= switchcase ) cycle inner
  select case( key )
  case( 'n' );          read( a, * ) key, nn, nt
  case( 'dx' );         read( a, * ) key, dx
  case( 'dt' );         read( a, * ) key, dt
  case( 'bc' );         read( a, * ) key, bc
  case( 'npml' );       read( a, * ) key, npml
  case( 'grid' );       read( a, * ) key, grid
  case( 'viscosity' );  read( a, * ) key, viscosity
  case( 'nrmdim' );     read( a, * ) key, nrmdim
  case( 'hypocenter' ); read( a, * ) key, hypocenter
  case( 'rcrit' );      read( a, * ) key, rcrit
  case( 'vrup' );       read( a, * ) key, vrup
  case( 'nclramp' );    read( a, * ) key, nclramp
  case( 'msrcradius' ); read( a, * ) key, msrcradius
  case( 'moment' );     read( a, * ) key, moment
  case( 'srctimefcn' ); read( a, * ) key, srctimefcn
  case( 'domp' );       read( a, * ) key, domp
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
    read( a, * ) key, outvar(nout), outit(nout), iout(nout,:)
  case( 'checkpoint' ); read( a, * ) key, checkpoint
  case( 'nprocs' );     read( a, * ) key, np
  case( 'verbose' );    read( a, * ) key, verb
  case( 'switch' )
  case( 'case' )
  case( '' )
  case default; print '(a)', 'bad key: ' // trim( key ); stop
  end select
end do inner
close( 9 )
end do outer

end subroutine
end module

