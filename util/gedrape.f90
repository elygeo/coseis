! Generate TeraShake grid from 2D mesh and topography
program main
use m_utm
implicit none
integer, parameter :: n1 = 600, n2 = 300
real, parameter :: dx = 1000., pi  = 3.14159265
real :: x(n1,n2,1,2), v1(n1,n2), v2(n1,n2), &
  x1, x2, x3, x4, o1, o2, d1, d2, h1, h2, h3, h4, rot, s, c, h
integer :: i, j, k, j1, k1
character :: endian

! Local TeraGrid mesh in meters
forall( i=1:n1 ) x(i,:,1,1) = dx * ( i - 1 )
forall( i=1:n2 ) x(:,i,1,2) = dx * ( i - 1 )

! Unrotate and translate to UTM
rot = 40. * pi / 180.
c = cos( rot )
s = sin( rot )
do k = 1, size( x, 2 )
do j = 1, size( x, 1 )
  x1 =  c * x(j,k,1,1) + s * x(j,k,1,2)
  x2 = -s * x(j,k,1,1) + c * x(j,k,1,2)
  x(j,k,1,1) = x1
  x(j,k,1,2) = x2
end do
end do
o1 = 132679.8125
o2 = 3824867.
x(:,:,1,1) = x(:,:,1,1) + o1
x(:,:,1,2) = x(:,:,1,2) + o2

! Project UTM zone 11 to lon/lat
call utm2ll( x, 1, 2, 11 )

! Rotate
rot = atan2( &
  ( x(n1,n2,1,1) + x(1,n2,1,1) - x(n1,1,1,1) - x(1,1,1,1) &
  - x(n1,n2,1,2) + x(1,n2,1,2) - x(n1,1,1,2) + x(1,1,1,2) ) , &
  ( x(n1,n2,1,1) - x(1,n2,1,1) + x(n1,1,1,1) - x(1,1,1,1) &
  + x(n1,n2,1,2) + x(1,n2,1,2) - x(n1,1,1,2) - x(1,1,1,2) ) )
print *, 'lon/lat rotation angle: ', rot * 180. / pi
stop
c = cos( rot )
s = sin( rot )
do k = 1, size( x, 2 )
do j = 1, size( x, 1 )
  x1 = c * x(j,k,1,1) - s * x(j,k,1,2)
  x2 = s * x(j,k,1,1) + c * x(j,k,1,2)
  x(j,k,1,1) = x1
  x(j,k,1,2) = x2
end do
end do

! Origin and step size
v1 = x(:,:,1,1)
v2 = x(:,:,1,2)
x1 = minval( v1 )
x2 = maxval( v1 )
x3 = minval( v2 )
x4 = maxval( v2 )
o1 =  c * .5 * ( x1 + x2 ) + s * .5 * ( x1 + x2 )
o2 = -s * .5 * ( x3 + x4 ) + c * .5 * ( x3 + x4 )
d1 = ( x2 - x1 ) / ( n1 - 1 )
d2 = ( x4 - x3 ) / ( n2 - 1 )

! New local mesh in lon/lat
forall( i=1:n1 ) x(i,:,1,1) = d1 * ( i - 1 )
forall( i=1:n2 ) x(:,i,1,2) = d2 * ( i - 1 )

! Unrate and translat to Lon/Lat
do k = 1, size( x, 2 )
do j = 1, size( x, 1 )
  x1 =  c * x(j,k,1,1) + s * x(j,k,1,2)
  x2 = -s * x(j,k,1,1) + c * x(j,k,1,2)
  x(j,k,1,1) = x1
  x(j,k,1,2) = x2
end do
end do
o1 = 132679.8125
o2 = 3824867.
x(:,:,1,1) = x(:,:,1,1) + o1
x(:,:,1,2) = x(:,:,1,2) + o2
! Resample
inquire( iolength=i ) v1
open( 1, file='data', recl=i, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) v1
close( 1 )
h = 30.
o1 = .5 * h - 121.5 * 3600.
o2 = .5 * h +  30.5 * 3600.
do k1 = 1, n2
do j1 = 1, n1
  x1 = ( ( x(j1,k1,1,1) * 3600 ) - o1 ) / h
  x2 = ( ( x(j1,k1,1,2) * 3600 ) - o2 ) / h
  j = int( x1 ) + 1
  k = int( x2 ) + 1
  h1 =  x1 - j + 1
  h2 = -x1 + j
  h3 =  x2 - k + 1
  h4 = -x2 + k
  v2(j1,k1) = ( &
    h2 * h4 * v1(j,k)   + &
    h1 * h4 * v1(j+1,k) + &
    h2 * h3 * v1(j,k+1) + &
    h1 * h3 * v1(j+1,k+1) )
end do
end do

! Byte order
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
print *, 'endian = ', endian

! 2D grid
inquire( iolength=i ) x(:,:,:,1)
open( 1, file='x', recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) x(:,:,:,1)
close( 1 )

! KML file
open( 1, file='image.kml', status='replace' )
write( 1, * ) '<?xml version="1.0" encoding="UTF-8"?>'
write( 1, * ) '<kml xmlns="http://earth.google.com/kml/2.1">'
write( 1, * ) '<GroundOverlay>'
write( 1, * ) '  <name>TeraShake</name>'
write( 1, * ) '  <Icon>'
write( 1, * ) '    <href>image.jpg</href>'
write( 1, * ) '  </Icon>'
write( 1, * ) '  <LatLonBox>'
write( 1, * ) '    <north>35.23584737375541</north>'
write( 1, * ) '    <south>32.22627982622544</south>'
write( 1, * ) '    <east>-114.3542485814704</east>'
write( 1, * ) '    <west>-120.8395935294394</west>'
write( 1, * ) '    <rotation>-40</rotation>'
write( 1, * ) '  </LatLonBox>'
write( 1, * ) '</GroundOverlay>'
write( 1, * ) '</kml>'
close(1)

end program

