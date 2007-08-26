! 2d Semicircular canyon mesh
program main
implicit none
integer :: i, n, n1, n2
real :: pi, dx, r, phi
real, allocatable :: x(:,:,:)

pi = 3.14159
dx = 100.
n  = 160
n1 = 227
n2 = 4 * n + 1
allocate( x(n1,n2,2) )

! Semicircle edge
do i = 1, n2
  phi = pi * ( i - 1 ) / ( n2 - 1 )
  x(1,i,1) = -dx * cos( phi )
  x(1,i,2) =  dx * sin( phi )
end do

! Outer edge
r = dx / sqrt( 2. ) * n1
do i = 1, n
  x(n1,i,1) = -r
  x(n1,i,2) = r * ( i - 1 ) / n
end do
do i = n + 1, 3 * n
  x(n1,i,1) = r * ( i - 1 - n - n ) / n
  x(n1,i,2) = r
end do
do i = 3 * n + 1, n2
  x(n1,i,1) = r
  x(n1,i,2) = r * ( n2 - i ) / n
end do

! Blend
do i = 2, n1-1
  x(i,:,:) = x(1,:,:)*(n1-i)/(n1-1) + x(n1,:,:)*(i-1)/(n1-1)
end do

! Output
inquire( iolength=i ) x(:,:,1)
open( 1, file='x1', recl=i, form='unformatted', access='direct', status='replace' )
open( 2, file='x2', recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) x(:,:,1)
write( 2, rec=1 ) x(:,:,2)
close( 1 )
close( 2 )

end program

