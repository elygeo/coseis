!------------------------------------------------------------------------------!
! MOMENTSRC

module momentsrc_m
contains
subroutine momentsrc
use globals_m
use dfnc_m

implicit none
save
logical :: init = .true.
integer, allocatable :: jj(:), kk(:), ll(:)
real, allocatable :: msrcx(:), msrcv(:)
integer :: nsrc, ic
real :: time, msrcf

if ( msrcradius <= 0. ) return

if ( init ) then
  init = .false.
  if( verb > 0 ) print '(a)', 'Initialize moment source'
  i1 = i1cell
  i2 = i2cell
  call dfnc( s1, 'g', x, x, dx, 1, 1, i1, i2 )
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    w1(j,k,l,:) = 0.125 * &
    ( x(j,k,l,:) + x(j+1,k+1,l+1,:) &
    + x(j+1,k,l,:) + x(j,k+1,l+1,:) &
    + x(j,k+1,l,:) + x(j+1,k,l+1,:) &
    + x(j,k,l+1,:) + x(j+1,k+1,l,:) );
  end forall
  do i = 1, 3
    w1(:,:,:,i) = w1(:,:,:,i) - xhypo(i)
  end do
  s2 = -1.
  w1 = w1 * w1
  s2(j1:j2,k1:k2,l1:l2) = msrcradius - sqrt( sum( w1(j1:j2,k1:k2,l1:l2,:), 4 ) )
  nsrc = count( s2 > 0. )
  allocate( jj(nsrc), kk(nsrc), ll(nsrc), msrcx(nsrc), msrcv(nsrc) ) 
  msrcx = pack( s2, s2 > 0. )
  msrcv = pack( s1, s2 > 0. )
  msrcx = msrcx / sum( msrcx ) / msrcv
  i = 0
  do l = l1, l2
  do k = k1, k2
  do j = j1, j2
    if ( s2(j,k,l) > 0. ) then
      i = i + 1
      jj(i) = j
      kk(i) = k
      ll(i) = l
    end if
  end do
  end do
  end do
  return
  ! c = [ 1 6 5; 6 2 4; 5 4 3 ]
  ! [ vec, val ] = eig( moment(c) )
  ! m0 = max( abs( val(:) ) )
  ! mw = 2 / 3 * log10( m0 ) - 10.7
  ! um = m0 / miu0 / dx / dx
  ! fprintf( 'Momnent Source\nM0: !g\nMw: !g\nD:  !g\n', m0, mw, um )
end if


if ( .false. ) ! increment stress
  time = ( it - .5 ) * dt
  select case( srctimefcn )
  case( 'delta' );  msrcf = 0.; if ( it == 1 ) msrcf = 1. / dt
  case( 'brune' );  msrcf = exp( -time / domp ) / domp ** 2. * time
  case( 'sbrune' ); msrcf = exp( -time / domp ) / domp ** 3. * time * time / 2.
  case default; stop 'srctimefcn'
  end select
  msrcf = dt * msrcf
else ! direct stress
  time = it * dt
  select case( srctimefcn )
  case( 'delta' );  msrcf = 1.; if ( it == 1 ) msrcf = 1.
  case( 'brune' );  msrcf = 1. - exp( -time / domp ) / domp * ( time + domp )
  case( 'sbrune' ); msrcf = 1. - exp( -time / domp ) / domp * &
    ( time + domp + time * time / domp / 2. )
  case default; stop 'srctimefcn'
  end select
end if

do ic = 1, 3
do i = 1, nsrc
  j = jj(i)
  k = kk(i)
  l = ll(i)
  w1(j,k,l,ic) = w1(j,k,l,ic) - msrcf * msrcx(i) * moment(ic)
  w2(j,k,l,ic) = w2(j,k,l,ic) - msrcf * msrcx(i) * moment(ic+3)
end do
end do

end subroutine
end module

