! Read input
module m_inread
implicit none
contains

subroutine inread
use m_globals
use m_util
integer :: i, io
logical :: inzone
character(12) :: key
character(256) :: line
type( t_io ), pointer :: p

! I/O pointers
allocate( pio0, p )
p => pio0

open( 1, file='input', status='old' )

doline: do

! Read line
read( 1, '(a)', iostat=io ) line
if ( io /= 0 ) exit doline
if ( line == '' ) cycle doline
str = line

! Read tokens
call strtok( str, key )
inzone = .false.
i = 0

! Select input key
select case( key )
case( '' )
case( 'datadir' )
case( 'return' );       exit doline
case( 'rfunc' );        rfunc = str(1:16)
case( 'tfunc' );        tfunc = str(1:16)
case( 'oplevel' );      read( str, *, iostat=io ) oplevel
case( 'affine' );       read( str, *, iostat=io ) affine
case( 'gridnoise' );    read( str, *, iostat=io ) gridnoise
case( 'fixhypo' );      read( str, *, iostat=io ) fixhypo
case( 'nn' );           read( str, *, iostat=io ) nn
case( 'nt' );           read( str, *, iostat=io ) nt
case( 'dx' );           read( str, *, iostat=io ) dx
case( 'dt' );           read( str, *, iostat=io ) dt
case( 'slipvector' );   read( str, *, iostat=io ) slipvector
case( 'hourglass' );    read( str, *, iostat=io ) hourglass
case( 'vdamp' );        read( str, *, iostat=io ) vdamp
case( 'rho1' );         read( str, *, iostat=io ) rho1
case( 'rho2' );         read( str, *, iostat=io ) rho2
case( 'gam1' );         read( str, *, iostat=io ) gam1
case( 'gam2' );         read( str, *, iostat=io ) gam2
case( 'vp1' );          read( str, *, iostat=io ) vp1
case( 'vp2' );          read( str, *, iostat=io ) vp2
case( 'vs1' );          read( str, *, iostat=io ) vs1
case( 'vs2' );          read( str, *, iostat=io ) vs2
case( 'npml' );         read( str, *, iostat=io ) npml
case( 'bc1' );          read( str, *, iostat=io ) bc1
case( 'bc2' );          read( str, *, iostat=io ) bc2
case( 'xhypo' );        read( str, *, iostat=io ) xhypo
case( 'rsource' );      read( str, *, iostat=io ) rsource
case( 'tsource' );      read( str, *, iostat=io ) tsource
case( 'moment1' );      read( str, *, iostat=io ) moment1
case( 'moment2' );      read( str, *, iostat=io ) moment2
case( 'faultnormal' );  read( str, *, iostat=io ) faultnormal
case( 'faultopening' ); read( str, *, iostat=io ) faultopening
case( 'rexpand' );      read( str, *, iostat=io ) rexpand
case( 'n1expand' );     read( str, *, iostat=io ) n1expand
case( 'n2expand' );     read( str, *, iostat=io ) n2expand
case( 'i1source' );     read( str, *, iostat=io ) i1source
case( 'i2source' );     read( str, *, iostat=io ) i2source
case( 'ihypo' );        read( str, *, iostat=io ) ihypo
case( 'vrup' );         read( str, *, iostat=io ) vrup
case( 'rcrit' );        read( str, *, iostat=io ) rcrit
case( 'trelax' );       read( str, *, iostat=io ) trelax
case( 'svtol' );        read( str, *, iostat=io ) svtol
case( 'np' );           read( str, *, iostat=io ) np
case( 'itstats' );      read( str, *, iostat=io ) itstats
case( 'itio' );         read( str, *, iostat=io ) itio
case( 'itcheck' );      read( str, *, iostat=io ) itcheck
case( 'itstop' );       read( str, *, iostat=io ) itstop
case( 'debug' );        read( str, *, iostat=io ) debug
case( 'mpin' );         read( str, *, iostat=io ) mpin
case( 'mpout' );        read( str, *, iostat=io ) mpout

select case( key )
case( 'x1' )
case( 'x2' )
case( 'x3' )
case( 'rho' )
case( 'vp' )
case( 'vs' )
!case( 'qp' )
!case( 'qs' )
case( 'gam' )
case( 'mus' )
case( 'mud' )
case( 'dc' )
case( 'co' )
case( 'tn' )
case( 'ts1' )
case( 'ts2' )
case( 'sxx' )
case( 'syy' )
case( 'szz' )
case( 'syz' )
case( 'szx' )
case( 'sxy' )
case( 'sz', 'sn', 'sx', 'sc', 'rx', 'wx', 'rn', 'wn', 'rz', 'wz' )
  p => p%next
  allocate( p )
  p%mode = key
  case( 'sz' );       read( str, *, iostat=io ) p%field, p%val, p%i1, p%i2, p%di
  case( 'sn' );       read( str, *, iostat=io ) p%field, p%val, p%i1
  case( 'sx' );       read( str, *, iostat=io ) p%field, p%val, p%x1
  case( 'sc' );       read( str, *, iostat=io ) p%field, p%val, p%x1, p%x2
  case( 'rx', 'wx' ); read( str, *, iostat=io ) p%field, p%x1
  case( 'rn', 'wn' ); read( str, *, iostat=io ) p%field, p%i1
  case( 'rz', 'wz' ); read( str, *, iostat=io ) p%field, p%i1, p%i2, p%di, p%nb
  end select
  if key(2) = 'n' then
    p%i2 = p%i1
    p%di = 1
    p%nb = itio
case default; io = 1
end select

! Error check
if ( io /= 0 ) then
  if ( master ) write( 0, * ) 'bad input: ', trim( line )
  stop
end if

end do doline

close( 1 )

end subroutine

end module

