! Generate TeraShake grid from 2D mesh and topography
program grid
use m_tscoords
implicit none
real :: r, dx, h, o1, o2, z0, h1, h2, h3, h4, ell(3), x0, y0, xf(6), yf(6), rf(6), zf, exag
integer :: n(3), nn, npml, nrect, i, j, k, l, j1, k1, l1, j2, k2, l2, jf0, kf0, lf0, &
  nf, nf1, nf2, nf3, reclen
real, allocatable :: x(:,:,:,:), w(:,:,:,:), s(:,:,:), t(:,:)
character :: endian

open( 1, file='dx', status='old' )
read( 1, * ) dx
close( 1 )

! Dimentions
npml = 10
exag = 1.
ell = (/ 600, 300, 80 /) * 1000
n = nint( ell / dx ) + 1
j = n(1)
k = n(2)
l = n(3)
nn = j * k * l
allocate( x(j,k,1,3), w(j,k,1,3), s(j,k,1) )
open( 1, file='nn' )
write( 1, * ) nn
close( 1 )

! 2D mesh
forall( i=1:n(1) ) x(i,:,:,1) = dx*(i-1)
forall( i=1:n(2) ) x(:,i,:,2) = dx*(i-1)

! Fault coordinates
xf = (/ 265864.,293831.,338482.,364062.,390075.,459348. /)
yf = (/ 183273.,187115.,200421.,212782.,215126.,210481. /)
zf = 16000.
!x0 = 365000.
!y0 = 202000.
x0 = .5 * ( minval(xf) + maxval(xf) )
y0 = .5 * ( minval(yf) + maxval(yf) )
nf = size( xf, 1 )

! Fault length
rf(1) = 0
do i = 2, nf
  h1 = xf(i) - xf(i-1)
  h2 = yf(i) - yf(i-1)
  rf(i) = rf(i-1) + sqrt( h1*h1 + h2*h2 )
end do

! Fault indices
nf1 = nint( rf(nf) / dx )
nf2 = 0
nf3 = nint( zf / dx )
jf0 = nint( x0 / dx - .5*nf1 ) + 1
kf0 = nint( y0 / dx ) + 1
lf0 = n(3) - nf3

! Interpolate fault
j1 = 1 + npml
j2 = n(1) - npml
k = kf0
i = 1
do j = j1+1, j2-1
  do while( i < nf-1 .and. dx*(j-jf0) > rf(i+1) )
    i = i + 1
  end do
  x(j,k,1,1) = xf(i) + (xf(i+1)-xf(i)) / (rf(i+1)-rf(i)) * (dx*(j-jf0)-rf(i))
  x(j,k,1,2) = yf(i) + (yf(i+1)-yf(i)) / (rf(i+1)-rf(i)) * (dx*(j-jf0)-rf(i))
end do

! Orogonal elements next to the fault
j1 = jf0
j2 = jf0 + nf1
k  = kf0
h1 = x(j2,k,1,1) - x(j1,k,1,1)
h2 = x(j2,k,1,2) - x(j1,k,1,2)
h = sqrt( h1*h1 + h2*h2 )
do j = j1-1, j2+1
  h1 = 0
  do i = 1, 4
    h1 = x(j+i,k,1,1) - x(j-i,k,1,1)
    h2 = x(j+i,k,1,2) - x(j-i,k,1,2)
  end do
  h = sqrt( h1*h1 + h2*h2 )
  x(j,k-1,1,1) = x(j,k,1,1) + h2 * dx / h
  x(j,k-1,1,2) = x(j,k,1,2) - h1 * dx / h
  x(j,k+1,1,1) = x(j,k,1,1) - h2 * dx / h
  x(j,k+1,1,2) = x(j,k,1,2) + h1 * dx / h
end do

! Blend fault to x-bounaries
j1 = 1 + npml
j2 = jf0 - 1
forall( j=j1+1:j2-1 )
  x(j,:,:,:) = x(j1,:,:,:)*(j2-j)/(j2-j1) + x(j2,:,:,:)*(j-j1)/(j2-j1)
end forall
j1 = jf0 + nf1 + 1
j2 = n(1) - npml
forall( j=j1+1:j2-1 )
  x(j,:,:,:) = x(j1,:,:,:)*(j2-j)/(j2-j1) + x(j2,:,:,:)*(j-j1)/(j2-j1)
end forall

! Blend fault to y-bounaries
k1 = 1 + npml
k2 = kf0 - 1
forall( k=k1+1:k2-1 )
  x(:,k,:,:) = x(:,k1,:,:)*(k2-k)/(k2-k1) + x(:,k2,:,:)*(k-k1)/(k2-k1)
end forall
k1 = kf0 + 1
k2 = n(2) - npml
forall( k=k1+1:k2-1 )
  x(:,k,:,:) = x(:,k1,:,:)*(k2-k)/(k2-k1) + x(:,k2,:,:)*(k-k1)/(k2-k1)
