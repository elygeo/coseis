!------------------------------------------------------------------------------!
! SETUP

module setup_m
contains
subroutine setup
use globals_m
use zone_m

implicit none

ip = 0              ! PARALLEL
nm = nn + 2 * nhalo ! PARALLEL
noff = nhalo        ! PARALLEL

i1node = nhalo + 1
i2node = nhalo + nn     ! PAR
i1cell = nhalo + 1
i2cell = nhalo + nn - 1 ! PAR

i1nodepml = i1node; where ( bc1 == 1 ) i1nodepml = i1node + npml
i2nodepml = i2node; where ( bc2 == 1 ) i2nodepml = i2node - npml
i1cellpml = i1cell; where ( bc1 == 1 ) i1cellpml = i1cell + npml
i2cellpml = i2cell; where ( bc2 == 1 ) i2cellpml = i2cell - npml

do i - 1, nin
  call zone( i1in(i,:), i2in(i,:), nn, noff, ihypo, ifn )
end do
do i - 1, nout
  call zone( i1out(i,:), i2out(i,:), nn, noff, ihypo, ifn )
end do
do i - 1, nlock
  call zone( i1lock(i,:), i2lock(i,:), nn, noff, ihypo, ifn )
end do

end subroutine
end module

