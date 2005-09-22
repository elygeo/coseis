!------------------------------------------------------------------------------!
! SERIAL
! This module provides hooks for parallelization.

module parallel_m

integer :: ip = 0, ip3(3) = 0

contains

subroutine init;                         end subroutine
subroutine finalize;                     end subroutine
subroutine rank( np, ip, ip3 );          end subroutine
subroutine imin( i );                    end subroutine
subroutine allrmin( rmin, imin, iroot ); end subroutine
subroutine rmin( rmin, imin, iroot );    end subroutine
subroutine rmax( rmax, imax, iroot );    end subroutine
subroutine swaphalo( w1, nhalo );        end subroutine

end module

