!------------------------------------------------------------------------------!
! SETUP

module setup_m
contains
subroutine setup
use globals_m

implicit none

ip = 0
nm = nn + 2 * nhalo
nf = 0
if( inrm /= 0 ) then
  nf = nm
  nf(inrm) = 1
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

where( i0 == 0 ) i0 = nn / 2 + mod( nn, 2 )
noff = nhalo
i0 = i0 + noff

end subroutine
end module

