! Curved mesh
program main
implicit none
real, parameter :: pi = 3.14159
real, allocatable :: x(:,:,:)
real :: ell, dx, r, phi, phi1, dphi
integer :: i, j, l, j1, j2, l0, n, m1, m3, cell

cell = 1
dx = 50.
dx = 100.
phi = 60. * pi / 180.
ell = 30000.
r = ell / phi
n  = nint( ell    / dx ) + 1 - cell
m1 = nint( 35000. / dx ) + 1 - cell
m3 = nint( 25400. / dx ) + 2
l0 = m3 / 2
j1 = ( m1 - n ) / 2 + 1
j2 = ( m1 - n ) / 2 + n
phi1 = -.5 * phi
dphi = -phi1 / ( n - 1 + cell )

print *, ' dx = ', dx
print *, ' r  = ', r
print *, ' nn = [ ', m1, ' ? ', m3, ' ];'
print *, ' ihypo = [ ', m1/2, ' ? ', l0, ' ];'

allocate( x(m1,m3,2) )
x = 0.
l = l0
do j = j1, j2
  phi = phi1 + dphi * ( 2 * ( j - j1 ) + cell )
  x(j,l,1) = r * sin( phi )
  x(j,l,2) = r * ( 1. - cos( phi ) )
end do
do j = j1-1, 1, -1
  x(j,l,:) = 2 * x(j+1,l,:) - x(j+2,l,:)
end do
do j = j2+1, m1
  x(j,l,:) = 2 * x(j-1,l,:) - x(j-2,l,:)
end do
print *, 'x1', minval( x(:,:,1) ), maxval( x(:,:,1) )
print *, 'x3', minval( x(:,:,2) ), maxval( x(:,:,2) )
do l = 1, l0-1
  x(:,l,1) = x(:,l0,1)
  x(:,l,2) = x(:,l0,2) + dx * ( l - l0 )
end do
do l = l0+1, m3
  x(:,l,1) = x(:,l0,1)
  x(:,l,2) = x(:,l0,2) + dx * ( l - l0 - 1 )
end do

print *, 'x1', minval( x(:,:,1) ), maxval( x(:,:,1) )
print *, 'x3', minval( x(:,:,2) ), maxval( x(:,:,2) )

inquire( iolength=i ) x(:,:,1)
open( 1, file='x1', recl=i, form='unformatted', access='direct', status='replace' )
open( 2, file='x3', recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) x(:,:,1)
write( 2, rec=1 ) x(:,:,2)
close( 1 )
close( 2 )

end program

