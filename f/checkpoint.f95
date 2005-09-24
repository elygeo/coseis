!------------------------------------------------------------------------------!
! Checkpointing

module checkpoint_m
use globals_m
use collective_m
implicit none
private
integer :: reclen, err
character(160) :: str
contains

subroutine readcheckpoint
if ( itcheck < 0 ) itcheck = itcheck + nt + 1
write( str, '(a,i6.6,a)' ) 'out/ckp/', ip, '.hdr'
open( 9, file=str, status='old', iostat=err )
if ( err == 0 ) then
  read( 9, * ) it
  close( 9 )
else
  it = 0
end if
call globalmin( it )
if ( it == 0 ) return
write( str, '(a,i6.6,i6.6)' ) 'out/ckp/', ip, it
inquire( iolength=reclen ) &
  t, v, u, sl, trup, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
open( 9, &
  file=str, &
  recl=reclen, &
  form='unformatted', &
  access='direct', &
  status='old' )
read( 9, rec=1 ) &
  t, v, u, sl, trup, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
close( 9 )
end subroutine

subroutine writecheckpoint
if ( itcheck == 0 .or. mod( it, itcheck ) /= 0 ) return
inquire( iolength=reclen ) &
  t, v, u, sl, trup, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
write( str, '(a,i6.6,i6.6)') 'out/ckp/', ip, it
open( 9, &
  file=str, &
  recl=reclen, &
  form='unformatted', &
  access='direct', &
  status='replace' )
write( 9, rec=1 ) &
  t, v, u, sl, trup, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
close( 9 )
write( str, '(a,i6.6,a)' ) 'out/ckp/', ip, '.hdr'
open( 9, file=str, status='replace' )
write( 9, * ) it
close( 9 )
end subroutine

end module

