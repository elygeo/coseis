!------------------------------------------------------------------------------!
! SERIAL
! This module provides hooks for parallelization.
! It does very little for the serial version.

module parallel_m
contains

subroutine init;                   end subroutine
subroutine finalize;               end subroutine
subroutine rank( np, ip, ip3 );    end subroutine
subroutine swaphalo( w1, nhalo );  end subroutine
function pmin( rl ) result( rg );   rg = rl;  end function
function pmax( rl ) result( rg );   rg = rl;  end function
function pmini( il ) result( ig );  ig = il;  end function

end module

