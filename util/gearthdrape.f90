! Drape TeraShake surface snapshots for draping in Google Earth
! Geoffrey Ely, 2007-04-10
program main
use m_utm
implicit none
real, parameter :: pi = 3.14159265
real :: dx, dt, lon0, lat0, phi, emptyval, theta, o1, o2
real :: x1, x2, h1, h2, h3, h4, dlon, dlat, r
real, allocatable :: x(:,:,:,:), v1(:,:), v2(:,:)
integer :: n1, n2, registration, i, j, k, j1, k1, ifile
character(160) :: filename

! parameters
registration = 0 ! 0=cell, 1=node
emptyval = 0.    ! value for points outside the data region
n1 = 3000        ! number of x grid points
n2 = 1500        ! number of y gridpoints
dx = 200.        ! cell size in meters
dt = .008        ! time step
lon0 = -117.478  ! center longitude
lat0 =   33.852  ! center latitude
phi   = -39.65   ! lon/lat rotation
theta = -40.     ! UTM rotation
o1 = 132679.8125 ! UTM x offset
o2 = 3824867.    ! UTM y offset

! local meters
allocate( x(n1,n2,1,2), v1(n1,n2), v2(n1,n2) )
forall( i=1:n1 ) x(i,:,1,1) = dx * ( i - 1 )
forall( i=1:n2 ) x(:,i,1,2) = dx * ( i - 1 )
if ( registration == 0 ) x = x + .5 * dx

! UTM zone 11
h1 =  cos( -theta / 180. * pi )
h2 =  sin( -theta / 180. * pi )
h3 = -sin( -theta / 180. * pi )
h4 =  cos( -theta / 180. * pi )
do k = 1, n2
do j = 1, n1
  x1 = x(j,k,1,1)
  x2 = x(j,k,1,2)
  x(j,k,1,1) = h1 * x1 + h3 * x2 + o1
  x(j,k,1,2) = h2 * x1 + h4 * x2 + o2
end do
end do

! lon/lat
call utm2ll( x, 1, 2, 11 )

! rotate
r = phi / 180. * pi
h1 =  cos( r ) / cos( lat0 * pi / 180. )
h2 =  sin( r )
h3 = -sin( r )
h4 =  cos( r ) * cos( lat0 * pi / 180. )
do k = 1, n2
do j = 1, n1
  x1 = x(j,k,1,1) - lon0
  x2 = x(j,k,1,2) - lat0
  x(j,k,1,1) = h4 * x1 + h2 * x2
  x(j,k,1,2) = h3 * x1 + h1 * x2
end do
end do

! origin and step size
dlon = 2. * maxval( abs( x(:,:,1,1) ) ) / ( n1 - 1 )
dlat = 2. * maxval( abs( x(:,:,1,2) ) ) / ( n2 - 1 )

! lon/lat
forall( i=1:n1 ) x(i,:,1,1) = -dlon * ( .5 + .5 * n1 - i )
forall( i=1:n2 ) x(:,i,1,2) = -dlat * ( .5 + .5 * n2 - i )
do k = 1, n2
do j = 1, n1
  x1 = x(j,k,1,1)
  x2 = x(j,k,1,2)
  x(j,k,1,1) = h1 * x1 + h3 * x2 + lon0
  x(j,k,1,2) = h2 * x1 + h4 * x2 + lat0
end do
end do

! UTM zone 11
call ll2utm( x, 1, 2, 11 )

! local meters
h1 =  cos( theta / 180. * pi )
h2 =  sin( theta / 180. * pi )
h3 = -sin( theta / 180. * pi )
h4 =  cos( theta / 180. * pi )
do k = 1, n2
do j = 1, n1
  x1 = x(j,k,1,1) - o1
  x2 = x(j,k,1,2) - o2
  x(j,k,1,1) = h4 * x1 + h2 * x2
  x(j,k,1,2) = h3 * x1 + h1 * x2
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
filename = trim( filename ) // '.ll'
inquire( iolength=i ) v2
open( 1, file=filename, recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) v2
close( 1 )

! KML file
x1 = .5 * ( dlon * n1 - dlon ) / cos( lat0 * pi / 180. )
x2 = .5 * ( dlat * n2 - dlat ) * cos( lat0 * pi / 180. )
open( 1, file=trim(filename)//'.kml', status='replace' )
write( 1, '(a)' ) '<?xml version="1.0" encoding="UTF-8"?>'
write( 1, '(a)' ) '<kml xmlns="http://earth.google.com/kml/2.1">'
write( 1, '(a)' ) '<Folder>'
write( 1, '(a)' ) '<GroundOverlay>'
write( 1, * )    ' <name>Image</name>'
write( 1, * )    ' <Icon>'
write( 1, * )    '   <href>'//trim(filename)//'.png</href>'
write( 1, * )    ' </Icon>'
write( 1, * )    ' <LatLonBox>'
write( 1, * )    '   <north>', lat0 + x2, '</north>'
write( 1, * )    '   <south>', lat0 - x2, '</south>'
write( 1, * )    '   <east>',  lon0 + x1, '</east>'
write( 1, * )    '   <west>',  lon0 - x1, '</west>'
write( 1, * )    '   <rotation>', phi, '</rotation>'
write( 1, * )    ' </LatLonBox>'
write( 1, '(a)' ) '</GroundOverlay>'
write( 1, '(a)' ) '<ScreenOverlay>'
write( 1, '(a)' ) '  <name>Legend</name>'
write( 1, '(a)' ) '  <Icon>'
write( 1, '(a)' ) '    <href>legend.png</href>'
write( 1, '(a)' ) '  </Icon>'
write( 1, '(a)' ) '  <overlayXY x=".5" y="0"  xunits="fraction" yunits="pixels" />'
write( 1, '(a)' ) '  <screenXY  x=".5" y="80" xunits="fraction" yunits="pixels" />'
write( 1, '(a)' ) '</ScreenOverlay>'
write( 1, '(a)' ) '</Folder>'
write( 1, '(a)' ) '</kml>'
close(1)

end do

end program

