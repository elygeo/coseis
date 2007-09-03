! Generate TeraShake mesh for input to the SCEC VM
! Geoffrey Ely, gely@ucsd.edu
! compile: f95 utm.f90 tsgrid.f90 -o tsgrid

program main
use m_tscoords
implicit none
real :: ell(2), dx, theta, o1, o2, h1, h2, h3, h4, o1, o2
real, allocatable :: x(:,:,:,:), t(:,:)
integer :: n(2), i
character :: endian0, endian, b1(4), b2(4)
equivalence (h1,b1), (h2,b2)

! byte order
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
open( 1, file='endian0', status='old' )
read( 1, * ) endian0
close( 1 )

! dimentions
dx = 200.
ell = (/ 600, 300 /) * 1000
n = nint( ell / dx ) + 1

! node centered mesh
allocate( x(n(1),n(2),1,3), t(960,780) )
forall( i=1:n(1) ) x(i,:,:,1) = dx * ( i - 1 )
forall( i=1:n(2) ) x(:,i,:,2) = dx * ( i - 1 )

! lon/lat
call ts2ll( x, 1, 2 )

! topo
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
h = 30.
o1 = .5 * h - 121.5 * 3600.
o2 = .5 * h +  30.5 * 3600.
do k1 = 1, size(w1,2)
do j1 = 1, size(w1,1)
  x1 = ( ( x(j1,k1,1,1) * 3600 ) - o1 ) / h
  x2 = ( ( x(j1,k1,1,2) * 3600 ) - o2 ) / h
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

! output
inquire( iolength=i ) x(:,:,:,3)
open( 3, file='z', recl=i, form='unformatted', access='direct', status='replace' )
write( 3, rec=i ) x(:,:,:,3)
close( 3 )

! cell centered mesh
n = n - 1
deallocate( x, t )
allocate( x(n(1),n(2),1,3) )
forall( i=1:n(1) ) x(i,:,:,1) = dx * ( i - 1 ) + .5 * dx
forall( i=1:n(2) ) x(:,i,:,2) = dx * ( i - 1 ) + .5 * dx

! lon/lat
call ts2ll( x, 1, 2 )

! output
open( 1, file='nn' )
write( 1, * ) product( n )
close( 1 )
inquire( iolength=i ) x(:,:,:,1)
open( 1, file='rlon', recl=i, form='unformatted', access='direct', status='replace' )
open( 2, file='rlat', recl=i, form='unformatted', access='direct', status='replace' )
open( 3, file='rdep', recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=i ) x(:,:,:,1)
write( 2, rec=i ) x(:,:,:,2)
write( 3, rec=i ) x(:,:,:,3)
close( 1 )
close( 2 )
close( 3 )

end program

