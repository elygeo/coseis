!------------------------------------------------------------------------------!
! SERIAL
! This module provides hooks for parallelization.

module parallel_m

integer :: ip3(3) = 0, ip3master(0) = 0
logical :: master = .true.

contains

subroutine init;                             end subroutine
subroutine finalize;                         end subroutine
subroutine rank( np );                       end subroutine
subroutine broadcast( r );                   end subroutine
subroutine globalmin( i );                   end subroutine
subroutine globalminloc( rmin, imin, noff ); end subroutine
subroutine globalmaxloc( rmax, imax, noff ); end subroutine
subroutine swaphalo( w1, nhalo );            end subroutine

end module

