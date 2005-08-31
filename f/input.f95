!------------------------------------------------------------------------------!
! INPUT

module input_m
contains
subroutine input
use globals_m

implicit none
integer :: iz
character(256) :: s, key, switch = 'default', switchcase = 'default'

nmat  = 0
nfric = 0
ntrac = 0
nstress = 0
nlock = 0
nout = 0

if ( verb > 0 ) print '(a)', 'Reading input file'
outer: do iz = 1, 2
select case( iz )
case( 1 ); open( 9, file='in.defaults', status='old' )
case( 2 ); open( 9, file='in', status='old' )
end select
inner: do
  read( 9,'(a)', iostat=i ) s
  if ( i /= 0 ) exit inner
  if ( s == ' ' ) cycle inner
  read( s, * ) key
  if ( key(1:1) == '#' ) cycle inner
  select case( key )
  case( 'switch' );     read( s, * ) key, switch
  case( 'case' );       read( s, * ) key, switchcase
  end select
  if ( switch /= switchcase ) cycle inner
  select case( key )
  case( 'n' );          read( s, * ) key, nn, nt
  case( 'dx' );         read( s, * ) key, dx
  case( 'dt' );         read( s, * ) key, dt
  case( 'bc' );         read( s, * ) key, bc
  case( 'npml' );       read( s, * ) key, npml
  case( 'grid' );       read( s, * ) key, grid
  case( 'viscosity' );  read( s, * ) key, viscosity
  case( 'nrmdim' );     read( s, * ) key, nrmdim
  case( 'hypocenter' ); read( s, * ) key, hypocenter
  case( 'rcrit' );      read( s, * ) key, rcrit
  case( 'vrup' );       read( s, * ) key, vrup
  case( 'nclramp' );    read( s, * ) key, nclramp
  case( 'msrcradius' ); read( s, * ) key, msrcradius
  case( 'moment' );     read( s, * ) key, moment
  case( 'srctimefcn' ); read( s, * ) key, srctimefcn
  case( 'domp' );       read( s, * ) key, domp
  case( 'locknodes' )
    nlock = nlock + 1
    read( s, * ) key, locknodes(nlock,:), ilock(nlock,:)
  case( 'material' )
    nmat = nmat + 1
    read( s, * ) key, material(nmat,:), imat(nmat,:)
  case( 'friction' )
    nfric = nfric + 1
    read( s, * ) key, friction(nfric,:), ifric(nfric,:)
  case( 'traction' )
    ntrac = ntrac + 1
    read( s, * ) key, traction(ntrac,:), itrac(ntrac,:)
  case( 'stress' )
    nstress = nstress + 1
    read( s, * ) key, stress(nstress,:), istress(nstress,:)
  case( 'out' )
    nout = nout + 1
    read( s, * ) key, outvar(nout), outit(nout), iout(nout,:)
  case( 'checkpoint' ); read( s, * ) key, checkpoint
  case( 'nprocs' );     read( s, * ) key, np
  case( 'verbose' );    read( s, * ) key, verb
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

