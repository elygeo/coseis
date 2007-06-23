! Setup model dimensions
module m_setup
implicit none
contains

subroutine setup
use m_globals
use m_collective
use m_util
integer :: nl(3), n(3)

! Hypocenter & halo
n = nn
ifn = abs( faultnormal )
if ( ifn /= 0 ) then
  nhalo(ifn) = 2
end if
where ( ihypo == 0 ) ihypo = ( n + 1 ) / 2
where ( ihypo <  0 ) ihypo = ihypo + nn + 1
if ( any( ihypo < 0 .or. ihypo > nn ) ) stop 'ihypo out of bounds'

! Partition for parallelization
if ( np0 == 1 ) np = 1
nl = nn / np
where ( modulo( nn, np ) /= 0 ) nl = nl + 1
nhalo = 1
if ( ifn /= 0 ) then
  nl(ifn) = max( 2, nl(ifn) )
  if ( modulo( ihypo(ifn), nl(ifn) ) == 0 ) nhalo(ifn) = 2
end if
np = nn / nl
where ( modulo( nn, nl ) /= 0 ) np = np + 1
call rank( ip, ip3, np )
nnoff = nl * ip3 - nhalo

! Master process
ip3master = ( ihypo - 1 ) / nl
master = .false.
if ( all( ip3 == ip3master ) ) master = .true.
call setmaster( ip3master )

! Size of arrays
nl = min( nl, nn - nnoff - nhalo )
nm = nl + 2 * nhalo

! Boundary conditions
if ( ifn /= 0 ) then
  if ( ihypo(ifn) == nn(ifn) ) bc2(ifn) = -2
end if
ibc1 = bc1
ibc2 = bc2
where ( ip3 /= 0      ) ibc1 = 9
where ( ip3 /= np - 1 ) ibc2 = 9

! Non-overlapping core region
i1core = 1  + nhalo
i2core = nm - nhalo

! Node region
i1node = 1  + nhalo
i2node = nm - nhalo
where ( abs( ibc1 ) > 1 ) i1node = 2
where ( abs( ibc2 ) > 1 ) i2node = nm - 1

! Cell region
i1cell = 1  + nhalo
i2cell = nm - nhalo - 1
where ( abs( ibc1 ) > 1 ) i1cell = 1
where ( abs( ibc2 ) > 1 ) i2cell = nm - 1

! PML region
i1pml = min( nm, max( 0, npml - nnoff ) )
i2pml = max( 1,  min( nm + 1, nn + 1 - npml - nnoff ) )
if ( npml > 0 ) then
  where ( bc1 /= 1 ) i1pml = 0
  where ( bc2 /= 1 ) i2pml = nm + 1
end if
if ( any( i1pml > i2pml ) ) stop 'model too small for PML'

! Map hypocenter to local index, test if fault on this process
ihypo = ihypo - nnoff
if ( ifn /= 0 ) then
  if ( ihypo(ifn) < 2 .or. ihypo(ifn) > nm(ifn) - 2 ) ifn = 0
end if

! Synchronize processes if debugging
sync = debug > 1

end subroutine

end module

