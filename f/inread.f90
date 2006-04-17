! Read input
module inread_m
implicit none
contains

subroutine inread
use globals_m
use tictoc_m
integer :: i, err
logical :: inzone
character(11) :: key
character(160) :: line

if ( master ) call toc( 'Reading input' )

open( 9, file='in.tmp', status='old' )

doline: do

! Read line
read( 9, '(a)', iostat=err ) line
if ( err /= 0 ) exit doline
if ( line == '' ) cycle doline

str = line
! Read tokens
call strtok( str, key )
inzone = .false.

! Select input key
select case( key )
case( 'datadir' )
case( 'return' );      exit doline
case( 'grid' );        grid = key
case( 'rfunc' );       rfunc = key
case( 'tfunc' );       tfunc = key
case( 'affine' );      read( str, * ) affine
case( 'gridnoise' );   read( str, * ) gridnoise
case( 'symmetry' );    read( str, * ) symmetry
case( 'origin' );      read( str, * ) origin
case( 'nn' );          read( str, * ) nn
case( 'nt' );          read( str, * ) nt
case( 'dx' );          read( str, * ) dx
case( 'dt' );          read( str, * ) dt
case( 'upvector' );    read( str, * ) upvector
case( 'viscosity' );   read( str, * ) viscosity
case( 'npml' );        read( str, * ) npml
case( 'bc1' );         read( str, * ) bc1
case( 'bc2' );         read( str, * ) bc2
case( 'xhypo' );       read( str, * ) xhypo
case( 'rsource' );     read( str, * ) rsource
case( 'tsource' );     read( str, * ) tsource
case( 'moment1' );     read( str, * ) moment1
case( 'moment2' );     read( str, * ) moment2
case( 'faultnormal' ); read( str, * ) faultnormal
case( 'rexpand' );     read( str, * ) rexpand
case( 'n1expand' );    read( str, * ) n1expand
case( 'n2expand' );    read( str, * ) n2expand
case( 'ihypo' );       read( str, * ) ihypo
case( 'vrup' );        read( str, * ) vrup
case( 'rcrit' );       read( str, * ) rcrit
case( 'trelax' );      read( str, * ) trelax
case( 'svtol' );       read( str, * ) svtol
case( 'np' );          read( str, * ) np
case( 'itcheck' );     read( str, * ) itcheck
case( 'debug' );       read( str, * ) debug
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
case( 'timeseries' );
  nout = nout + 1
  i = nout
  outtype(i) = 'x'
  ditout(i) = 1
  read( str, * ) fieldout(i), xout(i,:)
case( 'out' );
  nout = nout + 1
  i = nout
  outtype(i) = 'z'
  read( str, * ) fieldout(i), ditout(i), i1out(i,:), i2out(i,:)
case( 'lock' );
  nlock = nlock + 1
  i = nlock
  read( str, * ) ilock(i,:), i1lock(i,:), i2lock(i,:)
case default
  write( str, * ) 'Error: bad input: ', line
  if ( master ) call toc( str )
  stop 'bad input'
end select

! Input zone
if ( inzone ) then
  nin = nin + 1
  i = nin
  fieldin(i) = key
  intype(i) = 'z'
  i1in(i,:) = 1
  i2in(i,:) = -1
  call strtok( str, key )
  if ( key == 'read' ) then
    intype(i) = 'r'
  else
    read( key, * ) inval(i)
    call strtok( str, key )
    select case( key )
    case( '' )
    case( 'zone' ); read( str, * ) i1in(i,:), i2in(i,:)
    case( 'cube' ); read( str, * ) x1in(i,:), x2in(i,:); intype(i) = 'c'
    case default; stop 'bad input'
    end select
  end if
end if

end do doline

close( 9 )
end subroutine

! Parse string for the first token
subroutine strtok( str, tok )
character(*), intent(inout) :: str
character(*), intent(out) :: tok
integer :: i
tok = ''
i = verify( str, ' ' )
if ( i == 0 ) return
str = str(i:)
i = scan( str, ' ' )
if ( i == 0 ) then
  tok = str
  str = ''
else
  tok = str(:i-1)
  str = str(i:)
end if
end subroutine

end module

