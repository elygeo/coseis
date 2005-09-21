!------------------------------------------------------------------------------!
! SETUP

module setup_m
contains
subroutine setup
use globals_m
use parallel_m
use zone_m

implicit none
integer :: i

! Double nodes for fault
nn = n
if( ifn /= 0 ) nn(ifn) = nn(ifn) + 1

! Partition for parallelization
nl = nn / np; where ( mod( nn, np ) /= 0 ) nl = nl + 1
np = nn / nl; where ( mod( nn, nl ) /= 0 ) np = np + 1

! Find processor rank
ip = 0
ip3 = 0
call prank( np, ip, ip3 )

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

! Fault plane
if ( ifn /= 0 ) then
  if ( ifault == 0 ) ifault = nn(ifn) / 2 + mod( nn( ifn, 2 ) )
  ifault = ifault + noff(ifn)
end if

end subroutine
end module

