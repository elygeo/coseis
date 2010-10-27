! field input and output
module m_fieldio
implicit none
integer, private :: itdebug = -1, idebug
type t_io
    character(32) :: filename      ! filename on disk for input or output
    character(4) :: field          ! field variable, see fieldnames.py for possibilities
    character(8) :: tfunc          ! see time_function in util.f90 for possibilities
    character(3) :: mode           ! 'r' read, 'w' write
    integer :: ii(3,4), nc, nb, ib, fh
    real :: x1(3), x2(3), val, period
    real, pointer :: buff(:,:)     ! buffer for storing mutliple time steps
    !XXX character(4) :: fields(32) ! field variable, see fieldnames.py for possibilities
    !XXX real, pointer :: buff(:,:,:)  ! buffer for storing mutliple time steps
    type( t_io ), pointer :: next  ! pointer to next member of the field i/o list
end type t_io
type( t_io ), pointer :: io0, io, ioprev
contains

! append linked list item
subroutine pappend
allocate( io%next )
io => io%next
io%next => io0
end subroutine

! remove linked list item
subroutine pdelete
ioprev%next => io%next
deallocate( io )
io => ioprev
end subroutine

! field i/o sequence
subroutine fieldio( passes, field, f )
use m_globals
use m_util
use m_collective
use m_fio
character(*), intent(in) :: passes, field
real, intent(inout) :: f(:,:,:)
character(4) :: pass
integer :: i1(3), i2(3), i3(3), i4(3), di(3), m(4), n(4), o(4), &
    it1, it2, dit, i, j, k, l, ipass
real :: val

! atart timer
val = timer( 2 )
!if ( verb ) write( *, '(3a)' ) 'Field I/O ', passes, field

! pass loop
do ipass = 1, len( passes )
pass = passes(ipass:ipass)
io => io0

! i/o list loop
loop: do while( io%next%field /= 'head' )
ioprev => io
io => io%next

! 4d slice
i1 = io%ii(1,1:3) - nnoff
i2 = io%ii(2,1:3) - nnoff
di = io%ii(3,1:3)
it1 = io%ii(1,4)
it2 = io%ii(2,4)
dit = io%ii(3,4)

! time indices
if ( it > it2 ) then
    call pdelete
    cycle loop
end if
if ( it < it1 ) cycle loop
if ( modulo( it - it1, dit ) /= 0 ) cycle loop

! spatial indices
i3 = i1
i4 = i2
where( i1 < i1core ) i1 = i1 + ( (i1core - i1 - 1) / di + 1 ) * di
where( i2 > i2core ) i2 = i1 + (  i2core - i1    ) / di       * di
m(1:3) = (i4 - i3) / di + 1
n(1:3) = (i2 - i1) / di + 1
o(1:3) = (i1 - i3) / di

! dimensionality
i3 = i1
i4 = i2
do i = 1, 3
    if ( size( f, i ) == 1 ) then
        if ( n(i) < 1 ) then
            call pdelete
            cycle loop
        end if
        i1(i) = 1
        i2(i) = 1
        m(i) = 1
        n(i) = 1
        o(i) = 0
    end if
end do

! pass test
if ( pass == '<' .and. io%mode(2:2) == 'w' ) cycle loop
if ( pass == '>' .and. io%mode(2:2) /= 'w' ) cycle loop

!XXX loop over fields
if ( field /= io%field ) cycle loop

! i/o
val = io%val * time_function( io%tfunc, tm, dt, io%period )
select case( io%mode )
case( '=c', '+c' )
    call setcube( f, w1, i3, i4, di, io%x1, io%x2, val, io%mode )
case( '=C', '+C' )
    call setcube( f, w2, i3, i4, di, io%x1, io%x2, val, io%mode )
case( '=' )
    do l = i1(3), i2(3), di(3)
    do k = i1(2), i2(2), di(2)
    do j = i1(1), i2(1), di(1)
        f(j,k,l) = val
    end do
    end do
    end do
case( '+' )
    do l = i1(3), i2(3), di(3)
    do k = i1(2), i2(2), di(2)
    do j = i1(1), i2(1), di(1)
        f(j,k,l) = f(j,k,l) + val
    end do
    end do
    end do
case( '=i' )
    if ( all( i1 == i2 ) ) then
        do l = i1(3) - 1, i1(3)
        do k = i1(2) - 1, i1(2)
        do j = i1(1) - 1, i1(1)
            f(j,k,l) = val * &
                ( ( 1.0 - abs( io%x1(1) - j - nnoff(1) ) ) &
                * ( 1.0 - abs( io%x1(2) - k - nnoff(2) ) ) &
                * ( 1.0 - abs( io%x1(3) - l - nnoff(3) ) ) )
        end do
        end do
        end do
    end if
