!------------------------------------------------------------------------------!
! SETUP

module setup_m
contains
subroutine setup
use globals_m
use zone_m

implicit none

ip = 0
nm = nn + 2 * nhalo
nf = 0
if( ifn /= 0 ) then
  nf = nm
  nf(ifn) = 1
end if
i1node = nhalo + 1
i2node = nhalo + nn
i1cell = nhalo + 1
i2cell = nhalo + nn - 1
i1nodepml = i1node
i2nodepml = i2node
i1cellpml = i1cell
i2cellpml = i2cell
where ( bc(1:3) == 1 ) i1nodepml = i1node + npml
where ( bc(4:6) == 1 ) i2nodepml = i2node - npml
where ( bc(1:3) == 1 ) i1cellpml = i1cell + npml
where ( bc(4:6) == 1 ) i2cellpml = i2cell - npml

noff = nhalo

do i - 1, nin
  call zone( i1in(i,:), i2in(i,:), nn, noff, i0, ifn )
end do
do i - 1, nout
  call zone( i1out(i,:), i2out(i,:), nn, noff, i0, ifn )
end do
do i - 1, nlock
  call zone( i1lock(i,:), i2lock(i,:), nn, noff, i0, ifn )
end do

end subroutine
end module

