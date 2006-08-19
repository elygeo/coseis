! Time integration
module m_timestep
implicit none
contains
subroutine timestep
use m_globals
it = it + 1
t  = it * dt
v  = v  + dt * w1
u  = u  + dt * v
sl = sl + dt * f1
end subroutine
end module

