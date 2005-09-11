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
integer :: nsrc, ic, eiginfo
real :: time, msrcf, m0, mm(3,3), eigval(3), eigwork(8)

if ( msrcradius <= 0. ) return

inittrue: if ( init ) then

init = .false.
if ( ip == 0 ) print '(a)', 'Moment source'

i1 = i1cell
i2 = i2cell
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

! Cell volumes
s1 = 0.
call dfnc( s1, 'g', x, x, dx, 1, 1, i1, i2 )

! Cell center locations
w1 = 2 * msrcradius
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  w1(j,k,l,:) = 0.125 * &
    ( x(j,k,l,:) + x(j+1,k+1,l+1,:) &
    + x(j+1,k,l,:) + x(j,k+1,l+1,:) &
    + x(j,k+1,l,:) + x(j+1,k,l+1,:) &
    + x(j,k,l+1,:) + x(j+1,k+1,l,:) );
end forall

! Cell center hypocentral distance
do i = 1, 3
  w1(:,:,:,i) = w1(:,:,:,i) - x0(i)
end do

! Find cells within msrcradius
s2 = msrcradius - sqrt( sum( w1 * w1, 4 ) )
nsrc = count( s2 > 0. )
allocate( jj(nsrc), kk(nsrc), ll(nsrc), msrcx(nsrc), msrcv(nsrc) ) 

! Spatial weighting function
msrcv = pack( s1, s2 > 0. )
msrcx = pack( s2, s2 > 0. )
msrcx = msrcx / sum( msrcx ) / msrcv

! Index map
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

s1 = 0.
s2 = 0.

! Print some info, requires LAPACK for eigenvalue calculation
if ( hypop ) then
  mm(1,1) = moment(1)
  mm(2,2) = moment(2)
  mm(3,3) = moment(3)
  mm(2,3) = moment(4)
  mm(1,3) = moment(5)
  mm(1,2) = moment(6)
  call ssyev( 'N', 'U', 3, mm, 3, eigval, eigwork, size(eigwork), eiginfo )
  m0 = maxval( abs( eigval ) )
  print '(a,es12.4)', '  M0:', m0
  print '(a,es12.4)', '  Mw:', 2. / 3. * log10( m0 ) - 10.7
  print '(a,es12.4)', '  D: ', m0 / mu0 / dx / dx
end if

return

end if inittrue

!------------------------------------------------------------------------------!

! time indexing goes wi vi wi+1 vi+1 ...
if ( .false. ) then ! increment stress
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

