!------------------------------------------------------------------------------!
! Setup model dimensions

module setup_m
use globals_m
use collective_m
use zone_m
contains
subroutine setup

implicit none
integer :: i, nl(3), n(3)

! Partition for parallelization
nl = nn / np; where ( mod( nn, np ) /= 0 ) nl = nl + 1
np = nn / nl; where ( mod( nn, nl ) /= 0 ) np = np + 1

! Hypocenter
n = nn
if ( ifn /= 0 ) n(ifn) = n(ifn) - 1
where ( ihypo == 0 ) ihypo = n / 2 + 1
ip3master = ( ihypo - 1 ) / nl

! Find processor rank
call rank( np )

! Offset: add to global index to get memory index
nnoff = nhalo - nl * ip3

! Trim extra nodes off last processor
nl = min( nl, nn + nnoff - nhalo )
nm = nl + 2 * nhalo

! Node region
i1node = nhalo + 1
i2node = nhalo + nl

! Cell region
i1cell = nhalo + 1
i2cell = nhalo + nl - 1
where( ip3 /= 0      ) i1cell = i1cell - nhalo
where( ip3 /= np - 1 ) i2cell = i2cell + nhalo

! PML region
i1pml = 0      + nnoff;
i2pml = nn + 1 + nnoff;
where( bc1 == 1 ) i1pml = i1pml + npml
where( bc2 == 1 ) i2pml = i2pml - npml

end subroutine
end module

