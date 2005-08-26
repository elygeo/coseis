!------------------------------------------------------------------------------!
! SETUP

module setup_m
contains
subroutine setup
use globals_m

it = 0

ip = 0
nhalo = 1
offset = nhalo
where( hypocenter == 0 ) hypocenter = ng / 2 + mod( ng, 2 )
hypocenter = hypocenter + offset
if( nrmdim /= 0 ) ng(nrmdim) = ng(nrmdim) + 1
nl = ng
i1node = nhalo + 1
i2node = nhalo + nl
i1cell = nhalo + 1
i2cell = nhalo + nl - 1
i1nodepml = i1node + bc(1:3) * npml
i2nodepml = i2node - bc(4:6) * npml
i1cellpml = i1cell + bc(1:3) * npml
i2cellpml = i2cell - bc(4:6) * npml

call system_clock( count_rate=wt_rate )

end subroutine
end module