end forall

! Topo
allocate( t(960,780) )
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
inquire( iolength=reclen ) t
open( 1, file='topo.'//endian, recl=reclen, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) t
close( 1 )
t = t * exag

! 3D x/y
inquire( iolength=reclen ) x(:,:,:,1)
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
print *, 'longitude range: ', minval( w(:,:,:,1) ), maxval( w(:,:,:,1) )
print *, 'latgitude range: ', minval( w(:,:,:,2) ), maxval( w(:,:,:,2) )

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
  j1 = int( w(j,k,1,1) ) + 1
  k1 = int( w(j,k,1,2) ) + 1
  h1 =  w(j,k,1,1) - j1 + 1
  h2 = -w(j,k,1,1) + j1
  h3 =  w(j,k,1,2) - k1 + 1
  h4 = -w(j,k,1,2) + k1
  x(j,k,1,3) = ( &
    h2 * h4 * t(j1,k1)   + &
    h1 * h4 * t(j1+1,k1) + &
    h2 * h3 * t(j1,k1+1) + &
    h1 * h3 * t(j1+1,k1+1) )
end do
end do
z0 = sum( x(:,:,:,3) ) / ( n(1) * n(2) )
print *, 'elevation range: ', minval( x(:,:,:,3) ), maxval( x(:,:,:,3) )

! 2D elevation
open( 3, file='z', recl=reclen, form='unformatted', access='direct' )
write( 3, rec=1 ) x(:,:,:,3)
close( 3 )

! 3D elevation and depth. blend topo at fault bottom to flat basement
s = 0
open( 3, file='x3', recl=reclen, form='unformatted', access='direct' )
open( 4, file='rdep', recl=reclen, form='unformatted', access='direct' )
l1 = npml + 1
l2 = n(3) - nf3
do l = 1, l1
  write( 3, rec=l ) -dx*(n(3)-l) + z0 + s
  write( 4, rec=l )  dx*(n(3)-l1) - z0 + x(:,:,:,3)
end do
do l = l1+1, l2-1
  write( 3, rec=l ) -dx*(n(3)-l) + z0*(l2-l)/(l2-l1) + x(:,:,:,3)*(l-l1)/(l2-l1)
  write( 4, rec=l )  dx*(n(3)-l) + (x(:,:,:,3)-z0)*(l2-l)/(l2-l1)
end do
do l = l2, n(3)
  write( 3, rec=l ) -dx*(n(3)-l) + x(:,:,:,3)
  write( 4, rec=l )  dx*(n(3)-l) + s
end do
close( 3 )
close( 4 )

! Fault prestress
deallocate( t, x, s, w )
allocate( s(n(1),1,n(3)), t(1991,161) )
i = nint( dx / 100. )
j1 = jf0
j2 = jf0 + nf1
nf1 = min( nf1, (size(t,1)-1)/i )
j1 = j2 - nf1
nf3 = min( nf3, (size(t,2)-1)/i )
lf0 = n(3) - nf3
l1 = lf0
l2 = lf0 + nf3
inquire( iolength=reclen ) t
open( 1, file='tn.'//endian, recl=reclen, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) t
close( 1 )
s = -1e12
do l = l1, l2
do j = j1, j2
  k1 = i * (j2-j) + 1
  k2 = i * (l2-l) + 1
  s(j,1,l) = t(k1,k2)
end do
end do
inquire( iolength=reclen ) s
open( 1, file='tn', recl=reclen, form='unformatted', access='direct' )
write( 1, rec=1 ) s
close( 1 )
inquire( iolength=reclen ) t
open( 1, file='th.'//endian, recl=reclen, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) t
close( 1 )
s = 0.
do l = l1, l2
do j = j1, j2
  k1 = i * (j2-j) + 1
  k2 = i * (l2-l) + 1
  s(j,1,l) = t(k1,k2)
end do
end do
inquire( iolength=reclen ) s
open( 1, file='th', recl=reclen, form='unformatted', access='direct' )
write( 1, rec=1 ) s
close( 1 )

! Metadata
open( 1, file='gridmeta.m' )
write( 1, * ) 'dx      = ', dx, ';'
write( 1, * ) 'npml    = ', npml, ';'
write( 1, * ) 'n       = [ ', n, ' ];'
write( 1, * ) 'nn      = [ ', n + (/ 0, 1, 0 /), ' ];'
write( 1, * ) 'ihypo   = [ ', jf0,     kf0, lf0,     ' ];'
write( 1, * ) 'ihypo   = [ ', jf0+nf1, kf0, lf0+nf3, ' ];'
write( 1, * ) 'endian  = ''', endian, ''';'
close( 1 )

end program

