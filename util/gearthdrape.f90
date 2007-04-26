! Project TeraShake surface snapshot data to lon/lat for viewing in Google Earth.
! Also generates a Google Earth KML file with time animation called 'tmp.kml'.
! You must create the images using a separate plotting program of your choice.
! Geoffrey Ely, 2007-04-10
! compile: f95 -O utm.f90 gearthdrape.f90 -o gearthdrape
! usage: ./gearthdrape <file1> <file2> <file3> ...

program main
use m_utm
implicit none
real, parameter :: pi = 3.14159265
real :: dx, lon0, lat0, phi, emptyval, theta, o1, o2
real :: x1, x2, h1, h2, h3, h4, dlon, dlat
real, allocatable :: x(:,:,:,:), v1(:,:), v2(:,:)
integer :: n1, n2, registration, i, j, k, j1, k1, iarg, ifile
character(160) :: str
logical :: swab
character :: c1(4), c2(4)
equivalence (x1,c1), (x2,c2)

! parameters
registration = 0 ! 0=cell, 1=node
emptyval = 0.    ! value for points outside the data region
n1 = 3000        ! number of x grid points
n2 = 1500        ! number of y gridpoints
dx = 200.        ! cell size in meters
lon0 = -117.478  ! center longitude
lat0 =   33.852  ! center latitude
phi   = -39.65   ! lon/lat rotation
theta = -40.     ! UTM rotation
o1 = 132679.8125 ! UTM x offset
o2 = 3824867.    ! UTM y offset

do iarg = 1, command_argument_count()
  call get_command_argument( iarg, str )
  if ( str(1:1) /= '-' ) exit
  select case( str )
  case( '-s' ); swab = .true.
  case default; stop 'Usage: gearthdrape [-s] <file1> <file2> ...'
  end select
end do

! local meters
allocate( x(n1,n2,1,2), v1(n1,n2), v2(n1,n2) )
forall( i=1:n1 ) x(i,:,1,1) = dx * ( i - 1 )
forall( i=1:n2 ) x(:,i,1,2) = dx * ( i - 1 )
if ( registration == 0 ) x = x + .5 * dx

! UTM zone 11
h1 =  cos( theta / 180. * pi )
h2 =  sin( theta / 180. * pi )
h3 = -sin( theta / 180. * pi )
h4 =  cos( theta / 180. * pi )
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
h1 =  cos( phi / 180. * pi ) / cos( lat0 * pi / 180. )
h2 =  sin( phi / 180. * pi )
h3 = -sin( phi / 180. * pi )
h4 =  cos( phi / 180. * pi ) * cos( lat0 * pi / 180. )
do k = 1, n2
do j = 1, n1
  x1 = x(j,k,1,1) - lon0
  x2 = x(j,k,1,2) - lat0
  x(j,k,1,1) = h4 * x1 + h2 * x2
  x(j,k,1,2) = h3 * x1 + h1 * x2
end do
end do

! lon/lat resolution
dlon = 2. * maxval( abs( x(:,:,1,1) ) ) / ( n1 - 1 )
dlat = 2. * maxval( abs( x(:,:,1,2) ) ) / ( n2 - 1 )

! KML snippet
x1 = .5 * ( dlon * n1 - dlon ) / cos( lat0 * pi / 180. )
x2 = .5 * ( dlat * n2 - dlat ) * cos( lat0 * pi / 180. )
print *, '   <north>', lat0 + x2, '</north>'
print *, '   <south>', lat0 - x2, '</south>'
print *, '   <east>',  lon0 + x1, '</east>'
print *, '   <west>',  lon0 - x1, '</west>'
print *, '   <rotation>', phi, '</rotation>'

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

! KML initialize
open( 2, file='tmp.kml', status='replace' )
write( 2, '(a)' ) '<?xml version="1.0" encoding="UTF-8"?>'
write( 2, '(a)' ) '<kml xmlns="http://earth.google.com/kml/2.1">'
write( 2, '(a)' ) '<Folder>'
write( 2, '(a)' ) '<ScreenOverlay>'
write( 2, '(a)' ) '  <name>Legend</name>'
write( 2, '(a)' ) '  <Icon>'
write( 2, '(a)' ) '    <href>legend.png</href>'
write( 2, '(a)' ) '  </Icon>'
write( 2, '(a)' ) '  <overlayXY x=".5" y="0"  xunits="fraction" yunits="pixels" />'
write( 2, '(a)' ) '  <screenXY  x=".5" y="80" xunits="fraction" yunits="pixels" />'
write( 2, '(a)' ) '</ScreenOverlay>'

! loop over arguments
do ifile = iarg, command_argument_count()
call get_command_argument( ifile, str )

! read
inquire( iolength=i ) v1
open( 1, file=str, recl=i, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) v1
close( 1 )

! swap bytes
if ( swab ) then
do k = 1, n2
do j = 1, n1
  x1 = v1(j,k)
  c2(4) = c1(1)
  c2(3) = c1(2)
  c2(2) = c1(3)
  c2(1) = c1(4)
  v1(j,k) = x2
end do
end do
end if

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
str = trim( str ) // '.ll'
inquire( iolength=i ) v2
open( 1, file=str, recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) v2
close( 1 )

! KML
x1 = .5 * ( dlon * n1 - dlon ) / cos( lat0 * pi / 180. )
x2 = .5 * ( dlat * n2 - dlat ) * cos( lat0 * pi / 180. )
write( 2, '(a)' ) '<GroundOverlay>'
write( 2, * )    ' <name>Image</name>'
write( 2, * )    ' <Icon>'
write( 2, * )    '   <href>'//trim(str)//'.png</href>'
write( 2, * )    ' </Icon>'
write( 2, * )    ' <TimeSpan>'
write( 2, * )    '   <begin>', ifile, '</begin>'
write( 2, * )    ' </TimeSpan>'
write( 2, * )    ' <drawOrder>', ifile, '</drawOrder>'
write( 2, * )    ' <LatLonBox>'
write( 2, * )    '   <north>', lat0 + x2, '</north>'
write( 2, * )    '   <south>', lat0 - x2, '</south>'
write( 2, * )    '   <east>',  lon0 + x1, '</east>'
write( 2, * )    '   <west>',  lon0 - x1, '</west>'
write( 2, * )    '   <rotation>', phi, '</rotation>'
write( 2, * )    ' </LatLonBox>'
write( 2, '(a)' ) '</GroundOverlay>'

end do

! KML finalize
write( 2, '(a)' ) '</Folder>'
write( 2, '(a)' ) '</kml>'
close(2)

end program

