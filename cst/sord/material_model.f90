! material model
module material_model
implicit none
contains

subroutine init_material
use globals
use collective
use utilities
use field_io_mod
real :: max_l(14), max_g(14), vmin, vmax, cfl1, cfl2, r, s
integer :: i1(3), i2(3), j1, k1, l1, j2, k2, l2, j, k, l

if (sync) call barrier
if (master) call message('Material model')

! init arrays
call r3fill(mr, 0.0)
call r3fill(lam, 0.0)
call r3fill(mu, 0.0)
call r3fill(gam, 0.0)

! inputs
call field_io('<', 'rho', mr)
call field_io('<', 'vp',  lam)
call field_io('<', 'vs',  mu)
call field_io('<', 'gam', gam)
call r3copy(lam, s1)
call r3copy(mu, s2)

! limits
if (rho1 > 0.0) call r30max(mr, rho1)
if (rho2 > 0.0) call r30min(mr, rho2)
if (vp1  > 0.0) call r30max(s1, vp1)
if (vp2  > 0.0) call r30min(s1, vp2)
if (vs1  > 0.0) call r30max(s2, vs1)
if (vs2  > 0.0) call r30min(s2, vs2)

! velocity dependent viscosity
if (vdamp > 0.0) then
    !$omp parallel do schedule(static) private(j, k, l)
    do l = 1, nm(3)
    do k = 1, nm(2)
    do j = 1, nm(1)
        if (s2(j,k,l) == 0.0) then
            gam(j,k,l) = 0.0
        else
            gam(j,k,l) = vdamp / s2(j,k,l)
        end if
    end do
    end do
    end do
    !$omp end parallel do
end if

! limits
if (gam1 > 0.0) call r30max(gam, gam1)
if (gam2 > 0.0) call r30min(gam, gam2)

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
!$omp parallel do schedule(static) private(j, k, l)
do l = 1, nm(3)
do k = 1, nm(2)
do j = 1, nm(1)
    mu(j,k,l)  = mr(j,k,l) * s2(j,k,l) * s2(j,k,l)
    lam(j,k,l) = mr(j,k,l) * s1(j,k,l) * s1(j,k,l) - 2.0 * mu(j,k,l)
    r = lam(j,k,l) + mu(j,k,l)
    if (r == 0.0) then
        yy(j,k,l) = 0.0
    else
        yy(j,k,l) = 0.5 * lam(j,k,l) / r
    end if
end do
end do
end do
!$omp end parallel do

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
call field_io('>', 'rho', mr)
call field_io('>', 'vp',  s1)
call field_io('>', 'vs',  s2)
call field_io('>', 'gam', gam)
call field_io('>', 'lam', lam)
call field_io('>', 'mu',  mu)
call field_io('>', 'nu',  yy)

! hourglass constant
s = sqrt((dx(1) * dx(1) + dx(2) * dx(2) + dx(3) * dx(3)) / 3.0) / 12.0
!$omp parallel do schedule(static) private(j, k, l)
do l = 1, nm(3)
do k = 1, nm(2)
do j = 1, nm(1)
    r = lam(j,k,l) + 2.0 * mu(j,k,l)
    if (r == 0.0) then
        yy(j,k,l) = 0.0
    else
        yy(j,k,l) = mu(j,k,l) * (lam(j,k,l) + mu(j,k,l)) * s / r
    end if
end do
end do
end do
!$omp end parallel do

! global maxima
call rreduce1(max_g, max_l, 'allmax')

! vs harmonic mean for pml
if (vpml <= 0.0) then
    vmin = -max_g(3)
    vmax =  max_g(9)
    vpml = 2.0 * vmin * vmax / (vmin + vmax)
end if

! Courant condition
vmax = max_g(9)
r = dx(1) * dx(1) + dx(2) * dx(2) + dx(3) * dx(3)
cfl1 = dt * vmax * sqrt(3.0 / r)
cfl2 = dt * vmax * 3.0 / sqrt(r)

! output statistics
if (master) then
    open (1, file='stats-material.txt', status='replace')
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

end module

