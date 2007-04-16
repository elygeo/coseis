! Print TeraShake grid points in lon/lat
! compile: f95 -O utm.f90 grid.f90 -o grid
! usage: ./grid > <file>

program main
use m_utm
implicit none
real, parameter :: pi = 3.14159265
real :: dx, theta, o1, o2, x1, x2, h1, h2, h3, h4
real, allocatable :: x(:,:,:,:)
integer :: n1, n2, registration, i, j, k

! parameters
registration = 0 ! 0=cell, 1=node
n1 = 3000        ! number of x grid points
n2 = 1500        ! number of y gridpoints
dx = 200.        ! cell size in meters
theta = -40.     ! UTM rotation
o1 = 132679.8125 ! UTM x offset
o2 = 3824867.    ! UTM y offset

! local meters
allocate( x(n1,n2,1,2) )
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

! write out
do k = 1, n2
do j = 1, n1
  print '(2f10.5,x,a)', x(j,k,1,1), x(j,k,1,2)
end do
end do

end program

