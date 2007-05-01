! Generate TeraShake mesh for input to the SCEC VM
! Geoffrey Ely, gely@ucsd.edu
! compile: f95 utm.f90 tsgrid.f90 -o tsgrid

program main
use m_tscoords
implicit none
real :: ell(3), dx, theta, o1, o2, h1, h2, h3, h4, o1, o2
real, allocatable :: x(:,:,:,:)
integer :: n(3), i
character :: endian

! Dimentions
dx = 20000.
ell = (/ 600, 300, 80 /) * 1000
n = nint( ell / dx ) + 1

! 2D mesh in local meters
allocate( x(n(1),n(2),1,3) )
forall( i=1:n(1) ) x(i,:,:,1) = dx * ( i - 1 )
forall( i=1:n(2) ) x(:,i,:,2) = dx * ( i - 1 )

! UTM zone 11
theta = -45.     ! UTM rotation
o1 = 132679.8125 ! UTM x offset
o2 = 3824867.    ! UTM y offset
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

! Output
open( 1, file='nn' )
write( 1, * ) product( n )
close( 1 )
inquire( iolength=i ) x(:,:,:,1)
open( 1, file='rlon', recl=i, form='unformatted', access='direct', status='replace' )
open( 2, file='rlat', recl=i, form='unformatted', access='direct', status='replace' )
open( 3, file='rdep', recl=i, form='unformatted', access='direct', status='replace' )
do i = 1, n(3)
  x(:,:,:,3) = dx * ( i - 1 )
  write( 1, rec=i ) x(:,:,:,1)
  write( 2, rec=i ) x(:,:,:,2)
  write( 3, rec=i ) x(:,:,:,3)
end do
close( 1 )
close( 2 )
close( 3 )

end program

