! Generate TeraShake grid from 2D mesh and topography
program grid
use tscoords_m
use surfnormals_m
implicit none
real :: dx, h, o1, o2, z0, h1, h2, h3, h4, ell(3), yf0, xf(10), yf(10)
integer :: n(3), nn, npml, nt1, nt2, i, j, k, l, jj, kk, i1(3), i2(3), reclen
real, allocatable :: x(:,:,:,:), w(:,:,:,:), s(:,:,:), topo(:,:)

npml = 10
dx = 4000.
ell = (/ 600, 300, 80 /) * 1000
yf0 = 200000
n = nint( ell / dx ) + 1
j = n(1)
k = n(2)
l = n(3)
nn = j * k * l
allocate( x(j,k,1,3), w(j,k,1,3), s(j,k,1) )
open( 1, file='nn' )
write( 1, * ) nn
close( 1 )
xf = (/ 0,dx*npml,265864.,293831.,338482.,364062.,390075.,459348.,ell(1)-dx*npml,ell(1)/)
yf = (/ yf0, yf0, 183273.,187115.,200421.,212782.,215126.,210481., yf0, yf0 /)
k = nint( yf0 / dx ) + 1
i = 1
do j = 1, n(1)
  x(j,:,:) = dx*(j-1)
end do

! Topo
nt1 = 960
nt2 = 780
allocate( topo(nt1,nt2) )
inquire( iolength=reclen ) topo
open( 1, file='topo.bin', recl=reclen, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) topo
close( 1 )

! 2D x/y
inquire( iolength=reclen ) x(:,:,:,1)
open( 1, file='x', recl=reclen, form='unformatted', access='direct', status='old' )
open( 2, file='y', recl=reclen, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) x(:,:,:,1)
read( 2, rec=1 ) x(:,:,:,2)
close( 1 )
close( 2 )

! 3D x/y
open( 1, file='x1', recl=reclen, form='unformatted', access='direct' )
open( 2, file='x2', recl=reclen, form='unformatted', access='direct' )
do i = 1, n(3)
  write( 1, rec=i ) x(:,:,:,1)
  write( 2, rec=i ) x(:,:,:,2)
end do
close( 1 )
close( 2 )

! lat/lon
w = x
call ts2ll( w, 1, 2 )

! PML regions are orthogonal
j = n(1)
k = n(2)
do i = 0, npml-1
  w(1+i,:,:,:) = w(1+npml,:,:,:)
  w(j-i,:,:,:) = w(j-npml,:,:,:)
  w(:,1+i,:,:) = w(:,1+npml,:,:)
  w(:,k-i,:,:) = w(:,k-npml,:,:)
end do

! 3D lat/lon
open( 1, file='rlon', recl=reclen, form='unformatted', access='direct' )
open( 2, file='rlat', recl=reclen, form='unformatted', access='direct' )
do i = 1, n(3)
  write( 1, rec=i ) w(:,:,:,1)
  write( 2, rec=i ) w(:,:,:,2)
end do
close( 1 )
close( 2 )

! Topo
o1 = 15. - 121.5 * 3600.
o2 = 15. +  30.5 * 3600.
h  = 30.
w(:,:,:,1) = ( ( w(:,:,:,1) * 3600 ) - o1 ) / h
w(:,:,:,2) = ( ( w(:,:,:,2) * 3600 ) - o2 ) / h
do k = 1, size(x,2)
do j = 1, size(x,1)
  jj = int( w(j,k,1,1) ) + 1
  kk = int( w(j,k,1,2) ) + 1
  h1 =  w(j,k,1,1) - jj + 1
  h2 = -w(j,k,1,1) + jj
  h3 =  w(j,k,1,2) - kk + 1
  h4 = -w(j,k,1,2) + kk
  x(j,k,1,3) = ( &
    h2 * h4 * topo(jj,kk)   + &
    h1 * h4 * topo(jj+1,kk) + &
    h2 * h3 * topo(jj,kk+1) + &
    h1 * h3 * topo(jj+1,kk+1) )
end do
end do
z0 = sum( x(:,:,:,3) ) / ( n(1) * n(2) )
print *, 'Min Elevation: ', minval( x(:,:,:,3) )
print *, 'Max Elevation: ', maxval( x(:,:,:,3) )
print *, 'Average Elevation: ', z0

! 2D elevation
open( 3, file='z', recl=reclen, form='unformatted', access='direct' )
write( 3, rec=1 ) x(:,:,:,3)
close( 3 )

! Illumination
j = n(1)
k = n(2)
i1 = (/ 2, 2, 1 /)
i2 = (/ j-1, k-1, 1 /)
call surfnormals( w, x, i1, i2 )
w(1,:,:,:) = w(2,:,:,:)
w(j,:,:,:) = w(j-1,:,:,:)
w(:,1,:,:) = w(:,2,:,:)
w(:,k,:,:) = w(:,k-1,:,:)
s = sqrt( sum( w * w, 4 ) )
where ( s /= 0. ) s = 1. / s
do i = 1, 3
  w(:,:,:,i) = w(:,:,:,i) * s
end do
open( 3, file='shade', recl=reclen, form='unformatted', access='direct' )
write( 3, rec=1 ) w(:,:,:,1)
close( 3 )

! 3D elevation and depth
s = 0.
x(:,:,:,3) = (x(:,:,:,3)-z0) / (n(3)-npml)
open( 3, file='x3', recl=reclen, form='unformatted', access='direct' )
open( 4, file='rdep', recl=reclen, form='unformatted', access='direct' )
do i = 1, npml
  write( 3, rec=i ) z0 - (n(3)-i) * dx + s
  write( 4, rec=i ) (n(3)-i) * dx + (n(3)-npml) * x(:,:,:,3)
end do
do i = npml+1, n(3)
  write( 3, rec=i ) z0 - (n(3)-i) * dx + (i-npml) * x(:,:,:,3)
  write( 4, rec=i ) (n(3)-i) * dx + (n(3)-i) * x(:,:,:,3)
end do
close( 3 )
close( 4 )

end program

