! read model parameters
module m_parameters
implicit none
contains

subroutine read_parameters
use m_globals
use m_fieldio
integer :: ios, i
character(12) :: key
character(1) :: op
character(256) :: line

!inquire( file='parameters.py', size=n )

! i/o pointers
allocate( io0 )
io => io0
io%next => io0
io%field = 'head'

open( 1, file='parameters.py', status='old' )

doline: do

! read line
read( 1, '(a)', iostat=ios ) line
if ( ios /= 0 ) exit doline

! strip comments and punctuation
str = line
i = scan( str, '#' )
if ( i > 0 ) str(i:) = ' '
do
    i = scan( str, "()[]{}'" )
    if ( i == 0 ) exit
    str(i:i) = ' '
end do

! read key val pair
if ( str == '' ) cycle doline
read( str, *, iostat=ios ) key

! select input key
select case( key )
case( 'fieldio', '' )
case( 'shape' );        read( str, *, iostat=ios ) key, op, shape_
case( 'delta' );        read( str, *, iostat=ios ) key, op, delta
case( 'tm0' );          read( str, *, iostat=ios ) key, op, tm0
case( 'affine' );       read( str, *, iostat=ios ) key, op, affine
case( 'n1expand' );     read( str, *, iostat=ios ) key, op, n1expand
case( 'n2expand' );     read( str, *, iostat=ios ) key, op, n2expand
case( 'rexpand' );      read( str, *, iostat=ios ) key, op, rexpand
case( 'gridnoise' );    read( str, *, iostat=ios ) key, op, gridnoise
case( 'oplevel' );      read( str, *, iostat=ios ) key, op, oplevel
case( 'rho1' );         read( str, *, iostat=ios ) key, op, rho1
case( 'rho2' );         read( str, *, iostat=ios ) key, op, rho2
case( 'vp1' );          read( str, *, iostat=ios ) key, op, vp1
case( 'vp2' );          read( str, *, iostat=ios ) key, op, vp2
case( 'vs1' );          read( str, *, iostat=ios ) key, op, vs1
case( 'vs2' );          read( str, *, iostat=ios ) key, op, vs2
case( 'gam1' );         read( str, *, iostat=ios ) key, op, gam1
case( 'gam2' );         read( str, *, iostat=ios ) key, op, gam2
case( 'vdamp' );        read( str, *, iostat=ios ) key, op, vdamp
case( 'hourglass' );    read( str, *, iostat=ios ) key, op, hourglass
case( 'bc1' );          read( str, *, iostat=ios ) key, op, bc1
case( 'bc2' );          read( str, *, iostat=ios ) key, op, bc2
case( 'npml' );         read( str, *, iostat=ios ) key, op, npml
case( 'i1pml' );        read( str, *, iostat=ios ) key, op, i1pml
case( 'i2pml' );        read( str, *, iostat=ios ) key, op, i2pml
case( 'ppml' );         read( str, *, iostat=ios ) key, op, ppml
case( 'vpml' );         read( str, *, iostat=ios ) key, op, vpml
case( 'ihypo' );        read( str, *, iostat=ios ) key, op, ihypo
case( 'source' );       read( str, *, iostat=ios ) key, op, source
case( 'timefunction' ); read( str, *, iostat=ios ) key, op, timefunction
case( 'period' );       read( str, *, iostat=ios ) key, op, period
case( 'source1' );      read( str, *, iostat=ios ) key, op, source1
case( 'source2' );      read( str, *, iostat=ios ) key, op, source2
case( 'nsource' );      read( str, *, iostat=ios ) key, op, nsource
case( 'faultnormal' );  read( str, *, iostat=ios ) key, op, faultnormal
case( 'slipvector' );   read( str, *, iostat=ios ) key, op, slipvector
case( 'faultopening' ); read( str, *, iostat=ios ) key, op, faultopening
case( 'vrup' );         read( str, *, iostat=ios ) key, op, vrup
case( 'rcrit' );        read( str, *, iostat=ios ) key, op, rcrit
case( 'trelax' );       read( str, *, iostat=ios ) key, op, trelax
case( 'svtol' );        read( str, *, iostat=ios ) key, op, svtol
case( 'nproc3' );       read( str, *, iostat=ios ) key, op, nproc3
case( 'itstats' );      read( str, *, iostat=ios ) key, op, itstats
case( 'itio' );         read( str, *, iostat=ios ) key, op, itio
case( 'itcheck' );      read( str, *, iostat=ios ) key, op, itcheck
case( 'itstop' );       read( str, *, iostat=ios ) key, op, itstop
case( 'debug' );        read( str, *, iostat=ios ) key, op, debug
case( 'mpin' );         read( str, *, iostat=ios ) key, op, mpin
case( 'mpout' );        read( str, *, iostat=ios ) key, op, mpout
case default
    select case( key(1:1) )
    case( '=', '+' )
        call pappend
        do
            i = scan( str, '/' )
            if ( i == 0 ) exit
            str(i:i) = '\\'
        end do
        io%ib = -1
        !XXXread( str, *, iostat=ios ) io%mode, io%nc
        read( str, *, iostat=ios ) io%mode, io%nc, io%tfunc, &
            io%period, io%x1, io%x2, io%nb, io%ii, io%filename, &
            io%val, io%field
        do
            i = scan( io%filename, '\\' )
            if ( i == 0 ) exit
            io%filename(i:i) = '/'
        end do
    case default; ios = 1
    end select
end select

! error check
if ( ios /= 0 ) then
    if ( master ) write( 0, * ) 'bad input: ', trim( line )
    stop
end if

end do doline

close( 1 )

end subroutine

end module

