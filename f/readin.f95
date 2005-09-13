!------------------------------------------------------------------------------!
! READIN

module readin_m
contains
subroutine readin
use globals_m

implicit none
integer :: iz, err
character(160) :: infile(2), str, key1, key2, key3

infile(1) = 'defaults'
infile(2) = 'in'

nmat  = 0
nfric = 0
ntrac = 0
nstress = 0
nlock = 0
nout = 0

dofile: do iz = 1, 2
if ( ip == 0 ) print '(a,a)', 'Reading file: ', trim( infile(iz) )
open( 9, file=infile(iz), status='old' )
doline: do
  read( 9, '(a)', iostat=i ) str
  if ( i /= 0 ) exit doline
  str = adjustl( str )
  if ( str(1:1) == '#' .or. str == ' ' ) cycle doline
  str(159:160) = ' #'
  read( str, * ) key1, key2, key3
  selectkey: select case( key1 )
  case( '' )
  case( 'stop' );       exit doline
  case( 'n' );          read( str, * ) key1, nn, nt
  case( 'dx' );         read( str, * ) key1, dx
  case( 'dt' );         read( str, * ) key1, dt
  case( 'bc' );         read( str, * ) key1, bc
  case( 'npml' );       read( str, * ) key1, npml
  case( 'viscosity' );  read( str, * ) key1, viscosity
  case( 'faultnorm' );  read( str, * ) key1, inrm
  case( 'hypocenter' ); read( str, * ) key1, i0
  case( 'rcrit' );      read( str, * ) key1, vrup, rcrit
  case( 'vrup' );       read( str, * ) key1, vrup, rcrit
  case( 'nramp' );      read( str, * ) key1, nramp
  case( 'rsource' );    read( str, * ) key1, rsource
  case( 'sourcef' );    read( str, * ) key1, sourcef, domp
  case( 'moment' );     read( str, * ) key1, moment
  case( 'checkpoint' ); read( str, * ) key1, itcheck
  case( 'np' );         read( str, * ) key1, np
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
    read( str, * ) key1, outvar(nout), itout(nout), iout(nout,:)
  case default; print '(2(a,x))', 'Bad key:', key1; stop
  end select selectkey
end do doline
close( 9 )
end do dofile

write( str, '(a,i6.6,a)' ) 'out/ckp/', ip, '.hdr'
open( 9, file=str, status='old', iostat=err )
if ( err == 0 ) then
  read( 9, * ) it
  close( 9 )
else
  it = 0
end if

nhalo = 1
if( inrm /= 0 ) nn(inrm) = nn(inrm) + 1

end subroutine
end module

