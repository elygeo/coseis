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
integer :: nsrc, ic
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
  do i = 1, 3
    w1(:,:,:,i) = w1(:,:,:,i) - xhypo(i)
  end do
  s2 = msrcradius - sqrt( sum( w1 * w1, 4 ) )
  nsrc = count( s2 > 0. )
  allocate( jj(nsrc), kk(nsrc), ll(nsrc), msrcx(nsrc) ) 
  msrcx = pack( s2, s2 > 0. )
  msrcx = msrcx / sum( msrcx )
  msrcx = msrcx * pack( s1, s2 > 0. )
  msrcf = 0.
  i2 = nl + 2 * nhalo
  j2 = i2(1)
  k2 = i2(2)
  l2 = i2(3)
  jj = pack( (/ (((j,j=1,j2),k=1,k2),l=1,l2) /), s2 > 0. ) 
  kk = pack( (/ (((k,j=1,j2),k=1,k2),l=1,l2) /), s2 > 0. ) 
  ll = pack( (/ (((l,j=1,j2),k=1,k2),l=1,l2) /), s2 > 0. ) 
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
end select
msrcf = msrcf + dt * msrcdf

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

