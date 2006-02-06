! Setup model dimensions
module setup_m
use globals_m
use collective_m
use zone_m
contains
subroutine setup

implicit none
integer :: nl(3), n(3), ip3master(3)

if ( master ) then
  open( 9, file='log', position='append' )
  write( 9, * ) 'Setup'
  close( 9 )
end if

! Partition for parallelization
if ( np0 == 1 ) np = 1
nl = nn / np; where ( modulo( nn, np ) /= 0 ) nl = nl + 1
np = nn / nl; where ( modulo( nn, nl ) /= 0 ) np = np + 1
call rank( np, ip, ip3 )

! Hypocenter
n = nn
ifn = abs( faultnormal )
if ( ifn /= 0 ) n(ifn) = n(ifn) - 1
where ( ihypo == 0 ) ihypo = ( n + 1 ) / 2
where ( ihypo <  0 ) ihypo = ihypo + nn + 1

! Master processor holds the hypocenter
ip3master = ( ihypo - 1 ) / nl
call setmaster( ip3master )
master = .false.
if ( all( ip3 == ip3master ) ) master = .true.

! Boundary conditions
if ( ifn /= 0 ) then
  if ( ihypo(ifn) == nn(ifn) ) bc2(ifn) = -1
end if
ibc1 = bc1
ibc2 = bc2
where ( ip3 /= 0      ) ibc1 = 3
where ( ip3 /= np - 1 ) ibc2 = 3

! PML region
i1pml = 0
i2pml = nn + 1
where ( ibc1 == 1 ) i1pml = i1pml + npml
where ( ibc2 == 1 ) i2pml = i2pml - npml
if ( any( i1pml >= i2pml ) ) stop 'model too small for PML'

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
i1cell = nhalo  
i2cell = nhalo + nl
where ( ibc1 <= 1 ) i1cell = i1cell + 1
where ( ibc2 <= 1 ) i2cell = i2cell - 1

end subroutine
end module

