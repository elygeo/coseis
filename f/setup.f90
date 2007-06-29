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
if ( ifn /= 0 ) nhalo(ifn) = 2
nl = max( nl, nhalo )
np = nn / nl
where ( modulo( nn, nl ) /= 0 ) np = np + 1
call rank( ip, ip3, np )
nnoff = nl * ip3 - nhalo

! Master process
ip3master = ( ihypo - 1 ) / nl
where ( ip3master < 0 ) ip3master = 0
master = .false.
if ( all( ip3 == ip3master ) ) master = .true.
call setmaster( ip3master )

! Size of arrays
nl = min( nl, nn - nnoff - nhalo )
nm = nl + 2 * nhalo

! Boundary conditions
where ( i1bc < 1 ) i1bc = i1bc + nn + 1
where ( i2bc < 1 ) i2bc = i2bc + nn + 1
where ( abs( bc2 ) == 2 ) i2bc = i2bc - 1
if ( ifn /= 0 ) then
  if ( ihypo(ifn) < 2 ) then
    bc1(ifn) = -2
    i1bc(ifn) = ihypo(ifn) + 1
  end if
  if ( ihypo(ifn) > nn(ifn) - 2 ) then
    bc2(ifn) = -2
    i2bc(ifn) = ihypo(ifn)
  end if
end if
i1bc = i1bc - nnoff
i2bc = i2bc - nnoff
if ( any( i1bc > i2bc ) ) stop 'model too small for BC'

! Non-overlapping core region
i1core = 1  + nhalo
i2core = nm - nhalo

! Node region
i1node = max( i1bc, 2 )
i2node = min( i2bc, nm - 1 )

! Cell region
i1cell = max( i1bc, 1 )
i2cell = min( i2bc - 1, nm - 1 )

! PML region
i1pml = 0
i2pml = nn + 1
if ( npml > 0 ) then
  where ( bc1 == 10 ) i1pml = npml
  where ( bc2 == 10 ) i2pml = nn - npml + 1
end if
if ( any( i1pml > i2pml ) ) stop 'model too small for PML'
i1pml = i1pml - nnoff
i2pml = i2pml - nnoff

! Map hypocenter to local indices, and if fault on this process
ihypo = ihypo - nnoff
if ( ifn /= 0 ) then
  if ( ihypo(ifn) + 1 < i1core(ifn) .or. ihypo(ifn) > i2core(ifn) ) ifn = 0
end if

! Synchronize processes if debugging
sync = debug > 1

end subroutine

end module

