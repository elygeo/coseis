!------------------------------------------------------------------------------!
! READIN

module readin_m
contains
subroutine readin
use globals_m

implicit none
integer :: iz, err
character(160) :: infile(2), str, key1, key2
logical :: inzone

infile(1) = 'defaults'
infile(2) = 'in'
grid = 'none'
srctimef = 'none'
nin = 0
nout = 0
nlock = 0


dofile: do iz = 1, 2

if ( ip == 0 ) print '(a,a)', 'Reading file: ', trim( infile(iz) )
open( 9, file=infile(iz), status='old' )
doline: do
  read( 9, '(a)', iostat=err ) str
  if ( err /= 0 ) exit doline
  str = adjustl( str )
  if ( str(1:1) == '#' .or. str == ' ' ) cycle doline
  read( str, * ) key1, key2
  inzone = .false.
  selectkey: select case( key1 )
  case( '' )
  case( 'n' );            read( str, * ) key1, nn, nt
  case( 'dx' );           read( str, * ) key1, dx
  case( 'dt' );           read( str, * ) key1, dt
  case( 'grid' );         grid = key2
  case( 'rho' );          inzone = .true.
  case( 'vp' );           inzone = .true.
  case( 'vs' );           inzone = .true.
  case( 'lock' );
    nlock = nlock + 1
    i = nlock
    read( str, * ) key1, lock(i,:), i1lock(i,:), i2lock(i,:)
  case( 'viscosity' );    read( str, * ) key1, viscosity
  case( 'npml' );         read( str, * ) key1, npml
  case( 'bc' );           read( str, * ) key1, bc
  case( 'hypocenter' );   read( str, * ) key1, x0
  case( 'moment' );       read( str, * ) key1, moment
  case( 'sourcetimefn' ); sourcetimefn = key2
  case( 'tsource' );      read( str, * ) key1, tsource
  case( 'rsource' );      read( str, * ) key1, rsource
  case( 'faultnormal' );  read( str, * ) key1, ifn
  case( 'upvector' );     read( str, * ) key1, upvecotor
  case( 'mus' );          inzone = .true.
  case( 'mud' );          inzone = .true.
  case( 'dc' );           inzone = .true.
  case( 'cohesion' );     inzone = .true.
  case( 'tnormal' );      inzone = .true.
  case( 'tstrike' );      inzone = .true.
  case( 'tdip' );         inzone = .true.
  case( 'sxx' );          inzone = .true.
  case( 'syy' );          inzone = .true.
  case( 'szz' );          inzone = .true.
  case( 'syz' );          inzone = .true.
  case( 'szx' );          inzone = .true.
  case( 'sxy' );          inzone = .true.
  case( 'vrup' );         read( str, * ) key1, vrup
  case( 'rcrit' );        read( str, * ) key1, rcrit
  case( 'trelax' );       read( str, * ) key1, trelax
  case( 'np' );           read( str, * ) key1, np
  case( 'checkpoint' );   read( str, * ) key1, itcheck
  case( 'out' );
    nout = nout + 1
    i = nout
    read( str, * ) key1, outkey(i), itout(i), i1out(i,:), i2out(i,:)
  case default; print '(2a)', 'Bad input: ', trim( str ); stop
  end select selectkey
  if ( inzone ) 
    nin = nin + 1
    i = nin
    if ( key2 == 'read' ) then
      readfile(nin) = .true.
    else
      readfile(nin) = .false.
      read( str, * ) inkey(i), inval(i), i1in(i,:), i2in(i,:)
      if ( err /= 0 ) then
        i1in(nz,:) = 1
        i2in(nz,:) = -1
        read( str, *, iostat=err ) inkey(i), inval(i)
      end if
    end if
  end if
end do doline
close( 9 )

end do dofile

i = max( nout, max( nout, nlock ) )
if ( nin > nz .or. nout > nz .or nlock > nz ) then
  print *, 'Error: make nz at least max: ', nin, nout, nlock
  stop
end if

write( str, '(a,i6.6,a)' ) 'out/ckp/', ip, '.hdr'
open( 9, file=str, status='old', iostat=err )
if ( err == 0 ) then
  read( 9, * ) it
  close( 9 )
else
  it = 0
end if

if( ifn /= 0 ) nn(ifn) = nn(ifn) + 1

end subroutine
end module

