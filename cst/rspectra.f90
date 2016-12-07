! Response Spectra
!
! Original code by Doug Dreger
! Wrapper by Geoffrey Ely
!
! Create Python module with:
!     f2py -c -m rspectra rspectra.f90
!
! real component of displacement spectrum:    rd = z(1)
! real component of velocity spectrum:        rv = z(2)
! real component of acceleration spectrum:    aa = z(3)
! imaginary component of velocity spectrum:   prv = w * z(1)
! imaginary component of velocity spectrum:   pra = w * prv
! imaginary vel = i*w* real displacement
! imaginary acc = i*w* real velocity

! Wrapper
! u : acceleration time history
! dt : time step length
! w : angular frequency = 2 pi / T
! d : damping ratio
! n : number of samples (automatically determined)
subroutine rspectra(z, u, dt, w, d, n)
implicit none
real, intent(out) :: z(3)
real, intent(in) :: u(n), dt, w, d
integer, intent(in) :: n
!f2py intent(hide) :: n
if (w > 0.4 * acos(0.0) / dt) then
    call ucmpmx(z, u, dt, w, d, n-1)
else
    call cmpmax(z, u, dt, w, d, n-1)
end if
end subroutine

subroutine cmpmax(z, ug, dt, w, d, kug)
real ug(*), x1(3), x2(3), z(3), c(3)
wd = sqrt(1.0 - d * d) * w
w2 = w * w
w3 = w2 * w
do i = 1, 3
    x1(i) = 0.0
    z(i) = 0.0
end do
f1 = 2.0 * d / (w3 * dt)
f2 = 1.0 / w2
f3 = d * w
f4 = 1.0 / wd
f5 = f3 * f4
f6 = 2.0 * f3
e = exp(-f3 * dt)
g1 = e * sin(wd * dt)
g2 = e * cos(wd * dt)
h1 = wd * g2 - f3 * g1
h2 = wd * g1 + f3 * g2
do k = 1, kug
    dug = ug(k+1) - ug(k)
    z1 = f2 * dug
    z2 = f2 * ug(k)
    z3 = f1 * dug
    z4 = z1 / dt
    b = x1(1) + z2 - z3
    a = f4 * x1(2) + f5 * b + f4 * z4
    x2(1) = a * g1 + b * g2 + z3 - z2 - z1
    x2(2) = a * h1 - b * h2 - z4
    x2(3) = -f6 * x2(2) - w2 * x2(1)
    do l = 1, 3
        c(l) = abs(x2(l))
        if (c(l) .gt. z(l)) z(l) = c(l)
        x1(l) = x2(l)
    end do
end do
end subroutine

subroutine ucmpmx(z, ug, dt0, w, d, kug)
real ug(*), z(3), c(3), x1(3), x2(3)
pr = 4.0 * acos(0.0) / w
wd = sqrt(1.0 - d * d) * w
w2 = w * w
w3 = w2 * w
do i = 1, 3
    x1(i) = 0.0
    z(i) = 0.0
end do
f2 = 1.0 / w2
f3 = d * w
f4 = 1.0 / wd
f5 = f3 * f4
f6 = 2.0 * f3
dt = dt0
ns = nint(10.0 * dt / pr)+1
dt = dt / real(ns)
f1 = 2.0 * d / w3 / dt
e = exp(-f3 * dt)
g1 = e * sin(wd * dt)
g2 = e * cos(wd * dt)
h1 = wd * g2 - f3 * g1
h2 = wd * g1 + f3 * g2
do k = 1, kug
    dug = (ug(k+1) - ug(k)) / real(ns)
    g = ug(k)
    z1 = f2 * dug
    z3 = f1 * dug
    z4 = z1 / dt
    do is = 1, ns
        z2 = f2 * g
        b = x1(1) + z2 - z3
        a = f4 * x1(2) + f5 * b + f4 * z4
        x2(1) = a * g1 + b * g2 + z3 - z2 - z1
        x2(2) = a * h1 - b * h2 - z4
        x2(3) = -f6 * x2(2) - w2 * x2(,1)
        do l = 1, 3
            c(l) = abs(x2(l))
            if (c(l) .gt. z(l)) z(l) = c(l)
            x1(l) = x2(l)
        end do
        g = g + dug
    end do
end do
end subroutine

