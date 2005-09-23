!------------------------------------------------------------------------------!
! SERIAL
! This module provides hooks for parallelization.

module parallel_m

integer :: ip3(3) = 0, ip3master(0) = 0
logical :: master = .true.

contains

subroutine init;                  end subroutine
subroutine finalize;              end subroutine
subroutine rank( np, ip, ip3 );   end subroutine
subroutine imin( i );             end subroutine
subroutine allrmin( rmin, imin ); end subroutine
subroutine rmin( rmin, imin );    end subroutine
subroutine rmax( rmax, imax );    end subroutine
subroutine swaphalo( w1, nhalo ); end subroutine

end module

