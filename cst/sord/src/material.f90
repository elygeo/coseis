! material model
module m_material
implicit none
contains

subroutine material
use m_globals
use m_collective
use m_util
use m_fieldio
real :: max_l(14), max_g(14), vmin, vmax, cfl1, cfl2
integer :: i1(3), i2(3), j1, k1, l1, j2, k2, l2

if (master) write (*, '(a)') 'Material model'

! init
mr = 0.0
lam = 0.0
mu = 0.0
gam = 0.0

! inputs
call fieldio('<', 'rho', mr)
call fieldio('<', 'vp',  lam)
call fieldio('<', 'vs',  mu)
call fieldio('<', 'gam', gam)
s1 = lam
s2 = mu

! limits
if (rho1 > 0.0) mr = max(mr, rho1)
if (rho2 > 0.0) mr = min(mr, rho2)
if (vp1  > 0.0) s1 = max(s1, vp1)
if (vp2  > 0.0) s1 = min(s1, vp2)
if (vs1  > 0.0) s2 = max(s2, vs1)
if (vs2  > 0.0) s2 = min(s2, vs2)

! velocity dependent viscosity
if (vdamp > 0.0) then
    gam = s2
    call invert(gam)
    gam = gam * vdamp
end if

! limits
if (gam1 > 0.0) gam = max(gam, gam1)
if (gam2 > 0.0) gam = min(gam, gam2)

! halos
call scalar_swap_halo(mr,  nhalo)
call scalar_swap_halo(s1,  nhalo)
call scalar_swap_halo(s2,  nhalo)
call scalar_swap_halo(gam, nhalo)
call set_halo(mr,  0.0, i1cell, i2cell)
call set_halo(s1,  0.0, i1cell, i2cell)
call set_halo(s2,  0.0, i1cell, i2cell)
call set_halo(gam, 0.0, i1cell, i2cell)

! elastic moduli
mu  = mr * s2 * s2
lam = mr * s1 * s1 - 2.0 * mu

! Poisson ratio
yy = lam + mu
call invert(yy)
yy = 0.5 * lam * yy

! non-overlapping cell indices
i1 = max(i1core, i1bc)
i2 = min(i2core, i2bc - 1)
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

! minima
max_l(1) = -minval(mr(j1:j2,k1:k2,l1:l2))
max_l(2) = -minval(s1(j1:j2,k1:k2,l1:l2))
max_l(3) = -minval(s2(j1:j2,k1:k2,l1:l2))
max_l(4) = -minval(gam(j1:j2,k1:k2,l1:l2))
max_l(5) = -minval(lam(j1:j2,k1:k2,l1:l2))
max_l(6) = -minval(mu(j1:j2,k1:k2,l1:l2))
max_l(7) = -minval(yy(j1:j2,k1:k2,l1:l2))

! maxima
max_l(8)  = maxval(mr(j1:j2,k1:k2,l1:l2))
max_l(9)  = maxval(s1(j1:j2,k1:k2,l1:l2))
max_l(10) = maxval(s2(j1:j2,k1:k2,l1:l2))
max_l(11) = maxval(gam(j1:j2,k1:k2,l1:l2))
max_l(12) = maxval(lam(j1:j2,k1:k2,l1:l2))
max_l(13) = maxval(mu(j1:j2,k1:k2,l1:l2))
max_l(14) = maxval(yy(j1:j2,k1:k2,l1:l2))

! output
call fieldio('>', 'rho', mr)
call fieldio('>', 'vp',  s1)
call fieldio('>', 'vs',  s2)
call fieldio('>', 'gam', gam)
call fieldio('>', 'lam', lam)
call fieldio('>', 'mu',  mu)
call fieldio('>', 'nu',  yy)

! hourglass constant
yy = 12.0 * (lam + 2.0 * mu)
call invert(yy)
yy = yy * sqrt(sum(dx * dx) / 3.0) * mu * (lam + mu)
!yy = 0.3 / 16.0 * (lam + 2.0 * mu) * sqrt(sum(dx * dx) / 3.0) ! like Ma & Liu, 2006

! global maxima
call rreduce1(max_g, max_l, 'allmax', (/0, 0, 0/))

! vs harmonic mean for pml
if (vpml <= 0.0) then
    vmin = -max_g(3)
    vmax =  max_g(9)
    vpml = 2.0 * vmin * vmax / (vmin + vmax)
end if

! Courant condition
vmax = max_g(9)
cfl1 = dt * vmax * sqrt(3.0 / sum(dx * dx))
cfl2 = dt * vmax * 3.0 / sqrt(sum(dx * dx))

! output statistics
if (master) then
    open (1, file='stats/material.txt', status='replace')
    write (1, "(2g15.7,'  cfl')") cfl1, cfl2
    write (1, "(2g15.7,'  rho')") -max_g(1), max_g(8)
    write (1, "(2g15.7,'  vp')")  -max_g(2), max_g(9)
    write (1, "(2g15.7,'  vs')")  -max_g(3), max_g(10)
    write (1, "(2g15.7,'  gam')") -max_g(4), max_g(11)
    write (1, "(2g15.7,'  lam')") -max_g(5), max_g(12)
    write (1, "(2g15.7,'  mu')")  -max_g(6), max_g(13)
    write (1, "(2g15.7,'  nu')")  -max_g(7), max_g(14)
    close (1)
    if (any(max_g(1:7) > 0.0)) write (0, '(a)') 'Warning: negative moduli'
    if (cfl2 > 1.0) stop 'Courant condition not satisfied!'
end if

end subroutine

!------------------------------------------------------------------------------!

! calculate pml damping parameters
subroutine pml
use m_globals
integer :: i
real :: c1, c2, c3, damp, dampn, dampc, tune

if (npml < 1) return
c1 =  8.0 / 15.0
c2 = -3.0 / 100.0
c3 =  1.0 / 1500.0
tune = 3.5
damp = tune * vpml / sqrt(sum(dx * dx) / 3.0) * (c1 + (c2 + c3 * npml) * npml) / npml ** ppml
do i = 1, npml
    dampn = damp *  i ** ppml
    dampc = damp * (i ** ppml + (i - 1) ** ppml) * 0.5
    dn1(npml-i+1) = -2.0 * dampn       / (2.0 + dt * dampn)
    dc1(npml-i+1) = (2.0 - dt * dampc) / (2.0 + dt * dampc)
    dn2(npml-i+1) =  2.0               / (2.0 + dt * dampn)
    dc2(npml-i+1) =  2.0 * dt          / (2.0 + dt * dampc)
end do

end subroutine

end module

