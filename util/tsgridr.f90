! Generate TeraShake mesh for input to the SCEC VM
program main
use m_tscoords
implicit none
real :: ell(3), dx, o1, o2, h, xx, yy, h1, h2, h3, h4
real, allocatable :: x(:,:,:,:), t(:,:)
integer :: n(3), i, j, k, j1, k1, reclen
character :: endian

! Dimentions
open( 1, file='dx', status='old' )
read( 1, * ) dx
close( 1 )
ell = (/ 600, 300, 80 /) * 1000
n = nint( ell / dx ) + 1
print *, 'n = ', n

! Byte order
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
print *, 'endian = ', endian

! 2D mesh
allocate( x(n(1),n(2),1,3) )
forall( i=1:n(1) ) x(i,:,:,1) = dx * ( i - 1 )
forall( i=1:n(2) ) x(:,i,:,2) = dx * ( i - 1 )

! Project TeraShake coordinates to lon/lat
call ts2ll( x, 1, 2 )
print *, 'longitude range: ', minval( x(:,:,:,1) ), maxval( x(:,:,:,1) )
print *, 'latitude range: ',  minval( x(:,:,:,2) ), maxval( x(:,:,:,2) )

! Topo
allocate( t(960,780) )
inquire( iolength=reclen ) t
open( 1, file='topo3.'//endian, recl=reclen, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) t
close( 1 )
h  = 30.
o1 = .5 * h - 121.5 * 3600.
o2 = .5 * h +  30.5 * 3600.
do k1 = 1, size(x,2)
do j1 = 1, size(x,1)
  xx = ( ( x(j1,k1,1,1) * 3600 ) - o1 ) / h
  yy = ( ( x(j1,k1,1,2) * 3600 ) - o2 ) / h
  j = int( xx ) + 1
  k = int( yy ) + 1
  h1 =  xx - j + 1
  h2 = -xx + j
  h3 =  yy - k + 1
  h4 = -yy + k
  x(j1,k1,1,3) = ( &
    h2 * h4 * t(j,k)   + &
    h1 * h4 * t(j+1,k) + &
    h2 * h3 * t(j,k+1) + &
    h1 * h3 * t(j+1,k+1) )
end do
end do

! 2D
inquire( iolength=reclen ) x(:,:,:,1)
open( 1, file='lon', recl=reclen, form='unformatted', access='direct', status='replace' )
open( 2, file='lat', recl=reclen, form='unformatted', access='direct', status='replace' )
open( 3, file='z',   recl=reclen, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) x(:,:,:,1)
write( 2, rec=1 ) x(:,:,:,2)
write( 3, rec=1 ) x(:,:,:,3)
close( 1 )
close( 2 )
close( 3 )

stop

! 3D
open( 1, file='nn', status='replace' )
write( 1, * ) product( n )
close( 1 )
inquire( iolength=reclen ) x(:,:,:,1)
open( 1, file='rlon', recl=reclen, form='unformatted', access='direct', status='replace' )
open( 2, file='rlat', recl=reclen, form='unformatted', access='direct', status='replace' )
open( 3, file='rdep', recl=reclen, form='unformatted', access='direct', status='replace' )
do i = 1, n(3)
  x(:,:,:,3) = dx*(n(3)-i)
  write( 1, rec=i ) x(:,:,:,1)
  write( 2, rec=i ) x(:,:,:,2)
  write( 3, rec=i ) x(:,:,:,3)
end do
close( 1 )
close( 2 )
close( 3 )

end program