case( '+i' )
    if ( all( i1 == i2 ) ) then
        do l = i1(3) - 1, i1(3)
        do k = i1(2) - 1, i1(2)
        do j = i1(1) - 1, i1(1)
            f(j,k,l) = f(j,k,l) + val * &
                ( ( 1.0 - abs( io%x1(1) - j - nnoff(1) ) ) &
                * ( 1.0 - abs( io%x1(2) - k - nnoff(2) ) ) &
                * ( 1.0 - abs( io%x1(3) - l - nnoff(3) ) ) )
        end do
        end do
        end do
    end if
case( '=s' )
    call random_number( s1 )
    do l = i1(3), i2(3), di(3)
    do k = i1(2), i2(2), di(2)
    do j = i1(1), i2(1), di(1)
        f(j,k,l) = val * s1(j,k,l)
    end do
    end do
    end do
case( '+s' )
    call random_number( s1 )
    do l = i1(3), i2(3), di(3)
    do k = i1(2), i2(2), di(2)
    do j = i1(1), i2(1), di(1)
        f(j,k,l) = f(j,k,l) + val * s1(j,k,l)
    end do
    end do
    end do
case( '=r', '+r', '=R', '+R' )
    if ( io%mode(2:2) == 'R' ) then
        do i = 1, 3
            if ( m(i) == 1 ) then
                i1(i) = 1
                i2(i) = 1
                n(i) = 1
                o(i) = 0
            end if
        end do
    end if
    if ( io%ib < 0 ) then
        !XXX allocate( io%buff(io%nc,n(1)*n(2)*n(3),io%nb) )
        allocate( io%buff(n(1)*n(2)*n(3),io%nb) )
        io%ib = io%nb
        io%fh = fio_file_null
        if ( mpin /= 0 ) io%fh = file_null
    end if
    if ( io%ib == io%nb ) then
        n(4) = min( io%nb, (it2 - it) / dit + 1 )
        m(4) = (it2 - it1) / dit + 1
        o(4) = (it  - it1) / dit
        str = io%filename
        if ( any( n(1:3) /= m(1:3) ) .and. mpin == 0 ) &
            write( str, '(2a,i6.6)' ) trim( str ), '-', ipid
        call rio2( io%fh, io%buff(:,:n(4)), 'r', str, m, n, o, mpin, verb )
        io%ib = 0
        if ( any( n < 1 ) ) then
            deallocate( io%buff )
            call pdelete
            cycle loop
        end if
        if ( any( io%buff(:,:n(4)) /= io%buff(:,:n(4)) ) .or. &
            maxval( io%buff(:,:n(4)) ) > huge( val ) ) then
            write( 0, * ) 'NaN/Inf in ', io%filename
            stop
        end if
    end if
    io%ib = io%ib + 1
    i = 0
    do l = i1(3), i2(3), di(3)
    do k = i1(2), i2(2), di(2)
    do j = i1(1), i2(1), di(1)
        i = i + 1
        s1(j,k,l) = io%buff(i,io%ib)
    end do
    end do
    end do
    if ( any( di > 1 ) ) then
        i1 = io%ii(1,1:3) - nnoff
        i2 = io%ii(2,1:3) - nnoff
        if ( any( di > nhalo .and. nproc3 > 1 ) ) stop 'di too large for nhalo'
        call scalar_swap_halo( s1, nhalo )
        call interpolate( s1, i1, i2, di )
    end if
    if ( io%mode(2:2) == 'R' ) then
        if ( m(1) == 1 ) then
            i2(1) = size( s1, 1 )
            do i = 2, i2(1)
                s1(i,:,:) = s1(1,:,:)
            end do
        end if
        if ( m(2) == 1 ) then
            i2(2) = size( s1, 2 )
            do i = 2, i2(2)
                s1(:,i,:) = s1(:,1,:)
            end do
        end if
        if ( m(3) == 1 ) then
            i2(3) = size( s1, 3 )
            do i = 2, i2(3)
                s1(:,:,i) = s1(:,:,1)
            end do
        end if
    end if
    if ( io%mode(1:1) == '=' ) then
        do l = i1(3), i2(3)
        do k = i1(2), i2(2)
        do j = i1(1), i2(1)
            f(j,k,l) = s1(j,k,l)
        end do
        end do
        end do
    elseif ( io%mode(1:1) == '+' ) then
        do l = i1(3), i2(3)
        do k = i1(2), i2(2)
        do j = i1(1), i2(1)
            f(j,k,l) = f(j,k,l) + s1(j,k,l)
        end do
        end do
        end do
    end if
    if ( it == it2 ) then
        deallocate( io%buff )
        call pdelete
        cycle loop
    end if
