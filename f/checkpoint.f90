! Checkpointing
module m_checkpoint
use m_globals
use m_collective
implicit none
contains

! Look for checkpoint and read if found
subroutine readcheckpoint
integer :: i, ip
if ( itcheck < 1 ) itcheck = itcheck + nt + 1
ip = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
write( str, '(a,i6.6)' ) 'checkpoint/it', ip
open( 1, file=str, status='old', iostat=i )
if ( i == 0 ) then
  read( 1, * ) it
  close( 1 )
else
  it = 0
end if
call pimin( i, it )
it = i
if ( it == 0 ) then
  t     =  0.
  v     =  0.
  u     =  0.
  w1    =  0.
! z1    =  0.
! z2    =  0.
  sl    =  0.
  p1    =  0.
  p2    =  0.
  p3    =  0.
  p4    =  0. 
  p5    =  0.
  p6    =  0. 
  g1    =  0.
  g2    =  0.
  g3    =  0.
  g4    =  0.
  g5    =  0.
  g6    =  0.
  pv    =  0.
  psv   =  0.
  trup  =  1e9
  tarr  =  0.
  efric =  0.
  return
end if
if ( master ) write( 0, * ) 'Checkpoint found, starting from ', it
write( str, '(a,i6.6,a,i6.6)' ) 'checkpoint/cp', it, '-', ip
inquire( iolength=i ) &
  t, v, u, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, pv, psv, trup, tarr, efric
open( 1, file=str, recl=i, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) &
  t, v, u, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, pv, psv, trup, tarr, efric
close( 1 )
end subroutine

! Write checkpoint
subroutine writecheckpoint
integer :: i, ip
open( 1, file='itcheck', status='old', iostat=i )
if ( i == 0 ) then
  read( 1, * ) itcheck
  close( 1 )
end if
if ( itcheck < 1 ) itcheck = itcheck + nt + 1
if ( modulo( it, itcheck ) /= 0 ) return
ip = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
write( str, '(a,i6.6,a,i6.6)' ) 'checkpoint/cp', it, '-', ip
inquire( iolength=i ) &
  t, v, u, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, pv, psv, trup, tarr, efric
open( 1, file=str, recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) &
  t, v, u, w1, sl, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, pv, psv, trup, tarr, efric
close( 1 )
write( str, '(a,i6.6)' ) 'checkpoint/it', ip
open( 1, file=str, status='replace' )
write( 1, * ) it
close( 1 )
end subroutine

end module

