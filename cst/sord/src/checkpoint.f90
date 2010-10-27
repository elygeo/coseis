! checkpoint restart
module m_checkpoint
implicit none
integer, private :: itcheck0
contains

! look for checkpoint
subroutine look_for_checkpoint
use m_globals
use m_collective
use m_util
integer :: i
real :: r
r = timer( 2 )
write( str, '(a,i6.6)' ) 'checkpoint/it', ipid
open( 1, file=str, status='old', iostat=i )
if ( i == 0 ) then
    read( 1, * ) it, itcheck0
    close( 1 )
else
    it = 0
end if
call ireduce( i, it, 'allmin', (/0, 0, 0/) )
it = i
iotimer = iotimer + timer( 2 )
end subroutine

! read checkpoint
subroutine read_checkpoint
use m_globals
use m_stats
use m_util
integer :: i
real :: r
r = timer( 2 )
if ( it == 0 ) return
if ( master ) write( *, '(a,i6)' ) 'Checkpoint found, starting from ', it
i = modulo( it / itcheck0, 2 )
write( str, '(a,i6.6,a,i6.6)' ) 'checkpoint/cp', i, '-', ipid
if ( ifn == 0 ) then
    inquire( iolength=i ) &
        tm, vv, uu, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
    open( 1, file=str, recl=i, form='unformatted', access='direct', status='old' )
    read( 1, rec=1 ) &
        tm, vv, uu, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
    close( 1 )
else
    inquire( iolength=i ) &
        tm, vv, uu, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, &
        psv, trup, tarr, efric
    open( 1, file=str, recl=i, form='unformatted', access='direct', status='old' )
    read( 1, rec=1 ) &
        tm, vv, uu, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, &
        psv, trup, tarr, efric
    close( 1 )
end if
iotimer = iotimer + timer( 2 )
end subroutine

! write checkpoint
subroutine write_checkpoint
use m_globals
use m_stats
use m_util
use m_collective
integer :: i
real :: r
r = timer( 2 )
if ( verb ) write( *, '(a)' ) 'Checkpoint'
if ( itcheck >= 0 .and. ( it == nt .or. modulo( it, itio ) == 0 ) ) then
    open( 1, file='itcheck', status='old', iostat=i )
    if ( i == 0 ) then
        read( 1, * ) itcheck
        close( 1 )
    end if
end if
iotimer = iotimer + timer( 2 )
if ( itcheck <= 0 ) return
if ( modulo( it, itcheck ) /= 0 ) return
i = modulo( it / itcheck, 2 )
write( str, '(a,i6.6,a,i6.6)' ) 'checkpoint/cp', i, '-', ipid
if ( ifn == 0 ) then
    inquire( iolength=i ) &
        tm, vv, uu, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
    open( 1, file=str, recl=i, form='unformatted',access='direct',status='replace' )
    write( 1, rec=1 ) &
        tm, vv, uu, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
    close( 1 )
else
    inquire( iolength=i ) &
        tm, vv, uu, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, &
        psv, trup, tarr, efric
    open( 1, file=str, recl=i, form='unformatted',access='direct',status='replace' )
    write( 1, rec=1 ) &
        tm, vv, uu, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, &
        psv, trup, tarr, efric
    close( 1 )
end if
write( str, '(a,i6.6)' ) 'checkpoint/it', ipid
open( 1, file=str, status='replace' )
write( 1, * ) it, itcheck
close( 1 )
if (sync) call barrier
iotimer = iotimer + timer( 2 )
end subroutine

end module