case( '=w', '=wi' )
    if ( io%ib < 0 ) then
        !XXX allocate( io%buff(io%nc,n(1)*n(2)*n(3),io%nb) )
        allocate( io%buff(n(1)*n(2)*n(3),io%nb) )
        io%ib = 0
        io%fh = fio_file_null
        if ( mpout /= 0 ) io%fh = file_null
    end if
    if ( modulo( it, itstats ) /= 0 ) then
        select case( io%field )
        case( 'vm2' ); call vector_norm( f, vv, i1, i2, di )
        case( 'um2' ); call vector_norm( f, uu, i1, i2, di )
        case( 'wm2' ); call tensor_norm( f, w1, w2, i1, i2, di )
        case( 'am2' ); call vector_norm( f, w1, i1, i2, di )
        end select
    end if
    io%ib = io%ib + 1
    if ( io%mode == '=wi' .and. all( i1 == i2 ) ) then
        io%buff(1,io%ib) = 0.0
        do l = i1(3) - 1, i2(3)
        do k = i1(2) - 1, i2(2)
        do j = i1(1) - 1, i2(1)
            io%buff(1,io%ib) = io%buff(1,io%ib) + f(j,k,l) * &
                ( ( 1.0 - abs( io%x1(1) - j - nnoff(1) ) ) &
                * ( 1.0 - abs( io%x1(2) - k - nnoff(2) ) ) &
                * ( 1.0 - abs( io%x1(3) - l - nnoff(3) ) ) )
        end do
        end do
        end do
    else
        i = 0
        do l = i1(3), i2(3), di(3)
        do k = i1(2), i2(2), di(2)
        do j = i1(1), i2(1), di(1)
            i = i + 1
            io%buff(i,io%ib) = f(j,k,l)
        end do
        end do
        end do
    end if
    if ( io%ib == io%nb .or. it == it2 .or. modulo( it, itio ) == 0 ) then
        n(4) = io%ib
        m(4) = (it2 - it1) / dit + 1
        o(4) = (it  - it1) / dit + 1 - n(4)
        str = io%filename
        if ( any( n(1:3) /= m(1:3) ) .and. mpout == 0 ) &
            write( str, '(2a,i6.6)' ) trim( str ), '-', ipid
        call rio2( io%fh, io%buff(:,:n(4)), 'w', str, m, n, o, mpout, verb )
        io%ib = 0
        if ( it == it2 .or. any( n < 1 ) ) then
            deallocate( io%buff )
            call pdelete
            cycle loop
        end if
    end if
case default
    write( 0, * ) "bad i/o mode '", trim( io%mode ), "' for ", trim( io%filename )
    stop
end select

end do loop
end do

! debug output
i = scan( passes, '>' )
if ( i > 0 .and. debug > 3 .and. it <= 8 ) then
    if ( itdebug /= it ) then
        itdebug = it
        idebug = 0
    end if
    idebug = idebug + 1
    write( str, "(a,3(i4.4,'-'),a)" ) 'debug/f', it, ipid, idebug, field
    write( *, '(2a)' ) 'Opening file: ', trim( str )
    open( 1, file=str, status='replace' )
    do l = 1, size( f, 3 )
        write( 1, * ) it, l, field
        do k = 1, size( f, 2 )
            write( 1, * ) f(:,k,l)
        end do
    end do
    close( 1 )
end if

! timer
if (sync) call barrier
iotimer = iotimer + timer( 2 )

end subroutine

!------------------------------------------------------------------------------!

subroutine setcube( f, x, i1, i2, di, x1, x2, r, mode )
real, intent(inout) :: f(:,:,:)
real, intent(in) :: x(:,:,:,:), x1(3), x2(3), r
integer, intent(in) :: i1(3), i2(3), di(3)
character(*), intent(in) :: mode
integer :: n(3), o(3), j, k, l
n = (/ size(f,1), size(f,2), size(f,3) /)
o = 0
where ( n == 1 ) o = 1 - i1
select case( mode(1:1) )
case( '=' )
    do l = i1(3), i2(3), di(3)
    do k = i1(2), i2(2), di(2)
    do j = i1(1), i2(1), di(1)
    if( x(j,k,l,1) >= x1(1) .and. x(j,k,l,1) <= x2(1) .and. &
        x(j,k,l,2) >= x1(2) .and. x(j,k,l,2) <= x2(2) .and. &
        x(j,k,l,3) >= x1(3) .and. x(j,k,l,3) <= x2(3) ) &
        f(j+o(1),k+o(2),l+o(3)) = r
    end do
    end do
    end do
case( '+' )
    do l = i1(3), i2(3), di(3)
    do k = i1(2), i2(2), di(2)
    do j = i1(1), i2(1), di(1)
    if( x(j,k,l,1) >= x1(1) .and. x(j,k,l,1) <= x2(1) .and. &
        x(j,k,l,2) >= x1(2) .and. x(j,k,l,2) <= x2(2) .and. &
        x(j,k,l,3) >= x1(3) .and. x(j,k,l,3) <= x2(3) ) &
        f(j+o(1),k+o(2),l+o(3)) = f(j+o(1),k+o(2),l+o(3)) + r
    end do
    end do
    end do
case default; stop 'error in cube'
end select
end subroutine

end module

