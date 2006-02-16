! Read input
module inread_m
implicit none
contains

subroutine inread( filename )
use globals_m
integer :: i, err
logical :: inzone
character(*), intent(in) :: filename
character(11) :: key

if ( master ) then
  open( 9, file='log', position='append' )
  write( 9, * ) 'Reading file: ', filename
  close( 9 )
end if

open( 9, file=filename, status='old' )

doline: do

! Read line
read( 9, '(a)', iostat=err ) str
if ( err /= 0 ) exit doline

! Strip comments and MATLAB characters
i = index( str, '%' )
if ( i > 0 ) str(i:) = ' '
if ( str == ' ' ) cycle doline

! Strip MATLAB characters
do
  i = scan( str, "{}=[]/';" )
  if ( i == 0 ) exit
  str(i:i) = ' '
end do

! Read tokens
read( str, * ) key
inzone = .false.

! Select input key
select case( key )
case( 'datadir' )
case( 'return' );      exit doline
case( 'grid' );        read( str, * ) key, grid
case( 'gridtrans' );   read( str, * ) key, gridtrans
case( 'gridnoise' );   read( str, * ) key, gridnoise
case( 'rfunc' );       read( str, * ) key, rfunc
case( 'tfunc' );       read( str, * ) key, tfunc
case( 'nn' );          read( str, * ) key, nn
case( 'nt' );          read( str, * ) key, nt
case( 'dx' );          read( str, * ) key, dx
case( 'dt' );          read( str, * ) key, dt
case( 'upvector' );    read( str, * ) key, upvector
case( 'viscosity' );   read( str, * ) key, viscosity
case( 'npml' );        read( str, * ) key, npml
case( 'bc1' );         read( str, * ) key, bc1
case( 'bc2' );         read( str, * ) key, bc2
case( 'xhypo' );       read( str, * ) key, xhypo
case( 'rsource' );     read( str, * ) key, rsource
case( 'tsource' );     read( str, * ) key, tsource
case( 'moment1' );     read( str, * ) key, moment1
case( 'moment2' );     read( str, * ) key, moment2
case( 'faultnormal' ); read( str, * ) key, faultnormal
case( 'rexpand' );     read( str, * ) key, rexpand
case( 'n1expand' );    read( str, * ) key, n1expand
case( 'n2expand' );    read( str, * ) key, n2expand
case( 'ihypo' );       read( str, * ) key, ihypo
case( 'vrup' );        read( str, * ) key, vrup
case( 'rcrit' );       read( str, * ) key, rcrit
case( 'trelax' );      read( str, * ) key, trelax
case( 'svtol' );       read( str, * ) key, svtol
case( 'np' );          read( str, * ) key, np
case( 'itcheck' );     read( str, * ) key, itcheck
case( 'debug' );       read( str, * ) key, debug
case( 'rho' );         inzone = .true.
case( 'vp' );          inzone = .true.
case( 'vs' );          inzone = .true.
case( 'mus' );         inzone = .true.
case( 'mud' );         inzone = .true.
case( 'dc' );          inzone = .true.
case( 'co' );          inzone = .true.
case( 'tn' );          inzone = .true.
case( 'th' );          inzone = .true.
case( 'td' );          inzone = .true.
case( 'sxx' );         inzone = .true.
case( 'syy' );         inzone = .true.
case( 'szz' );         inzone = .true.
case( 'syz' );         inzone = .true.
case( 'szx' );         inzone = .true.
case( 'sxy' );         inzone = .true.
case( 'out' );
  nout = nout + 1
  i = nout
  read( str, * ) key, fieldout(i), ditout(i), i1out(i,:), i2out(i,:)
case( 'lock' );
  nlock = nlock + 1
  i = nlock
  read( str, * ) key, ilock(i,:), i1lock(i,:), i2lock(i,:)
case default
  if ( master ) then
    open( 9, file='log', position='append' )
    write( 9, * ) 'Error: bad input: ', trim( str )
    close( 9 )
  end if
  stop 'bad input'
end select

! Input zone
if ( inzone ) then
  nin = nin + 1
  i = nin
  i1in(i,:) = 1
  i2in(i,:) = -1
  read( str, * ) fieldin(i), key
  if ( key == 'read' ) then
    intype(i) = 'r'
  else
    read( str, *, iostat=err ) fieldin(i), inval(i), key
    if ( err /= 0 ) then
      read( str, * ) fieldin(i), inval(i)
    else
      select case( key )
      case( 'zone' )
        intype(i) = 'z'
        read( str, * ) fieldin(i), inval(i), key, i1in(i,:), i2in(i,:)
      case( 'cube' )
        intype(i) = 'c'
        read( str, * ) fieldin(i), inval(i), key, x1in(i,:), x2in(i,:)
      case default; stop
      end select
    end if
  end if
end if

end do doline

close( 9 )

end subroutine
end module

