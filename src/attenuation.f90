! attenuation
module m_attenuation
implicit none
contains

subroutine attenuation
use m_globals
integer :: i
real :: tau1, tau2, omega

tau1 = log( 2.0 * dt )
tau2 = log( 10.0 * dt * nt )

do i = 1, 8
    omega = exp( tau1 + (tau2 - tau1) * (2.0 * k - 1.0) / 16.0 )
    c1(i) = 2.0 * omega * dt / (2.0 + omega * dt)
    c2(i) = 2.0 - omega * dt / (2.0 + omega * dt)
    c3(i) =       omega * dt / (2.0 - omega * dt)
    c4(i) =              2.0 / (2.0 - omega * dt)
end do

end subroutine

end module

