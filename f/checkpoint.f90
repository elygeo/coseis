! Checkpointing
module m_checkpoint
implicit none
contains

! Look for checkpoint and read if found
subroutine readcheckpoint
use m_globals
use m_collective
integer :: i, irank
if ( itcheck < 1 ) itcheck = itcheck + nt + 1
irank = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
write( str, '(a,i6.6)' ) 'checkpoint/it', irank
open( 1, file=str, status='old', iostat=i )
if ( i == 0 ) then
  read( 1, * ) it
  close( 1 )
else
  it = 0
end if
call ireduce( i, it, 'allmin', 0 )
it = i
if ( it == 0 ) return
if ( master ) write( 0, * ) 'Checkpoint found, starting from ', it
i = modulo( it / itcheck, 2 )
write( str, '(a,i6.6,a,i6.6)' ) 'checkpoint/cp', i, '-', irank
inquire( iolength=i ) &
  t, v, u, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, pv, psv, trup, tarr, efric
open( 1, file=str, recl=i, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) &
  t, v, u, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, pv, psv, trup, tarr, efric
close( 1 )
end subroutine

! Write checkpoint
subroutine writecheckpoint
use m_globals
integer :: i, irank
open( 1, file='itcheck', status='old', iostat=i )
if ( i == 0 ) then
  read( 1, * ) itcheck
  close( 1 )
end if
if ( itcheck < 1 ) itcheck = itcheck + nt + 1
if ( modulo( it, itcheck ) /= 0 ) return
irank = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
i = modulo( it / itcheck, 2 )
write( str, '(a,i6.6,a,i6.6)' ) 'checkpoint/cp', i, '-', irank
inquire( iolength=i ) &
  t, v, u, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, pv, psv, trup, tarr, efric
open( 1, file=str, recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) &
  t, v, u, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, pv, psv, trup, tarr, efric
close( 1 )
write( str, '(a,i6.6)' ) 'checkpoint/it', irank
open( 1, file=str, status='replace' )
write( 1, * ) it
close( 1 )
end subroutine

end module

