! Time stamp log
module m_tictoc
implicit none
integer, private :: clock0, clockrate, clockmax
contains

subroutine tic
call system_clock( clock0, clockrate, clockmax )
end subroutine

subroutine toc( str, i )
character(*), intent(in) :: str
integer, intent(in), optional :: i
real :: t
integer :: clock1
call system_clock( clock1 )
t = real( clock1 - clock0 ) / real( clockrate )
if ( t < 0. ) t = real( clock1 - clock0 + clockmax ) / real( clockrate )
open( 2, file='log', position='append' )
if ( present( i ) ) then
  write( 2, '(f10.3,1x,a,i6)' ) t, trim( str ), i
else
  write( 2, '(f10.3,1x,a)' ) t, trim( str )
end if
close( 2 )
end subroutine

end module

