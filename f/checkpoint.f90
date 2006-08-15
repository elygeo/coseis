! Checkpointing
module m_checkpoint
use m_globals
use m_collective
implicit none
contains

! Look for checkpoint and read if found
subroutine readcheckpoint
integer :: i, reclen, err
if ( itcheck < 1 ) itcheck = itcheck + nt + 1
i = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
write( str, '(a,i6.6)' ) 'checkpoint/it', i
open( 1, file=str, status='old', iostat=err )
if ( err == 0 ) then
  read( 1, * ) it
  close( 1 )
else
  it = 1
end if
call pimin( it )
if ( it == 1 ) return
if ( master ) print *, 'Checkpoint found, starting from ', it
write( str, '(a,i6.6,a,i6.6)' ) 'checkpoint/cp', it, '-', i
inquire( iolength=reclen ) &
  t, v, u, pv, z1, z2, sl, svm, psv, trup, tarr, efrac, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
open( 1, &
  file=str, &
  recl=reclen, &
  form='unformatted', &
  access='direct', &
  status='old' )
read( 1, rec=1 ) &
  t, v, u, pv, z1, z2, sl, svm, psv, trup, tarr, efrac, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
close( 1 )
end subroutine

! Write checkpoint
subroutine writecheckpoint
integer :: i, reclen
if ( itcheck < 1 ) itcheck = itcheck + nt + 1
if ( modulo( it, itcheck ) /= 0 ) return
i = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
inquire( iolength=reclen ) &
  t, v, u, pv, z1, z2, sl, svm, psv, trup, tarr, efrac, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
write( str, '(a,i6.6,a,i6.6)' ) 'checkpoint/cp', it, '-', i
open( 1, &
  file=str, &
  recl=reclen, &
  form='unformatted', &
  access='direct', &
  status='replace' )
write( 1, rec=1 ) &
  t, v, u, pv, z1, z2, sl, svm, psv, trup, tarr, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
close( 1 )
write( str, '(a,i6.6)' ) 'checkpoint/it', i
open( 1, file=str, status='replace' )
write( 1, * ) it
close( 1 )
end subroutine

end module

