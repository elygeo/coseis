! Generate TeraShake grid from 2D mesh and topography
program grid
use tscoords_m
use surfnormals_m
implicit none
real :: dx, h, o1, o2, z0, h1, h2, h3, h4, ell(3), yf0, xf(10), yf(10)
integer :: n(3), nn, npml, nt1, nt2, i, j, k, l, jj, kk, i1(3), i2(3), reclen, k0, j0n, j0s, l0n, l0s, j1, j2
real, allocatable :: x(:,:,:,:), w(:,:,:,:), s(:,:,:), topo(:,:)
character :: endian

open( 1, file='in-grid', status='old' )
read( 1, * ) dx, npml
close( 1 )
ell = (/ 600, 300, 80 /) * 1000
yf0 = 202000

! Dimentions
n = nint( ell / dx ) + 1
j = n(1)
k = n(2)
l = n(3)
nn = j * k * l
allocate( x(j,k,1,3), w(j,k,1,3), s(j,k,1) )
open( 1, file='tmp/nn' )
write( 1, * ) nn
close( 1 )

! 2D mesh
forall( i=1:n(1) ) x(i,:,:,1) = dx*(i-1)
forall( i=1:n(2) ) x(:,i,:,2) = dx*(i-1)

! Interpolate fault trace
xf = (/ -dx,dx*npml,265864.,293831.,338482.,364062.,390075.,459348.,ell(1)-dx*npml,ell(1)+dx /)
yf = (/ yf0,yf0,    183273.,187115.,200421.,212782.,215126.,210481.,yf0,yf0 /)
i = 1
k0 = nint( yf0 / dx ) + 1
do j = 1, n(1)
  do while( x(j,k0,1,1) > xf(i+1) )
    i = i + 1
  end do
  x(j,k0,1,2) = yf(i) + (yf(i+1)-yf(i)) / (xf(i+1)-xf(i)) * (x(j,k0,1,1)-xf(i))
end do

! Blend fault to bounaries
l = k0-npml-1
do k = npml+2, k0-1
  x(:,k,:,2) = x(:,k0,:,2)*(k-npml-1)/l + dx*npml*(k0-k)/l
end do
l = n(2)-npml-k0
do k = k0+1, n(2)-npml-1
  x(:,k,:,2) = x(:,k0,:,2)*(n(2)-npml-k)/l + (ell(2)-dx*npml)*(k-k0)/l
end do

! Topo
nt1 = 960
nt2 = 780
allocate( topo(nt1,nt2) )
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
inquire( iolength=reclen ) topo
open( 1, file='topo.'//endian, recl=reclen, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) topo
close( 1 )

! 3D x/y
open( 1, file='tmp/x1', recl=reclen, form='unformatted', access='direct' )
open( 2, file='tmp/x2', recl=reclen, form='unformatted', access='direct' )
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
do i = npml-1,0,-1
  w(i+1,:,:,:) = w(i+2,:,:,:)
  w(j-i,:,:,:) = w(j-i-1,:,:,:)
  w(:,i+1,:,:) = w(:,i+2,:,:)
  w(:,k-i,:,:) = w(:,k-i-1,:,:)
end do

! 3D lat/lon
open( 1, file='tmp/rlon', recl=reclen, form='unformatted', access='direct' )
open( 2, file='tmp/rlat', recl=reclen, form='unformatted', access='direct' )
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
print *, 'min elevation: ', minval( x(:,:,:,3) )
print *, 'max elevation: ', maxval( x(:,:,:,3) )
print *, 'average elevation: ', z0

! 2D elevation
open( 3, file='tmp/z', recl=reclen, form='unformatted', access='direct' )
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
open( 1, file='tmp/shade', recl=reclen, form='unformatted', access='direct' )
write( 1, rec=1 ) w(:,:,:,1)
close( 1 )

! 3D elevation and depth
s = 0
open( 3, file='tmp/x3', recl=reclen, form='unformatted', access='direct' )
open( 4, file='tmp/rdep', recl=reclen, form='unformatted', access='direct' )
l = n(3)-npml-1
do i = 1, npml+1
  write( 3, rec=i ) s + (z0 - dx*(n(3)-i))
  write( 4, rec=i ) x(:,:,:,3) - (z0-dx*l)
end do
do i = npml+2, n(3)
  write( 3, rec=i )  x(:,:,:,3)*((i-npml-1)/l) + ((z0 - dx*l)*(n(3)-i)/l)
  write( 4, rec=i ) (x(:,:,:,3) - (z0-dx*l)) * ((n(3)-i)/l)
end do
close( 3 )
close( 4 )

! Hypocenter
j1  = int( (xf(3))/dx ) + 2
j2  = int( (xf(8))/dx ) + 1
j0n = nint( (xf(3)+8000.)/dx ) + 1
j0s = nint( (xf(8)-8000.)/dx ) + 1
l = n(3)-npml-1
l0n = n(3) - nint( 8000 * l / (dx*l + x(j0n,k0,1,3) - z0) )
l0s = n(3) - nint( 8000 * l / (dx*l + x(j0s,k0,1,3) - z0) )
open( 1, file='tmp/griddata.m' )
write( 1, * ) 'dx     = ', dx, ';'
write( 1, * ) 'npml   = ', npml, ';'
write( 1, * ) 'n      = [ ', n, ' ];'
write( 1, * ) 'nn     = [ ', n + (/ 0, 1, 0 /), ' ];'
write( 1, * ) 'j1     = ', j1, ';'
write( 1, * ) 'j2     = ', j2, ';'
write( 1, * ) 'ihypo1 = [ ', j0n, k0, l0n, ' ];'
write( 1, * ) 'ihypo2 = [ ', j0s, k0, l0s, ' ];'
write( 1, * ) 'endian = ''', endian, ''';'
close( 1 )

end program

