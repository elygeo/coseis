! Interpolate topo onto TeraShake mesh
program main
use m_tscoords
implicit none
real :: ell(2), dx, x1, x2, o1, o2, h, h1, h2, h3, h4
real, allocatable :: x(:,:,:,:), t(:,:)
integer :: n(2), i, j, k, j1, k1
character :: endian0, endian, b1(4), b2(4)
equivalence (h1,b1), (h2,b2)

! Byte order
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
open( 1, file='endian0', status='old' )
read( 1, * ) endian0
close( 1 )

! Dimensions
dx = 200.
ell = (/ 600, 300 /) * 1000
n = nint( ell / dx )
allocate( x(n(1),n(2),1,3), t(960,780) )
print *, n

! Cell centered mesh
forall( i=1:n(1) ) x(i,:,:,1) = dx * ( i - 1 ) + .5 * dx
forall( i=1:n(2) ) x(:,i,:,2) = dx * ( i - 1 ) + .5 * dx
call ts2ll( x, 1, 2 )

! Interpolate topography
inquire( iolength=i ) t
open( 1, file='topo3.f32', recl=i, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) t
close( 1 )
if ( endian /= endian0 ) then
do k = 1, size( t, 2 )
do j = 1, size( t, 1 )
  h1 = t(j,k)
  b2(4) = b1(1)
  b2(3) = b1(2)
  b2(2) = b1(3)
  b2(1) = b1(4)
  t(j,k) = h2
end do
end do
end if
h = 3600. / 30.
o1 = .5 - 121.5 * h
o2 = .5 +  30.5 * h
do k1 = 1, size( x, 2 )
do j1 = 1, size( x, 1 )
  x1 = x(j1,k1,1,1) * h - o1
  x2 = x(j1,k1,1,2) * h - o2
  j = int( x1 ) + 1
  k = int( x2 ) + 1
  h1 =  x1 - j + 1
  h2 = -x1 + j
  h3 =  x2 - k + 1
  h4 = -x2 + k
  x(j1,k1,1,3) = ( &
    h2 * h4 * t(j,k)   + &
    h1 * h4 * t(j+1,k) + &
    h2 * h3 * t(j,k+1) + &
    h1 * h3 * t(j+1,k+1) )
end do
end do

! Output
inquire( iolength=i ) x(:,:,:,3)
open( 3, file='x3', recl=i, form='unformatted', access='direct', status='replace' )
write( 3, rec=1 ) x(:,:,:,3)
close( 3 )

end program

