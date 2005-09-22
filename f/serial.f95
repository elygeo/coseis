!------------------------------------------------------------------------------!
! SERIAL
! This module provides hooks for parallelization.

module parallel_m
contains

subroutine init;                       end subroutine
subroutine finalize;                   end subroutine
subroutine rank( np, ip, ip3 );        end subroutine
subroutine swaphalo( w1, nhalo );      end subroutine
subroutine pmin( rl, rg );   rg = rl;  end subroutine
subroutine pmax( rl, rg );   rg = rl;  end subroutine
subroutine pmini( il, ig );  ig = il;  end subroutine

end module

