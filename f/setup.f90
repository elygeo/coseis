!------------------------------------------------------------------------------!
! Setup model dimensions

module setup_m
use globals_m
use collective_m
use zone_m
contains
subroutine setup

implicit none
integer :: nl(3), n(3), ip3master(3)

! Hypocenter
n = nn
if ( ifn /= 0 ) n(ifn) = n(ifn) - 1
where ( ihypo == 0 ) ihypo = ( n + 1 ) / 2

! PML region
i1pml = 0
i2pml = nn + 1
where( bc1 == 1 ) i1pml = i1pml + npml
where( bc2 == 1 ) i2pml = i2pml - npml
if ( any( i1pml >= i2pml ) ) stop 'model too small for PML'

! Partition for parallelization
nl = nn / np; where ( mod( nn, np ) /= 0 ) nl = nl + 1
np = nn / nl; where ( mod( nn, nl ) /= 0 ) np = np + 1

! Processor rank
call rank( np, ip3 )

! Master processor holds the hypocenter
ip3master = ( ihypo - 1 ) / nl
call setmaster( ip3master )
if ( all( ip3 == ip3master ) ) master = .true.

! Map global indices to local memory indices
nnoff = nhalo - nl * ip3
ihypo = ihypo + nnoff
i1pml = i1pml + nnoff
i2pml = i2pml + nnoff

! Trim extra nodes off last processor
nl = min( nl, nn + nnoff - nhalo )

! Size of arrays
nm = nl + 2 * nhalo

! Node region
i1node = nhalo + 1
i2node = nhalo + nl

! Cell region
i1cell = nhalo + 1
i2cell = nhalo + nl - 1
where( ip3 /= 0      ) i1cell = i1cell - nhalo
where( ip3 /= np - 1 ) i2cell = i2cell + nhalo

end subroutine
end module

