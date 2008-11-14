! Checkpoint restart
module m_checkpoint
implicit none
integer, private :: itcheck0
contains

! Look for checkpoint
subroutine look_for_checkpoint
use m_globals
use m_collective
integer :: i
write( str, '(a,i6.6)' ) 'checkpoint/it', ipid
open( 1, file=str, status='old', iostat=i )
if ( i == 0 ) then
  read( 1, * ) it, itcheck0
  close( 1 )
else
  it = 0
end if
call ireduce( i, it, 'allmin', 0 )
it = i
end subroutine

! Read checkpoint
subroutine read_checkpoint
use m_globals
use m_stats
integer :: i
if ( it == 0 ) return
if ( master ) write( 0, * ) 'Checkpoint found, starting from ', it
i = modulo( it / itcheck0, 2 )
write( str, '(a,i6.6,a,i6.6)' ) 'checkpoint/cp', i, '-', ipid
inquire( iolength=i ) &
  tm, vv, uu, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, psv, trup, tarr, efric
open( 1, file=str, recl=i, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) &
  tm, vv, uu, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, psv, trup, tarr, efric
close( 1 )
end subroutine

! Write checkpoint
subroutine write_checkpoint
use m_globals
use m_stats
integer :: i
if ( verbose ) write( 0, * ) 'Checkpoint'
open( 1, file='itcheck', status='old', iostat=i )
if ( i == 0 ) then
  read( 1, * ) itcheck
  close( 1 )
end if
if ( itcheck == 0 ) return
if ( modulo( it, itcheck ) /= 0 ) return
i = modulo( it / itcheck, 2 )
write( str, '(a,i6.6,a,i6.6)' ) 'checkpoint/cp', i, '-', ipid
inquire( iolength=i ) &
  tm, vv, uu, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, psv, trup, tarr, efric
open( 1, file=str, recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) &
  tm, vv, uu, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, psv, trup, tarr, efric
close( 1 )
write( str, '(a,i6.6)' ) 'checkpoint/it', ipid
open( 1, file=str, status='replace' )
write( 1, * ) it, itcheck
close( 1 )
end subroutine

end module

