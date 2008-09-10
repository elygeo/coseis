! Time step
module m_timestep
implicit none
contains

subroutine timestep
use m_globals
use m_util
integer :: j, k, l

! Status
if ( master ) then
  if ( debug == 2 ) then
    write( 0, * ) 'Time step', it
  else
    write( 0, '(a)', advance='no' ) '.'
    if ( modulo( it, 50 ) == 0 .or. it == nt ) write( 0, '(i6)' ) it
  end if
end if

! Save previous slip velocity
j = ihypo(1)
k = ihypo(2)
l = ihypo(3)
if ( ifn /= 0 ) then
  select case( ifn )
  case( 1 ); t2(1,:,:,:) = vv(j+1,:,:,:) - vv(j,:,:,:)
  case( 2 ); t2(:,1,:,:) = vv(:,k+1,:,:) - vv(:,k,:,:)
  case( 3 ); t2(:,:,1,:) = vv(:,:,l+1,:) - vv(:,:,l,:)
  end select
  f2 = sqrt( sum( t2 * t2, 4 ) )
end if

! Time integration
tm = it * dt
vv = vv + w1 * dt
uu = uu + vv * dt

! Velocity and displacement output
p => pio0
do while( associated( p%next ) )
  p => p%next
  select case( p%field )
  case( 'v1' ); call rio4( 'out', p, .false., vv(:,:,:1) )
  case( 'v2' ); call rio4( 'out', p, .false., vv(:,:,:2) )
  case( 'v3' ); call rio4( 'out', p, .false., vv(:,:,:3) )
  case( 'u1' ); call rio4( 'out', p, .false., uu(:,:,:1) )
  case( 'u2' ); call rio4( 'out', p, .false., uu(:,:,:2) )
  case( 'u3' ); call rio4( 'out', p, .false., uu(:,:,:3) )
  end select
end do

! Fault time integration
if ( ifn /= 0 ) then
  select case( ifn )
  case( 1 ); t1(1,:,:,:) = vv(j+1,:,:,:) - vv(j,:,:,:)
  case( 2 ); t1(:,1,:,:) = vv(:,k+1,:,:) - vv(:,k,:,:)
  case( 3 ); t1(:,:,1,:) = vv(:,:,l+1,:) - vv(:,:,l,:)
  end select
  f1 = sqrt( sum( t1 * t1, 4 ) )
  sl = sl + dt * f1
  psv = max( psv, f1 )
  if ( svtol > 0. ) then
    where ( f1 >= svtol .and. trup > 1e8 )
      trup = tm - dt * ( .5 + ( svtol - f1 ) / ( f2 - f1 ) )
    end where
    where ( f1 >= svtol )
      tarr = 1e9
    end where
    where ( f1 < svtol .and. f2 >= svtol )
      tarr = tm - dt * ( .5 + ( svtol - f1 ) / ( f2 - f1 ) )
    end where
  end if
  select case( ifn )
  case( 1 ); t2(1,:,:,:) = uu(j+1,:,:,:) - uu(j,:,:,:)
  case( 2 ); t2(:,1,:,:) = uu(:,k+1,:,:) - uu(:,k,:,:)
  case( 3 ); t2(:,:,1,:) = uu(:,:,l+1,:) - uu(:,:,l,:)
  end select
  f2 = sqrt( sum( t2 * t2, 4 ) )
  p => pio0
  do while( associated( p%next ) )
    p => p%next
    call rio4( 'out', 'sv1',  t1(:,:,:,1) )
    call rio4( 'out', 'sv2',  t1(:,:,:,2) )
    call rio4( 'out', 'sv3',  t1(:,:,:,3) )
    call rio4( 'out', 'svm',  f1          )
    call rio4( 'out', 'su1',  t2(:,:,:,1) )
    call rio4( 'out', 'su2',  t2(:,:,:,2) )
    call rio4( 'out', 'su3',  t2(:,:,:,3) )
    call rio4( 'out', 'sum',  f2          )
    call rio4( 'out', 'psv',  psv         )
    call rio4( 'out', 'fr',   f1          )
    call rio4( 'out', 'sl',   sl          )
    call rio4( 'out', 'trup', trup        )
    call rio4( 'out', 'tarr', tarr        )
  end do
end if

end subroutine
end module

