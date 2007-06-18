! Setup model dimensions
module m_setup
implicit none
contains

subroutine setup
use m_globals
use m_collective
use m_util
integer :: nl(3), n(3), ip3master(3), i

! Hypocenter
n = nn
i = abs( faultnormal )
if ( i /= 0 ) n(i) = n(i) - 1
where ( ihypo == 0 ) ihypo = ( n + 1 ) / 2
where ( ihypo <  0 ) ihypo = ihypo + nn + 1

! Partition for parallelization
if ( np0 == 1 ) np = 1
nl = nn / np; where ( modulo( nn, np ) /= 0 ) nl = nl + 1
nl = max( nl, nhalo )
np = nn / nl; where ( modulo( nn, nl ) /= 0 ) np = np + 1
call rank( ip, ip3, np )
nnoff = nl * ip3 - nhalo

! Master processor
ip3master = ( ihypo - 1 ) / nl
master = .false.
if ( all( ip3 == ip3master ) ) master = .true.
call setmaster( ip3master )

! Size of arrays
nl = min( nl, nn - nnoff - nhalo )
nm = nl + 2 * nhalo

! Boundary conditions
if ( faultnormal /= 0 ) then
  if ( ihypo(i) == nn(i) ) bc2(i) = -2
end if
ibc1 = bc1
ibc2 = bc2
where ( ip3 /= 0      ) ibc1 = 9
where ( ip3 /= np - 1 ) ibc2 = 9

! Regions
i1core = 1  + nhalo
i2core = nm - nhalo
i1node = max(  1-nnoff, 2    )
i2node = min( nn-nnoff, nm-1 )
i1cell = max(  1-nnoff,   1    )
i2cell = min( nn-nnoff-1, nm-1 )

! PML region
i1pml = 0 - nhalo
i2pml = nn + 1 + nhalo
if ( npml > 0 ) then
  where ( bc1 == 1 ) i1pml = npml
  where ( bc2 == 1 ) i2pml = nn + 1 - npml
end if
i1pml = i1pml - nnoff
i2pml = i2pml - nnoff
if ( any( i1pml >= i2pml ) ) stop 'model too small for PML'

! Map hypocenter to local index, test if fault on this processor
ihypo = ihypo - nnoff
ifn = 0
if ( faultnormal /= 0 ) then
  if ( ihypo(i) >= 1 .and. ihypo(i) <= nm(i) ) ifn = abs( faultnormal )
end if

end subroutine

end module

