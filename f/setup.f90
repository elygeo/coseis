! Setup model dimensions
module setup_m
implicit none
contains

subroutine setup
use globals_m
use collective_m
use zone_m
use tictoc_m
integer :: nl(3), n(3), ip3master(3)

if ( master ) call toc( 'Setup' )

! Partition for parallelization
if ( np0 == 1 ) np = 1
nl = nn / np; where ( modulo( nn, np ) /= 0 ) nl = nl + 1
np = nn / nl; where ( modulo( nn, nl ) /= 0 ) np = np + 1
call rank( np, ip, ip3 )
nnoff = nhalo - nl * ip3

! Hypocenter
n = nn
ifn = abs( faultnormal )
if ( ifn /= 0 ) n(ifn) = n(ifn) - 1
where ( ihypo == 0 ) ihypo = ( n + 1 ) / 2
where ( ihypo <  0 ) ihypo = ihypo + nn + 1
ip3master = ( ihypo - 1 ) / nl
call setmaster( ip3master )
master = .false.
if ( all( ip3 == ip3master ) ) master = .true.

! Boundary conditions
if ( ifn /= 0 ) then
  if ( ihypo(ifn) == nn(ifn) ) bc2(ifn) = -2
end if
ibc1 = bc1
ibc2 = bc2
where ( ip3 /= 0      ) ibc1 = 9
where ( ip3 /= np - 1 ) ibc2 = 9

! Map global hypocenter index to local hypocenter index
ihypo = ihypo + nnoff

! Trim extra nodes off last processor
nl = min( nl, nn + nnoff - nhalo )

! Size of arrays
nm = nl + 2 * nhalo

! Test if both sides of the fault exists on this processor
if ( ihypo(ifn) < 1 .or. ihypo(ifn) >= nm(ifn) ) ifn = 0

! PML region
i1pml = nnoff + npml
i2pml = nnoff + nn + 1 - npml
where ( ibc1 /= 1 ) i1pml = 0
where ( ibc2 /= 1 ) i2pml = nm + 1
if ( any( i1pml >= i2pml ) ) stop 'model too small for PML'

! Node region
i1node = nhalo + 1
i2node = nhalo + nl

! Cell region
i1cell = nhalo  
i2cell = nhalo + nl
where ( abs( ibc1 ) <= 1 ) i1cell = i1cell + 1
where ( abs( ibc2 ) <= 1 ) i2cell = i2cell - 1

end subroutine

end module

