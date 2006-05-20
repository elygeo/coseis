! Setup model dimensions
module setup_m
implicit none
contains

subroutine setup
use globals_m
use collective_m
use zone_m
use tictoc_m
integer :: nl(3), n(3), ip3master(3), i

if ( master ) call toc( 'Setup' )

! Hypocenter
n = nn
i = abs( faultnormal )
if ( i /= 0 ) n(i) = n(i) - 1
where ( ihypo == 0 ) ihypo = ( n + 1 ) / 2
where ( ihypo <  0 ) ihypo = ihypo + nn + 1

! Partition for parallelization
if ( np0 == 1 ) np = 1
nl = nn / np; where ( modulo( nn, np ) /= 0 ) nl = nl + 1
np = nn / nl; where ( modulo( nn, nl ) /= 0 ) np = np + 1
call rank( np, ip, ip3 )
nnoff = nhalo - nl * ip3

! Master processor
ip3master = ( ihypo - 1 ) / nl
master = .false.
if ( all( ip3 == ip3master ) ) master = .true.
call setmaster( ip3master )

! Size of arrays
nl = min( nl, nn + nnoff - nhalo )
nm = nl + 2 * nhalo

! Boundary conditions
if ( faultnormal /= 0 ) then
  if ( ihypo(i) == nn(i) ) bc2(i) = -2
end if
ibc1 = bc1
ibc2 = bc2
where ( ip3 /= 0      ) ibc1 = 9
where ( ip3 /= np - 1 ) ibc2 = 9

! Node region
i1node = nhalo + 1
i2node = nhalo + nl

! Cell region
i1cell = nhalo  
i2cell = nhalo + nl
where ( abs( ibc1 ) <= 1 ) i1cell = i1cell + 1
where ( abs( ibc2 ) <= 1 ) i2cell = i2cell - 1

! PML region
i1pml = nnoff + npml
i2pml = nnoff + nn + 1 - npml
where ( ibc1 /= 1 ) i1pml = 0
where ( ibc2 /= 1 ) i2pml = nm + 1
if ( any( i1pml >= i2pml ) ) stop 'model too small for PML'

! Map hypocenter to local index, test if fault on this processor
ihypo = ihypo + nnoff
ifn = 0
if ( faultnormal /= 0 ) then
  if ( ihypo(i) >= 1 .or. ihypo(i) <= nm(i) ) ifn = abs( faultnormal )
end if

end subroutine

end module

