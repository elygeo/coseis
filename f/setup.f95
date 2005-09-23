!------------------------------------------------------------------------------!
! SETUP

module setup_m
contains
subroutine setup
use globals_m
use parallel_m
use zone_m

implicit none
integer :: i, nl(3)

! Double nodes for fault
nn = n
if( ifn /= 0 ) nn(ifn) = nn(ifn) + 1

! Partition for parallelization
nl = nn / np; where ( mod( nn, np ) /= 0 ) nl = nl + 1
np = nn / nl; where ( mod( nn, nl ) /= 0 ) np = np + 1

! Hypocenter
where ( ihypo == 0 ) ihypo = n / 2 + 1
! FIXME
imaster = ihypo / nl

! Find processor rank
call rank( np )

! Offset: add to global index to get memory index
noff = nhalo - nl * ip3

! Trim extra nodes off last processor
nl = min( nl, nn + noff - nhalo )
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
i1pml = 0      + noff;
i2pml = nn + 1 + noff;
where( bc1 == 1 ) i1pml = i1pml + npml
where( bc2 == 1 ) i2pml = i2pml - npml

end subroutine
end module

