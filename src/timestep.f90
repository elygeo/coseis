! Time integration
module m_timestep
implicit none
contains

subroutine timestep
use m_globals
use m_util
use m_fieldio
use m_stats
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

! Velocity time integration
tm = tm0 + dt * ( it - 1 ) - dt * 0.5
vv = vv + dt * w1
call fieldio( '<>', 'v1', vv(:,:,:,1) )
call fieldio( '<>', 'v2', vv(:,:,:,2) )
call fieldio( '<>', 'v3', vv(:,:,:,3) )
if ( modulo( it, itstats ) == 0 ) then
  call vector_norm( s1, vv, i1core, i2core, (/ 1, 1, 1 /) )
  call scalar_set_halo( s1, -1., i1core, i2core )
  vmax = maxval( s1 )
end if
call fieldio( '>', 'vm2', s1  )

! Displacement time integration
tm = tm0 + dt * ( it - 1 )
uu = uu + dt * vv
call fieldio( '<>', 'u1', uu(:,:,:,1) )
call fieldio( '<>', 'u2', uu(:,:,:,2) )
call fieldio( '<>', 'u3', uu(:,:,:,3) )
if ( modulo( it, itstats ) == 0 ) then
  call vector_norm( s1, uu, i1core, i2core, (/ 1, 1, 1 /) )
  call scalar_set_halo( s1, -1., i1core, i2core )
  umax = maxval( s1 )
end if
call fieldio( '>', 'um2', s1  )

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
  call fieldio( '>', 'sv1',  t1(:,:,:,1) )
  call fieldio( '>', 'sv2',  t1(:,:,:,2) )
  call fieldio( '>', 'sv3',  t1(:,:,:,3) )
  call fieldio( '>', 'svm',  f1          )
  call fieldio( '>', 'psv',  psv         )
  call fieldio( '>', 'su1',  t2(:,:,:,1) )
  call fieldio( '>', 'su2',  t2(:,:,:,2) )
  call fieldio( '>', 'su3',  t2(:,:,:,3) )
  call fieldio( '>', 'sum',  f2          )
  call fieldio( '>', 'sl',   sl          )
  call fieldio( '>', 'trup', trup        )
  call fieldio( '>', 'tarr', tarr        )
  call scalar_set_halo( f1,   -1., i1core, i2core )
  call scalar_set_halo( f2,   -1., i1core, i2core )
  call scalar_set_halo( tarr, -1., i1core, i2core )
  svmax = maxval( f1 )
  sumax = maxval( f2 )
  slmax = maxval( sl )
  tarrmax = maxval( tarr )
end if

end subroutine
end module

