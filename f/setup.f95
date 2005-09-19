!------------------------------------------------------------------------------!
! SETUP

module setup_m
contains
subroutine setup
use globals_m
use zone_m

implicit none
integer :: i

np = 1
ip3 = 0

!call mpi_cart_create( mpi_comm_world, 3, np, period, .true., comm3, err )
!call mpi_cart_get( comm, 3, np, period, ip3, err )

ip = 



where( ip3 == 0      ) bc1 = -1
where( ip3 == np - 1 ) bc2 = -1

noff = nhalo - nl * ip3
nl = min( nl, nn + noff - nhalo )
nm = nl + 2 * nhalo

i1node = nhalo + 1
i2node = nhalo + nl

i1cell = nhalo + 1
i2cell = nhalo + nl - 1
where( bc1 = -1 ) i1cell = i1cell - nhalo
where( bc2 = -1 ) i2cell = i2cell + nhalo

i1pml = 1  - noff;
i2pml = nn - noff;
where( bc1 == 1 ) i1pml = i1pml + npml
where( bc2 == 1 ) i2pml = i2pml - npml

where( ihypo == 0 ) ihypo = nn / 2 + mod( nn, 2 ) + noff
if ( ifn /= 0 ) then
if ( i1hypo(ifn) < i1node(ifn) .or. i1hypo(ifn) > i2node(ifn) ) then
  ifn = 0
end if
end if

do i = 1, nin
  call zone( i1in(i,:), i2in(i,:), nn, noff, ihypo, ifn )
end do
do i = 1, nout
  call zone( i1out(i,:), i2out(i,:), nn, noff, ihypo, ifn )
end do
do i = 1, nlock
  call zone( i1lock(i,:), i2lock(i,:), nn, noff, ihypo, ifn )
end do

end subroutine
end module

