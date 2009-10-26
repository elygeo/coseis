! Read model parameters
module m_parameters
implicit none
contains

subroutine read_parameters
use m_globals
use m_fieldio
integer :: io, i
character(12) :: key
character(1) :: op
character(256) :: line

! I/O pointers
allocate( pio0 )
p => pio0
p%next => pio0
p%field = 'head'

open( 1, file='parameters.py', status='old' )

doline: do

! Read line
read( 1, '(a)', iostat=io ) line
if ( io /= 0 ) exit doline

! Strip comments and punctuation
str = line
i = scan( str, '#' )
if ( i > 0 ) str(i:) = ' '
do
    i = scan( str, "()[]{}'," )
    if ( i == 0 ) exit
    str(i:i) = ' '
end do

! Read key val pair
if ( str == '' ) cycle doline
read( str, *, iostat=io ) key

! Select input key
select case( key )
case( 'fieldio', '' )
case( 'nn' );           read( str, *, iostat=io ) key, op, nn
case( 'nt' );           read( str, *, iostat=io ) key, op, nt
case( 'dx' );           read( str, *, iostat=io ) key, op, dx
case( 'dt' );           read( str, *, iostat=io ) key, op, dt
case( 'tm0' );          read( str, *, iostat=io ) key, op, tm0
case( 'affine' );       read( str, *, iostat=io ) key, op, affine
case( 'n1expand' );     read( str, *, iostat=io ) key, op, n1expand
case( 'n2expand' );     read( str, *, iostat=io ) key, op, n2expand
case( 'rexpand' );      read( str, *, iostat=io ) key, op, rexpand
case( 'gridnoise' );    read( str, *, iostat=io ) key, op, gridnoise
case( 'oplevel' );      read( str, *, iostat=io ) key, op, oplevel
case( 'rho1' );         read( str, *, iostat=io ) key, op, rho1
case( 'rho2' );         read( str, *, iostat=io ) key, op, rho2
case( 'vp1' );          read( str, *, iostat=io ) key, op, vp1
case( 'vp2' );          read( str, *, iostat=io ) key, op, vp2
case( 'vs1' );          read( str, *, iostat=io ) key, op, vs1
case( 'vs2' );          read( str, *, iostat=io ) key, op, vs2
case( 'gam1' );         read( str, *, iostat=io ) key, op, gam1
case( 'gam2' );         read( str, *, iostat=io ) key, op, gam2
case( 'vdamp' );        read( str, *, iostat=io ) key, op, vdamp
case( 'hourglass' );    read( str, *, iostat=io ) key, op, hourglass
case( 'bc1' );          read( str, *, iostat=io ) key, op, bc1
case( 'bc2' );          read( str, *, iostat=io ) key, op, bc2
case( 'npml' );         read( str, *, iostat=io ) key, op, npml
case( 'i1pml' );        read( str, *, iostat=io ) key, op, i1pml
case( 'i2pml' );        read( str, *, iostat=io ) key, op, i2pml
case( 'ppml' );         read( str, *, iostat=io ) key, op, ppml
case( 'vpml' );         read( str, *, iostat=io ) key, op, vpml
case( 'ihypo' );        read( str, *, iostat=io ) key, op, ihypo
case( 'source' );       read( str, *, iostat=io ) key, op, source
case( 'timefunction' ); read( str, *, iostat=io ) key, op, timefunction
case( 'period' );       read( str, *, iostat=io ) key, op, period
case( 'source1' );      read( str, *, iostat=io ) key, op, source1
case( 'source2' );      read( str, *, iostat=io ) key, op, source2
case( 'nsource' );      read( str, *, iostat=io ) key, op, nsource
case( 'faultnormal' );  read( str, *, iostat=io ) key, op, faultnormal
case( 'slipvector' );   read( str, *, iostat=io ) key, op, slipvector
case( 'faultopening' ); read( str, *, iostat=io ) key, op, faultopening
case( 'vrup' );         read( str, *, iostat=io ) key, op, vrup
case( 'rcrit' );        read( str, *, iostat=io ) key, op, rcrit
case( 'trelax' );       read( str, *, iostat=io ) key, op, trelax
case( 'svtol' );        read( str, *, iostat=io ) key, op, svtol
case( 'np3' );          read( str, *, iostat=io ) key, op, np3
case( 'itstats' );      read( str, *, iostat=io ) key, op, itstats
case( 'itio' );         read( str, *, iostat=io ) key, op, itio
case( 'itcheck' );      read( str, *, iostat=io ) key, op, itcheck
case( 'itstop' );       read( str, *, iostat=io ) key, op, itstop
case( 'debug' );        read( str, *, iostat=io ) key, op, debug
case( 'mpin' );         read( str, *, iostat=io ) key, op, mpin
case( 'mpout' );        read( str, *, iostat=io ) key, op, mpout
case default
    select case( key(1:1) )
    case( '=', '+' )
        call pappend
        p%ib = -1
        !XXXread( str, *, iostat=io ) p%mode, p%nfield
        !XXXallocate( p%fields(p%nfield) )
        !XXXread( str, *, iostat=io ) p%mode, p%nfield, p%tfunc, p%period, p%x1, &
        !XXX    p%x2, p%nb, p%ii, p%filename, p%val, p%fields
        read( str, *, iostat=io ) p%mode, p%tfunc, p%period, p%x1, p%x2, p%nb, &
            p%ii, p%field, p%filename, p%val
    case default; io = 1
    end select
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

