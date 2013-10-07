! material model
module material_model
implicit none
contains

subroutine init_material
use globals
use collective
use utilities
use field_io_mod
real :: maxl(14), maxg(14), vmin, vmax, cfl1, cfl2, r, s
integer :: i1(3), i2(3), j1, k1, l1, j2, k2, l2, j, k, l

if (sync) call barrier
if (master) print *, clock(), 'Material model'

! init arrays
call rfill(mr, 0.0, size(mr))
call rfill(lam, 0.0, size(lam))
call rfill(mu, 0.0, size(mu))
call rfill(gam, 0.0, size(gam))

! inputs
call field_io('<', 'rho', mr)
call field_io('<', 'vp',  lam)
call field_io('<', 'vs',  mu)
call field_io('<', 'gam', gam)
call rcopy(lam, s1, size(s1))
call rcopy(mu, s2, size(s2))

! limits
call rlimits(mr, rho1, rho2, size(mr))
call rlimits(s1, vp1, vp2, size(s1))
call rlimits(s2, vs1, vs2, size(s2))

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
call rlimits(gam, gam1, gam2, size(gam))

! this should be taken care of inside field_io now
!call scalar_swap_halo(mr,  nhalo)
!call scalar_swap_halo(s1,  nhalo)
!call scalar_swap_halo(s2,  nhalo)
!call scalar_swap_halo(gam, nhalo)

! halos
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
maxl(1) = -minval(mr(j1:j2,k1:k2,l1:l2))
maxl(2) = -minval(s1(j1:j2,k1:k2,l1:l2))
maxl(3) = -minval(s2(j1:j2,k1:k2,l1:l2))
maxl(4) = -minval(gam(j1:j2,k1:k2,l1:l2))
maxl(5) = -minval(lam(j1:j2,k1:k2,l1:l2))
maxl(6) = -minval(mu(j1:j2,k1:k2,l1:l2))
maxl(7) = -minval(yy(j1:j2,k1:k2,l1:l2))

! maxima
maxl(8)  = maxval(mr(j1:j2,k1:k2,l1:l2))
maxl(9)  = maxval(s1(j1:j2,k1:k2,l1:l2))
maxl(10) = maxval(s2(j1:j2,k1:k2,l1:l2))
maxl(11) = maxval(gam(j1:j2,k1:k2,l1:l2))
maxl(12) = maxval(lam(j1:j2,k1:k2,l1:l2))
maxl(13) = maxval(mu(j1:j2,k1:k2,l1:l2))
maxl(14) = maxval(yy(j1:j2,k1:k2,l1:l2))

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
call rreduce1(maxg, maxl, 'allmax')

! vs harmonic mean for pml
if (vpml <= 0.0) then
    vmin = -maxg(3)
    vmax =  maxg(9)
    vpml = 2.0 * vmin * vmax / (vmin + vmax)
end if

! Courant condition
vmax = maxg(9)
r = dx(1) * dx(1) + dx(2) * dx(2) + dx(3) * dx(3)
cfl1 = dt * vmax * sqrt(3.0 / r)
cfl2 = dt * vmax * 3.0 / sqrt(r)

! output statistics
if (master) then
    open (1, file='material.json', status='replace')
    write (1,*) '{'
    write (1,*) '"cfl": [', cfl1,     ', ', cfl2,     '],'
    write (1,*) '"rho": [', -maxg(1), ', ', maxg(8),  '],'
    write (1,*) '"vp":  [', -maxg(2), ', ', maxg(9),  '],'
    write (1,*) '"vs":  [', -maxg(3), ', ', maxg(10), '],'
    write (1,*) '"gam": [', -maxg(4), ', ', maxg(11), '],'
    write (1,*) '"lam": [', -maxg(5), ', ', maxg(12), '],'
    write (1,*) '"mu":  [', -maxg(6), ', ', maxg(13), '],'
    write (1,*) '"nu":  [', -maxg(7), ', ', maxg(14), '],'
    write (1,*) '}'
    close (1)
    if (any(maxg(1:7) > 0.0)) stop 'negative moduli'
    if (cfl2 > 1.0) stop 'Courant condition not satisfied!'
end if

end subroutine

end module

