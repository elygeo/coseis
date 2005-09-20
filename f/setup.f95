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

! Hypocenter
where( ihypo == 0 ) ihypo = nn / 2 + mod( nn, 2 )
phypo = ihypo / nl
ihypo = ihypo + noff

! Test if this processor holds the fault
if ( ifn /= 0 ) if ( phypo(ifn) /= ip3(ifn) ) ifn = 0

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

! Input zones
if ( nin > nz ) stop 'too many input zone, make nz bigger'
do i = 1, nin
  call zone( i1in(i,:), i2in(i,:), nn, noff, ihypo, ifn )
end do

! Output zones
if ( nout > nz ) stop 'too many output zones, make nz bigger'
do i = 1, nout
  call zone( i1out(i,:), i2out(i,:), nn, noff, ihypo, ifn )
end do

! Locked nodes
if ( nlock > nz ) stop 'too many lock zones, make nz bigger'
do i = 1, nlock
  call zone( i1lock(i,:), i2lock(i,:), nn, noff, ihypo, ifn )
end do

end subroutine
end module

