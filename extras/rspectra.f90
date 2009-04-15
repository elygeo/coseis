! Response Spectra
! Modified code from Doug Dreger
! Create Python module with f2py -c -m rspec rspec.f90

! real component of displacement spectrum:    rd = z(1)
! real component of velocity spectrum:        rv = z(2)
! real component of acceleration spectrum:    aa = z(3)
! imaginary component of velocity spectrum:   prv = w * z(1)
! imaginary component of velocity spectrum:   pra = w * prv
! imaginary vel = i*w* real displacement   where w = period = 2pi/T
! imaginary acc = i*w* real velocity    

! Use when time sampling is uniform and period >= 10.0 * dt
subroutine cmpmax( z, u, dt, w, d, n )
implicit none
integer, intent(in) :: n
real, intent(in) :: u(n), dt, w, d
real, intent(out) :: z(3)
real :: wd, du, a, b, f1, f2, f4, f5, f6, g1, g2, h1, h2, z1, z2, z3, z4, x1(3), x2(3)
integer :: k
wd = sqrt( 1. - d * d ) * w
x1 = 0.0
x2 = 0.0
z  = 0.0
f1 = 2.0 * d / ( w * w * w * dt )
f2 = 1.0 / ( w * w )
f4 = 1.0 / wd
f5 = d * w / wd
f6 = -2.0 * d * w
g1 = exp( -d * w * dt ) * sin( wd * dt )
g2 = exp( -d * w * dt ) * cos( wd * dt )
h1 = wd * g2 - d * w * g1
h2 = wd * g1 + d * w * g2
do k = 1, n - 1
    du = u(k+1) - u(k)
    z1 = f2 * du
    z2 = f2 * u(k)
    z3 = f1 * du
    z4 = z1 / dt
    b = x1(1) + z2 - z3
    a = f4 * x1(2) + f5 * b + f4 * z4
    x2(1) = a * g1 + b * g2 + z3 - z2 - z1
    x2(2) = a * h1 - b * h2 - z4
    x2(3) = f6 * x2(2) - w * w * x2(1)
    x1 = x2
    z = max( z, abs( x2 ) )
end do
end subroutine

! used for non-uniform time sampling or period < 10.0 * dt
subroutine ucmpmx( z, u, t, w, d, n )
implicit none
integer, intent(in) :: n
real, intent(in) :: u(n), t(n), w, d
real, intent(out) :: z(3)
real :: f10, wd, dt, du, g, a, b, f1, f2, f4, f5, f6, g1, g2, h1, h2, z1, z2, z3, z4, x1(3), x2(3)
integer :: i, k, ns
f10 = 10.0 * w / ( 4.0 * acos( 0.0 ) )
wd = sqrt( 1. - d * d ) * w
x1 = 0.0
x2 = 0.0
z  = 0.0
f2 = 1.0 / ( w * w )
f4 = 1.0 / wd
f5 = d * w / wd
f6 = -2.0 * d * w
do k = 1, n - 1
    g  = u(k)
    dt = t(k+1) - t(k)
    ns = nint( f10 * dt ) + 1
    du = ( u(k+1) - u(k) ) / real( ns )
    dt = dt / real( ns )
    f1 = 2.0 * d / ( w * w * w * dt )
    g1 = exp( -d * w * dt ) * sin( wd * dt )
    g2 = exp( -d * w * dt ) * cos( wd * dt )
    h1 = wd * g2 - d * w * g1
    h2 = wd * g1 + d * w * g2
    z1 = f2 * du
    z3 = f1 * du
    z4 = z1 / dt
    do i = 1, ns
        z2 = f2 * g
        g = g + du
        b = x1(1) + z2 - z3
        a = f4 * x1(2) + f5 * b + f4 * z4
        x2(1) = a * g1 + b * g2 + z3 - z2 - z1
        x2(2) = a * h1 - b * h2 - z4
        x2(3) = f6 * x2(2) - w * w * x2(1)
        x1 = x2
        z = max( z, abs( x2 ) )
    end do
end do
end subroutine

