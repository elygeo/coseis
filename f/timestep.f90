! Time step
module m_timestep
implicit none
contains

subroutine timestep
use m_globals
use m_util
integer :: j, k, l

! Save previous slip velocity
if ( ifn /= 0 ) then
  j = ihypo(1)
  k = ihypo(2)
  l = ihypo(3)
  select case( ifn )
  case( 1 ); t2(1,:,:,:) = v(j+1,:,:,:) - v(j,:,:,:)
  case( 2 ); t2(:,1,:,:) = v(:,k+1,:,:) - v(:,k,:,:)
  case( 3 ); t2(:,:,1,:) = v(:,:,l+1,:) - v(:,:,l,:)
  end select
  f2 = sqrt( sum( t2 * t2, 4 ) )
end if

! Time integration
it = it + 1
t  = it * dt
v  = v  + dt * w1
u  = u  + dt * v

! Fault time integration
if ( ifn /= 0 ) then
  select case( ifn )
  case( 1 ); t1(1,:,:,:) = v(j+1,:,:,:) - v(j,:,:,:)
  case( 2 ); t1(:,1,:,:) = v(:,k+1,:,:) - v(:,k,:,:)
  case( 3 ); t1(:,:,1,:) = v(:,:,l+1,:) - v(:,:,l,:)
  end select
  f1 = sqrt( sum( t1 * t1, 4 ) )
  sl = sl + dt * f1
  psv = max( psv, f1 )
  if ( svtol > 0. ) then
    where ( f1 >= svtol .and. trup > 1e8 )
      trup = t - dt * ( .5 + ( svtol - f1 ) / ( f2 - f1 ) )
    end where
    where ( f1 >= svtol )
      tarr = 1e9
    end where
    where ( f1 < svtol .and. f2 >= svtol )
      tarr = t - dt * ( .5 + ( svtol - f1 ) / ( f2 - f1 ) )
    end where
  end if
  select case( ifn )
  case( 1 ); t2(1,:,:,:) = u(j+1,:,:,:) - u(j,:,:,:)
  case( 2 ); t2(:,1,:,:) = u(:,k+1,:,:) - u(:,k,:,:)
  case( 3 ); t2(:,:,1,:) = u(:,:,l+1,:) - u(:,:,l,:)
  end select
  f2 = sqrt( sum( t2 * t2, 4 ) )
end if

end subroutine
end module

