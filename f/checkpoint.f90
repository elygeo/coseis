! Checkpointing
module checkpoint_m
use globals_m
use collective_m
use tictoc_m
implicit none
contains

! Look for checkpoint and read if found
subroutine readcheckpoint
integer :: i, reclen, err
if ( itcheck < 1 ) itcheck = itcheck + nt + 1
i = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
write( str, '(a,i6.6)' ) 'checkpoint/it', i
open( 9, file=str, status='old', iostat=err )
if ( err == 0 ) then
  read( 9, * ) it
  close( 9 )
else
  it = 1
end if
call pimin( it )
if ( it == 1 ) return
if ( master ) call toc( 'Checkpoint found, starting from ', it )
write( str, '(a,i6.6,a,i6.6)' ) 'checkpoint/cp', it, '-', i
inquire( iolength=reclen ) &
  t, v, u, sl, trup, tarr, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
open( 9, &
  file=str, &
  recl=reclen, &
  form='unformatted', &
  access='direct', &
  status='old' )
read( 9, rec=1 ) &
  t, v, u, sl, trup, tarr, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
close( 9 )
end subroutine

! Write checkpoint
subroutine writecheckpoint
integer :: i, reclen
if ( modulo( it, itcheck ) /= 0 ) return
if ( master ) call toc( 'Write checkpoint' )
i = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
inquire( iolength=reclen ) &
  t, v, u, sl, trup, tarr, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
write( str, '(a,i6.6,a,i6.6)' ) 'checkpoint/cp', it, '-', i
open( 9, &
  file=str, &
  recl=reclen, &
  form='unformatted', &
  access='direct', &
  status='replace' )
write( 9, rec=1 ) &
  t, v, u, sl, trup, tarr, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
close( 9 )
write( str, '(a,i6.6)' ) 'checkpoint/it', i
open( 9, file=str, status='replace' )
write( 9, * ) it
close( 9 )
end subroutine

end module

