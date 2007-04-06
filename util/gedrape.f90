! Generate TeraShake grid from 2D mesh and topography
program main
use m_utm
implicit none
integer, parameter :: n1 = 600, n2 = 300, i1 = 1, i2 = 1, di = 1
real, parameter :: dx = 1000., pi  = 3.14159265, emptyval = 0.
real :: x(n1,n2,1,2), v1(n1,n2), v2(n1,n2), &
  x1, x2, x3, x4, o1, o2, d1, d2, h1, h2, h3, h4, rot, s, c
integer :: i, j, k, j1, k1, ifile
character(160) :: filename

filename = 'template'

! local meters
forall( i=1:n1 ) x(i,:,1,1) = dx * ( i - 1 )
forall( i=1:n2 ) x(:,i,1,2) = dx * ( i - 1 )

! UTM zone 11
o1 = 132679.8125
o2 = 3824867.
rot = 40. * pi / 180.
c = cos( rot )
s = sin( rot )
do k = 1, n2
do j = 1, n1
  x1 = x(j,k,1,1)
  x2 = x(j,k,1,2)
  x(j,k,1,1) =  c * x1 + s * x2 + o1
  x(j,k,1,2) = -s * x1 + c * x2 + o2
end do
end do

! lon/lat
call utm2ll( x, 1, 2, 11 )

! rotate
rot = atan2( &
  ( x(n1,n2,1,1) + x(1,n2,1,1) - x(n1,1,1,1) - x(1,1,1,1) &
  - x(n1,n2,1,2) + x(1,n2,1,2) - x(n1,1,1,2) + x(1,1,1,2) ) , &
  ( x(n1,n2,1,1) - x(1,n2,1,1) + x(n1,1,1,1) - x(1,1,1,1) &
  + x(n1,n2,1,2) + x(1,n2,1,2) - x(n1,1,1,2) - x(1,1,1,2) ) )
c = cos( rot )
s = sin( rot )
do k = 1, n2
do j = 1, n1
  x1 = x(j,k,1,1)
  x2 = x(j,k,1,2)
  x(j,k,1,1) =  c * x1 - s * x2
  x(j,k,1,2) =  s * x1 + c * x2
end do
end do

! origin and step size
v1 = x(:,:,1,1)
v2 = x(:,:,1,2)
x1 = minval( v1 )
x2 = maxval( v1 )
x3 = minval( v2 )
x4 = maxval( v2 )
o1 =  c * .5 * ( x1 + x2 ) + s * .5 * ( x3 + x4 )
o2 = -s * .5 * ( x1 + x2 ) + c * .5 * ( x3 + x4 )
d1 = ( x2 - x1 ) / ( n1 - 1 )
d2 = ( x4 - x3 ) / ( n2 - 1 )

! KML file
open( 1, file=trim(filename)//'.kml', status='replace' )
write( 1, * ) '<?xml version="1.0" encoding="UTF-8"?>'
write( 1, * ) '<kml xmlns="http://earth.google.com/kml/2.1">'
write( 1, * ) '<GroundOverlay>'
write( 1, * ) '  <name>TeraShake</name>'
write( 1, * ) '  <Icon>'
write( 1, * ) '    <href>'//trim(filename)//'.jpg</href>'
write( 1, * ) '  </Icon>'
write( 1, * ) '  <LatLonBox>'
write( 1, * ) '    <north>', o2 + .5 * ( d2 * n2 - d2 ), '</north>'
write( 1, * ) '    <south>', o2 - .5 * ( d2 * n2 - d2 ), '</south>'
write( 1, * ) '    <east>',  o1 + .5 * ( d1 * n1 - d1 ), '</east>'
write( 1, * ) '    <west>',  o1 - .5 * ( d1 * n1 - d1 ), '</west>'
write( 1, * ) '    <rotation>', -rot * 180. / pi, '</rotation>'
write( 1, * ) '  </LatLonBox>'
write( 1, * ) '</GroundOverlay>'
write( 1, * ) '</kml>'
close(1)

! lon/lat
forall( i=1:n1 ) x(i,:,1,1) = x1 + d1 * ( i - 1 )
forall( i=1:n2 ) x(:,i,1,2) = x3 + d2 * ( i - 1 )
do k = 1, n2
do j = 1, n1
  x1 = x(j,k,1,1)
  x2 = x(j,k,1,2)
  x(j,k,1,1) =  c * x1 + s * x2
  x(j,k,1,2) = -s * x1 + c * x2
end do
end do

! UTM zone 11
call ll2utm( x, 1, 2, 11 )

! local meters
o1 = 132679.8125
o2 = 3824867.
rot = 40. * pi / 180.
c = cos( rot )
s = sin( rot )
do k = 1, n2
do j = 1, n1
  x1 = x(j,k,1,1) - o1
  x2 = x(j,k,1,2) - o2
  x(j,k,1,1) = c * x1 - s * x2
  x(j,k,1,2) = s * x1 + c * x2
end do
end do

! loop over arguments
do ifile = 1, command_argument_count()
call get_command_argument( ifile, filename )

! read
inquire( iolength=i ) v1
open( 1, file=filename, recl=i, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) v1
close( 1 )

! resample
v2 = emptyval
do k1 = 1, n2
do j1 = 1, n1
  x1 = x(j1,k1,1,1) / dx
  x2 = x(j1,k1,1,2) / dx
  j = int( x1 ) + 1
  k = int( x2 ) + 1
  if ( j > 0 .and. j < n1 .and. k > 0 .and. k < n2 ) then
    h1 =  x1 - j + 1
    h2 = -x1 + j
    h3 =  x2 - k + 1
    h4 = -x2 + k
    v2(j1,k1) = ( &
      h2 * h4 * v1(j,k)   + &
      h1 * h4 * v1(j+1,k) + &
      h2 * h3 * v1(j,k+1) + &
      h1 * h3 * v1(j+1,k+1) )
  end if
end do
end do

! write
filename = trim( filename ) // './/'
inquire( iolength=i ) v2
open( 1, file=filename, recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) v2
close( 1 )

end do

end program

