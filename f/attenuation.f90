! Calculate PML damping parameters
module attenuation_m
implicit none
contains

subroutine attenuation
use globals_m
integer :: i
real :: tau1, tau2, omega

tau1 = log( 2. * dt )
tau2 = log( 10. * dt * nt )

do i = 1, 8
  omega = exp( tau1 + ( tau2 - tau1 ) * ( 2 * k - 1 ) / 16 )
  c1(i) = 2. * omega * dt / ( 2. + omega * dt )
  c2(i) = 2. - omega * dt / ( 2. + omega * dt )
  c3(i) =      omega * dt / ( 2. - omega * dt )
  c4(i) =              2. / ( 2. - omega * dt )
end do

end subroutine

end module

