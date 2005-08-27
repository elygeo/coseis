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
real :: time, msrcdf, msrcf

if ( msrcradius == 0. ) return

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
    if msrcnodealign
      w1(:,:,:,i) = w1(:,:,:,i) - xh(1,1,1,i)
    else
      w1(:,:,:,i) = w1(:,:,:,i) - 0.125 * sum( xh(:,:,:,i) )
    end if
  end do
  s2 = msrcradius - sqrt( sum( w1 * w1, 4 ) )
  n = count( s2 > 0. )
  allocate( msrci(n,3), msrcx(n) ) 
  i = 0
  do l = l1, l2
  do k = k1, k2
  do j = j1, j2
    if ( s2(j,k,l) > 0. ) then
      i = i + 1
      jj(i) = j
      kk(i) = k
      ll(i) = l
      msrcx(i) = s2(j,k,l)
    end if
  end do
  end do
  end do
  n = i
  msrcx = msrcx / sum( msrcx )
  forall( i=1:n ) msrcx(i) = msrcx(i) * s1(jj(i),kk(i),ll(i))
  ! c = [ 1 6 5; 6 2 4; 5 4 3 ]
  ! [ vec, val ] = eig( moment(c) )
  ! m0 = max( abs( val(:) ) )
  ! mw = 2 / 3 * log10( m0 ) - 10.7
  ! um = m0 / miu0 / dx / dx
  ! fprintf( 'Momnent Source\nM0: !g\nMw: !g\nD:  !g\n', m0, mw, um )
  return
  msrcf = 0.
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

do i = 0, 2
  w1(msrci+o*i) = w1(msrci+o*i) - msrcf(it) * msrcx * moment(i+1)
  w2(msrci+o*i) = w2(msrci+o*i) - msrcf(it) * msrcx * moment(i+4)
end do

end subroutine
end module
