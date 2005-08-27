!------------------------------------------------------------------------------!
! MOMENTSRC

module momentsrc_m
contains
subroutine momentsrc
use globals_m
use dfnc_m

save
logical :: init = .true.
integer, allocatable :: jj(:), kk(:), ll(:)
real, allocatable :: msrcx(:)
integer :: n
real :: time, domp, msrcdf, msrcf

if ( msrcradius <= 0. ) return

if ( init ) then
  init = .false.
  i1 = i1cell
  i2 = i2cell
  s1(:,:,:) = 0.
  call dfnc( s1, 'g', x, x, dx, 1, 1, i1, i2 )
  where( s1 /= 0. ) s1 = 1. / s1
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  w1 = 2. * msrcradius
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    w1(j,k,l,:) = 0.125 * &
    ( x(j,k,l,:) + x(j+1,k+1,l+1,:) &
    + x(j+1,k,l,:) + x(j,k+1,l+1,:) &
    + x(j,k+1,l,:) + x(j+1,k,l+1,:) &
    + x(j,k,l+1,:) + x(j+1,k+1,l,:) );
  end forall
  do i = 1:3
    w1(:,:,:,i) = w1(:,:,:,i) - xhypo(i)
  end do
  s2 = msrcradius - sqrt( sum( w1 * w1, 4 ) )
  n = count( s2 > 0. )
  allocate( msrci(n,3), msrcx(n) ) 
  ii = 0
  do l = l1, l2
  do k = k1, k2
  do j = j1, j2
    if ( s2(j,k,l) > 0. ) then
      ii = ii + 1
      jj(ii) = j
      kk(ii) = k
      ll(ii) = l
      msrcx(ii) = s2(j,k,l)
    end if
  end do
  end do
  end do
  msrcx = msrcx / sum( msrcx )
  n = ii
  do ii = 1, n
    j = jj(ii)
    k = kk(ii)
    l = ll(ii)
    msrcx(ii) = msrcx(ii) * s1(j,k,l)
  end do
  msrcf = 0.
  return
  ! c = [ 1 6 5; 6 2 4; 5 4 3 ]
  ! [ vec, val ] = eig( moment(c) )
  ! m0 = max( abs( val(:) ) )
  ! mw = 2 / 3 * log10( m0 ) - 10.7
  ! um = m0 / miu0 / dx / dx
  ! fprintf( 'Momnent Source\nM0: !g\nMw: !g\nD:  !g\n', m0, mw, um )
end if

domp = 8 * dt
time = it - .5 * dt
select case( srctimefcn )
case( 'delta' );  msrcdf = 0.; if ( it == 1 ) msrcdf = 1. / dt
case( 'brune' );  msrcdf = time * exp( -time / domp ) / domp ** 2.
case( 'sbrune' ); msrcdf = time ** 2. * exp( -time / domp ) / 2. / domp ** 3.
case default; error srctimefcn
end select
msrcf = msrcf + dt * msrcdf

do i  = 1, 3
do ii = 1, n
  j = jj(ii)
  k = kk(ii)
  l = ll(ii)
  w1(j,k,l,i) = w1(j,k,l,i) - msrcf(ii) * msrcx * moment(i)
  w2(j,k,l,i) = w2(j,k,l,i) - msrcf(ii) * msrcx * moment(i+3)
end do
end do

end subroutine
end module

