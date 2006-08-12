! Time Step
module m_timestep
implicit none
contains

subroutine timestep
use m_globals
use m_tictoc
use m_collective
integer :: i1(3), i2(3), j1, k1, l1, j2, k2, l2, j3, k3, l3, j4, k4, l4
real :: de

if ( master ) call toc( 'Time integration' )

! Time integration
it = it + 1
t  = t  + dt
v  = v  + dt * w1
u  = u  + dt * v

! Fault time integration
if ( ifn /= 0 ) then
  i1 = 1
  i2 = nm
  i1(ifn) = ihypo(ifn)
  i2(ifn) = ihypo(ifn)
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  i1(ifn) = ihypo(ifn) + 1
  i2(ifn) = ihypo(ifn) + 1
  j3 = i1(1); j4 = i2(1)
  k3 = i1(2); k4 = i2(2)
  l3 = i1(3); l4 = i2(3)
  t1 = v(j3:j4,k3:k4,l3:l4,:) - v(j1:j2,k1:k2,l1:l2,:)
  t2 = u(j3:j4,k3:k4,l3:l4,:) - u(j1:j2,k1:k2,l1:l2,:)
  f1 = sqrt( sum( t1 * t1, 4 ) )
  f2 = sqrt( sum( t2 * t2, 4 ) )
  sl = sl + dt * f1
  if ( svtol > 0. ) then
    where ( f1 >= svtol .and. trup > 1e8 )
      trup = t - dt * ( .5 + ( svtol - f1 ) / ( svm - f1 ) )
    end where
    where ( f1 >= svtol )
      tarr = 1e9
    end where
    where ( f1 < svtol .and. svm >= svtol )
      tarr = t - dt * ( .5 + ( svtol - f1 ) / ( svm - f1 ) )
    end where
  end if
  svm = f1
  psv = max( psv, f1 )
  work = .5 * sum( sum( ( t0 + t3 ) * t2, 4 ) * area )
  call psum( work, ifn )
  de = dt * sum( sum( t1 * t3, 4 ) * area )
  call psum( de, ifn )
  efrac = efrac + de
end if

end subroutine

end module

