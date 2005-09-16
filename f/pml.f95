!------------------------------------------------------------------------------!
! PML

module pml_m
contains
subroutine pml
use globals_m

implicit none
real :: hmean, tune, c1, c2, c3, damp, dampn, dampc, courant, pmlp

! Check Courant stability condition. TODO: make general
courant = dt * vpmax * sqrt( 3. ) / abs( dx )
if ( ip == 0 ) print '(a,es11.4)', '  Courant: 1 >', courant

! PML damping
allocate( dn1(npml), dn2(npml), dc1(npml), dc2(npml) )
c1 =  8. / 15.
c2 = -3. / 100.
c3 =  1. / 1500.
tune = 3.5
pmlp = 2
hmean = 2. * vsmin * vsmax / ( vsmin + vsmax )
damp = tune * hmean / dx * ( c1 + ( c2 + c3 * npml ) * npml ) / npml ** pmlp
do i = 1, npml
  dampn = damp *   i ** pmlp
  dampc = damp * ( i ** pmlp + ( i - 1 ) ** pmlp ) / 2.
  dn1(npml-i+1) = - 2. * dampn        / ( 2. + dt * dampn )
  dc1(npml-i+1) = ( 2. - dt * dampc ) / ( 2. + dt * dampc )
  dn2(npml-i+1) =   2.                / ( 2. + dt * dampn )
  dc2(npml-i+1) =   2. * dt           / ( 2. + dt * dampc )
end do

end subroutine
end module

