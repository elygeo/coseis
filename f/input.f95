!------------------------------------------------------------------------------!
! INPUT

module input_m
contains
subroutine input
use globals_m

implicit none
integer :: iz, err
character(160) :: infile(2), str, key1, key2, key3, &
  switchcase = 'start', caseswitch = 'start'

write( str, '(a,a,i6.6,a)' ) dir, 'ckp/', ip, '.hdr'
open( 9, file=str, status='old', iostat=err )
if ( err == 0 ) then
  read( 9, * ) it
  close( 9 )
else
  it = 0
end if

infile(1) = 'defaults.in'
infile(2) = trim( dir ) // '/in'

nmat  = 0
nfric = 0
ntrac = 0
nstress = 0
nlock = 0
nout = 0

izloop: do iz = 1, 2
if ( ip == 0 ) print '(a,a)', 'Reading file: ', trim( infile(iz) )
open( 9, file=infile(iz), status='old' )
loop: do
  read( 9,'(a)', iostat=i ) str
  if ( i /= 0 ) exit loop
  str = adjustl( str )
  if ( str(1:1) == '#' .or. str == ' ' ) cycle loop
  str(159:160) = ' #'
  read( str, * ) key1, key2, key3
  select case( key1 )
  case( 'switch' );     switchcase = key2
  case( 'case' );       caseswitch = key2
  end select
  if ( caseswitch /= switchcase ) cycle loop
  a2: select case( key1 )
  case( 'dir' );        read( str, * ) key1, dir
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
  case( 'srctimefcn' ); srctimefcn = key2
  case( 'grid' );
    if ( key2 == 'read' ) then
      grid = ''
      griddir = key3
    else
      grid = key2
    end if
  case( 'material' )
    if ( key2 == 'read' ) then
      nmat = 0
      matdir = key3
    else
      nmat = nmat + 1
      read( str, * ) key1, material(nmat,:), imat(nmat,:)
    end if
  case( 'friction' )
    if ( key2 == 'read' ) then
      nfric = 0
      fricdir = key3
    else
      nfric = nfric + 1
      read( str, * ) key1, friction(nfric,:), ifric(nfric,:)
    end if
  case( 'stress' )
    if ( key2 == 'read' ) then
      nstress = 0
      stressdir = key3
    else
      nstress = nstress + 1
      read( str, * ) key1, stress(nstress,:), istress(nstress,:)
    end if
  case( 'traction' )
    if ( key2 == 'read' ) then
      ntrac = 0
      tracdir = key3
    else
      ntrac = ntrac + 1
      read( str, * ) key1, traction(ntrac,:), itrac(ntrac,:)
    end if
  case( 'locknodes' )
    nlock = nlock + 1
    read( str, * ) key1, locknodes(nlock,:), ilock(nlock,:)
  case( 'out' )
    nout = nout + 1
    read( str, * ) key1, outvar(nout), outit(nout), iout(nout,:)
  case( 'checkpoint' ); read( str, * ) key1, checkpoint
  case( 'np' );         read( str, * ) key1, np
  case( 'switch' )
  case( 'case' )
  case( '' )
  case default; print '(2(a,x))', 'bad key:', key1; stop
  end select a2
end do loop
close( 9 )
end do izloop

end subroutine
end module

