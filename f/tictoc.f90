! Time stamp log
module m_tictoc
implicit none
integer, private :: clock0, clockrate, clockmax
contains

subroutine tic
call system_clock( clock0, clockrate, clockmax )
end subroutine

function toc()
real :: toc
integer :: clock1
call system_clock( clock1 )
toc = real( clock1 - clock0 ) / real( clockrate )
if ( toc < 0. ) toc = real( clock1 - clock0 + clockmax ) / real( clockrate )
end function

end module

