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
call rank( np, ip, ip3 )
ip = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )

FIXME
where( ip3 == 0      ) bc1 = -1
where( ip3 == np - 1 ) bc2 = -1

noff = nhalo - nl * ip3
nl = min( nl, nn + noff - nhalo )
nm = nl + 2 * nhalo

! Node region
i1node = nhalo + 1
i2node = nhalo + nl

! Cell region
i1cell = nhalo + 1
i2cell = nhalo + nl - 1
where( bc1 = -1 ) i1cell = i1cell - nhalo
where( bc2 = -1 ) i2cell = i2cell + nhalo

FIXME
! PML region
i1pml = 1  - noff;
i2pml = nn - noff;
where( bc1 == 1 ) i1pml = i1pml + npml
where( bc2 == 1 ) i2pml = i2pml - npml

! Hypocenter
where( ihypo == 0 ) ihypo = nn / 2 + mod( nn, 2 ) + noff
if ( ifn /= 0 ) then
if ( i1hypo(ifn) < i1node(ifn) .or. i1hypo(ifn) > i2node(ifn) ) then
  ifn = 0
end if
end if

! Input zones
do i = 1, nin
  call zone( i1in(i,:), i2in(i,:), nn, noff, ihypo, ifn )
end do

! Output zones
do i = 1, nout
  call zone( i1out(i,:), i2out(i,:), nn, noff, ihypo, ifn )
end do

! Locked nodes
do i = 1, nlock
  call zone( i1lock(i,:), i2lock(i,:), nn, noff, ihypo, ifn )
end do

end subroutine
end module

