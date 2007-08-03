! Curved mesh
program main
implicit none
real, parameter :: pi = 3.14159
real, allocatable :: x(:,:,:)
real :: ell, dx, phi
integer :: i, j, l, j1, j2, l0, n, m1, m3, cell

cell = 1
dx = 100.
dx = 50.
phi = 30. * pi / 180.
ell = 15000.
n  = nint( ell    / dx ) + 1 - cell
m1 = nint( 35000. / dx ) + 1 - cell
m3 = nint( 25600. / dx )
l0 = m3 / 2
j1 = ( m1 - n ) / 2
j2 = ( m1 - n ) / 2 + n + 1

print *, ' dx = ', dx
print *, ' nn = [ ', m1, ' ? ', m3, ' ];'
print *, ' ihypo = [ ', m1/2, ' ? ', l0, ' ];'

allocate( x(m1,m3,2) )
x = 0.
l = l0
do j = j1+1, j2-1
  x(j,l,1) = .5 * dx * ( j + j - m1 - 1 )
end do
print *, 'x1', minval( x(:,:,1) ), maxval( x(:,:,1) )
print *, 'x3', minval( x(:,:,2) ), maxval( x(:,:,2) )

x(j1,l,1) = x(j1+1,l,1) - dx * cos( phi )
x(j2,l,1) = x(j2-1,l,1) + dx * cos( phi )
x(j1,l,2) = dx * sin( phi ) 
x(j2,l,2) = dx * sin( phi ) 
print *, 'x1', minval( x(:,:,1) ), maxval( x(:,:,1) )
print *, 'x3', minval( x(:,:,2) ), maxval( x(:,:,2) )

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

