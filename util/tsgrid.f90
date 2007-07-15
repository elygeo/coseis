! Generate TeraShake grid from 2D mesh and topography
program main
use m_tscoords
implicit none
real :: dx, h, o1, o2, xx, yy, h1, h2, h3, h4, ell(3), x0, y0, z0, &
  xf(6), yf(6), rf(6), zf, exag, mus, mud, tn, ts, rho, vp, vs, dc
integer :: n(3), npml, i, j, k, l, j1, k1, l1, j2, k2, l2, jf0, kf0, lf0, &
  nf, nf1, nf2, nf3, ii(3)
real, allocatable :: x(:,:,:,:), w1(:,:,:,:), s1(:,:,:), s2(:,:,:), t(:,:)
character :: endian0, endian, b1(4), b2(4)
character(256) :: str
equivalence (h1,b1), (h2,b2)

! Model parameters
write( 0, '(a)' ) 'TeraShake Grid Generation'
mus = 1.06
mud = .5;  tn = -20e6
rho = 3000.
vp = 7250.
vs = 4200.
dc = .5
open( 1, file='dx', status='old' )
read( 1, * ) dx
close( 1 )
open( 1, file='npml', status='old' )
read( 1, * ) npml
close( 1 )
open( 1, file='exag', status='old' )
read( 1, * ) exag
close( 1 )
open( 1, file='endian0', status='old' )
read( 1, * ) endian0
close( 1 )
write( 0, * ) 'dx =', dx
write( 0, * ) 'npml =', npml
ell = (/ 600, 300, 80 /) * 1000
xf = (/ 265864.,293831.,338482.,364062.,390075.,459348. /)
yf = (/ 183273.,187115.,200421.,212782.,215126.,210481. /)
zf = 16000.
x0 = .5 * ( minval(xf) + maxval(xf) )
y0 = .5 * ( minval(yf) + maxval(yf) )
!x0 = 365000.
!y0 = 202000.

! Byte order
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
open( 1, file='endian', status='replace' )
write( 1, '(a)' ) endian
close( 1 )

! Dimensions
n = nint( ell / dx ) + 1
n(2) = n(2) + 1
write( 0, * ) 'nn =', n
open( 1, file='nc' )
write( 1, * ) product( n - 1 )
close( 1 )

! Fault length
nf = size( xf, 1 )
rf(1) = 0
do i = 2, nf
  h1 = xf(i) - xf(i-1)
  h2 = yf(i) - yf(i-1)
  rf(i) = rf(i-1) + sqrt( h1*h1 + h2*h2 )
end do
write( 0, * ) 'Fault corners: ', rf
write( 0, * ) 'Fault length: ', rf(nf)

! Fault indices
nf1 = nint( rf(nf) / dx )
nf2 = 0
nf3 = nint( zf / dx )
jf0 = nint( x0 / dx - .5*nf1 ) + 1
kf0 = nint( y0 / dx ) + 1
lf0 = n(3) - nf3

! Hypocenter
j = nint( 9000. / dx )
l = nint( 5000. / dx )

! Mesh metadata
open( 1, file='meta.m', status='replace' )
write( 1, '(a)' ) '% SORD metadata'
write( 1, * ) ' dx          = ', dx, ';'
write( 1, * ) ' dt          = ', dx * .00006, ';'
write( 1, * ) ' nt          = 0;'
write( 1, * ) ' nn          = [ ', n, ' ];'
write( 1, * ) ' ihypo       = [ ', jf0+j,     kf0, n(3)-l, ' ];'
write( 1, * ) ' ihypo       = [ ', jf0-j+nf1, kf0, n(3)-l, ' ];'
write( 1, * ) ' npml        = ', npml, ';'
write( 1, * ) ' faultnormal = 2;'
write( 1, * ) ' endian      = ''', endian, ''';'
write( 1, * ) ' out{1}      = { 3 ''x''    0   1 1 1 0 ', n, ' 0 };'
write( 1, * ) ' out{2}      = { 1 ''rho''  0   1 1 1 0 ', n-1, ' 0 };'
write( 1, * ) ' out{3}      = { 1 ''vp''   0   1 1 1 0 ', n-1, ' 0 };'
write( 1, * ) ' out{4}      = { 1 ''vs''   0   1 1 1 0 ', n-1, ' 0 };'
write( 1, * ) ' out{5}      = { 1 ''ts1''  0   1 1 1 0 ', n, ' 0 };'
close( 1 )

! SORD input parameters
open( 1, file='insord.m', status='replace' )
write( 1, '(a)' ) '% SORD input'
write( 1, * ) ' dx = ', dx, ';'
write( 1, * ) ' dt = ', dx * .00006, ';'
write( 1, * ) ' nt = ', 180. / dx / .00006, ';'
write( 1, * ) ' nn = [ ', n, ' ];'
write( 1, * ) ' ihypo = [ ', jf0+j,     kf0, -1-l, ' ];'
write( 1, * ) ' ihypo = [ ', jf0-j+nf1, kf0, -1-l, ' ];'
write( 1, * ) ' npml = ', npml, ';'
write( 1, * ) ' dc = ', dc, ';'
write( 1, * ) ' mud = ', mud, ';'
write( 1, * ) ' mus = { ', mus, '''zone''', jf0, 0, -1-nf3, jf0+nf1, 0, -1, ' };'
close( 1 )

! 2D mesh
allocate( x(n(1),n(2),1,3) )
forall( i=1:n(1) ) x(i,:,:,1) = dx*(i-1)
forall( i=1:n(2) ) x(:,i,:,2) = dx*(i-1)

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

! Fault double nodes
x(:,kf0+1:n(2),1,:) = x(:,kf0:n(2)-1,1,:)

! Orthogonal elements next to the fault
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
  x(j,k+2,1,1) = x(j,k,1,1) - h2 * dx / h
  x(j,k+2,1,2) = x(j,k,1,2) + h1 * dx / h
end do

! Blend fault to x-boundaries
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

! Blend fault to y-boundaries
k1 = 1 + npml
k2 = kf0 - 1
forall( k=k1+1:k2-1 )
  x(:,k,:,:) = x(:,k1,:,:)*(k2-k)/(k2-k1) + x(:,k2,:,:)*(k-k1)/(k2-k1)
end forall
k1 = kf0 + 2
k2 = n(2) - npml
forall( k=k1+1:k2-1 )
  x(:,k,:,:) = x(:,k1,:,:)*(k2-k)/(k2-k1) + x(:,k2,:,:)*(k-k1)/(k2-k1)
end forall

! lon/lat
j = n(1)
k = n(2)
allocate( w1(j,k,1,3), s1(j,k,1), t(960,780) )
w1 = x
call ts2ll( w1, 1, 2 )
if ( any( w1 /= w1 ) ) stop 'NaNs in lon/lat'
write( 0, * ) 'longitude range: ', minval( w1(:,:,:,1) ), maxval( w1(:,:,:,1) )
write( 0, * ) 'latgitude range: ', minval( w1(:,:,:,2) ), maxval( w1(:,:,:,2) )

! Sites
doline: do
open( 1, file='tssites.ll', status='old' )
open( 2, file='insord.m', status='old', position='append' )
read( 1, *, iostat=i ) xx, yy, str
if ( i /= 0 ) exit doline
s1 = ( w1(:,:,:,1) - xx ) * ( w1(:,:,:,1) - xx ) &
   + ( w1(:,:,:,2) - yy ) * ( w1(:,:,:,2) - yy )
ii = minloc( s1 )
write( 2, * ) 'out = { ''v'' 1   ', ii(1:2), ' -1 0   ', ii(1:2), ' -1 -1 }; % ', trim(str)
end do doline
close( 1 )
close( 2 )

! Topo
if ( exag < .00001 ) then
x(:,:,:,3) = 0.
else
inquire( iolength=i ) t
open( 1, file='topo3.f32', recl=i, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) t
close( 1 )
if ( endian /= endian0 ) then
do k = 1, size( t, 2 )
do j = 1, size( t, 1 )
  h1 = t(j,k)
  b2(4) = b1(1)
  b2(3) = b1(2)
  b2(2) = b1(3)
  b2(1) = b1(4)
  t(j,k) = h2
end do
end do
end if
h = 30.
o1 = .5 * h - 121.5 * 3600.
o2 = .5 * h +  30.5 * 3600.
do k1 = 1, size(w1,2)
do j1 = 1, size(w1,1)
  xx = ( ( w1(j1,k1,1,1) * 3600 ) - o1 ) / h
  yy = ( ( w1(j1,k1,1,2) * 3600 ) - o2 ) / h
  j = int( xx ) + 1
  k = int( yy ) + 1
  h1 =  xx - j + 1
  h2 = -xx + j
  h3 =  yy - k + 1
  h4 = -yy + k
  x(j1,k1,1,3) = ( &
    h2 * h4 * t(j,k)   + &
    h1 * h4 * t(j+1,k) + &
    h2 * h3 * t(j,k+1) + &
    h1 * h3 * t(j+1,k+1) )
end do
end do
x(:,:,:,3) = x(:,:,:,3) * exag
end if

! 2D grid
inquire( iolength=i ) x(:,:,:,1)
open( 1, file='x', recl=i, form='unformatted', access='direct', status='replace' )
open( 2, file='y', recl=i, form='unformatted', access='direct', status='replace' )
open( 3, file='z', recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) x(:,:,:,1)
write( 2, rec=1 ) x(:,:,:,2)
write( 3, rec=1 ) x(:,:,:,3)
close( 1 )
close( 2 )
close( 3 )

! PML regions are orthogonal
j = n(1)
k = n(2)
do i = npml-1,0,-1
  x(i+1,:,:,3) = x(i+2,:,:,3)
  x(j-i,:,:,3) = x(j-i-1,:,:,3)
  x(:,i+1,:,3) = x(:,i+2,:,3)
  x(:,k-i,:,3) = x(:,k-i-1,:,3)
end do
z0 = sum( x(:,:,:,3) ) / ( n(1) * n(2) )
write( 0, * ) 'elevation range: ', minval( x(:,:,:,3) ), maxval( x(:,:,:,3) ), z0

! Chunk here x -> w1

! 3D grid
inquire( iolength=i ) x(:,:,:,1)
open( 1, file='x1', recl=i, form='unformatted', access='direct', status='replace' )
open( 2, file='x2', recl=i, form='unformatted', access='direct', status='replace' )
open( 3, file='x3', recl=i, form='unformatted', access='direct', status='replace' )
do l = 1, n(3)
  write( 1, rec=l ) x(:,:,:,1)
  write( 2, rec=l ) x(:,:,:,2)
end do
s1 = 0
l1 = npml + 1
l2 = n(3) - nf3
do l = 1, l1
  write( 3, rec=l ) -dx*(n(3)-l) + z0 + s1
end do
do l = l1+1, l2-1
  write( 3, rec=l ) -dx*(n(3)-l) + z0*(l2-l)/(l2-l1) + x(:,:,:,3)*(l-l1)/(l2-l1)
end do
do l = l2, n(3)
  write( 3, rec=l ) -dx*(n(3)-l) + x(:,:,:,3)
end do
close( 1 )
close( 2 )
close( 3 )

! 3D element centers
deallocate( w1, s1, t )
j = n(1) - 1
k = n(2) - 1
allocate( w1(j,k,1,3), s1(j,k,1) )
forall( j=1:n(1)-1, k=1:n(2)-1, i=1:3 )
  w1(j,k,1,i) = .25 * ( x(j,k,1,i) + x(j+1,k,1,i) + x(j,k+1,1,i) + x(j+1,k+1,1,i) )
end forall

! PML regions are extruded
j = n(1) - 1
k = n(2) - 1
do i = npml-2,0,-1
  w1(i+1,:,:,:) = w1(i+2,:,:,:)
  w1(j-i,:,:,:) = w1(j-i-1,:,:,:)
  w1(:,i+1,:,:) = w1(:,i+2,:,:)
  w1(:,k-i,:,:) = w1(:,k-i-1,:,:)
end do

! lon/lat
call ts2ll( w1, 1, 2 )

! 2D lon/lat check
inquire( iolength=i ) w1(:,:,:,1)
open( 1, file='xc1', recl=i, form='unformatted', access='direct', status='replace' )
open( 2, file='xc2', recl=i, form='unformatted', access='direct', status='replace' )
open( 3, file='xc3', recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) w1(:,:,:,1)
write( 2, rec=1 ) w1(:,:,:,2)
write( 3, rec=1 ) w1(:,:,:,3)
close( 1 )
close( 2 )
close( 3 )

! Chunk here w1 -> ?

! 3D lon/lat/depth
inquire( iolength=i ) w1(:,:,:,1)
open( 7, file='rlon', recl=i, form='unformatted', access='direct', status='replace' )
open( 8, file='rlat', recl=i, form='unformatted', access='direct', status='replace' )
open( 9, file='rdep', recl=i, form='unformatted', access='direct', status='replace' )
do l = 1, n(3)-1
  write( 7, rec=l ) w1(:,:,:,1)
  write( 8, rec=l ) w1(:,:,:,2)
end do
s1 = 0
l1 = npml
l2 = n(3) - nf3
do l = 1, l1
  write( 9, rec=l ) dx*(n(3)-.5-l1) - z0 + w1(:,:,:,3)
end do
do l = l1+1, l2-1
  write( 9, rec=l ) dx*(n(3)-.5-l) + (w1(:,:,:,3)-z0)*(l2-.5-l)/(l2-l1-1)
end do
do l = l2, n(3)-1
  write( 9, rec=l ) dx*(n(3)-.5-l) + s1
end do
close( 7 )
close( 8 )
close( 9 )

! Fault prestress
write( 0, * ) 'mus: ', mus
write( 0, * ) 'mud: ', mud
write( 0, * ) 'tn: ', tn
write( 0, * ) 'dc: ', dc
deallocate( x, s1, w1 )
allocate( t(1991,161), s1(n(1),1,n(3)), s2(n(1),1,n(3)) )
i = nint( dx / 100. )
j1 = jf0
j2 = jf0 + nf1
nf1 = min( nf1, (size(t,1)-1)/i )
j1 = j2 - nf1
nf3 = min( nf3, (size(t,2)-1)/i )
lf0 = n(3) - nf3
l1 = lf0
l2 = lf0 + nf3

inquire( iolength=i ) t
open( 1, file='ts-ts1.f32', recl=i, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) t
close( 1 )
if ( endian /= endian0 ) then
do k = 1, size( t, 2 )
do j = 1, size( t, 1 )
  h1 = t(j,k)
  b2(4) = b1(1)
  b2(3) = b1(2)
  b2(2) = b1(3)
  b2(1) = b1(4)
  t(j,k) = h2
end do
end do
end if

! Taper shear stress
t = t + 10e6
do j = 1, 1991
  t(j,:) = t(j,:) * ( 1. + .1 * ( 996. - j ) / 1990. )
end do

! Sample shear stress onto mesh
s1 = 0.
i = nint( dx / 100. )
do l = l1, l2
do j = j1, j2
  k1 = i * (j2-j) + 1
  k2 = i * (l2-l) + 1
  s1(j,1,l) = t(k1,k2)
end do
end do

! Write tractions
inquire( iolength=i ) s1
open( 1, file='ts1', recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) s1
close( 1 )

tn = abs( tn )
ts = sum( t ) / size( t )
write( 0, * ) 'Average'
write( 0, * ) 'ts: ', ts
write( 0, * ) 'dt: ', abs( ts ) - mud * abs( tn )
write( 0, * ) 'S:  ', ( tn * mus - ts ) / ( ts - tn * mud )
write( 0, * ) 'rcrit: ', rho * vs ** 2. * tn * ( mus - mud ) * dc / ( ts - tn * mud ) ** 2

!ts = t(91,51)
ts = sum( t(21:1971,21:141) ) / size( t(21:1971,21:141) )
write( 0, * ) 'Interior average'
write( 0, * ) 'ts: ', ts
write( 0, * ) 'dt: ', abs( ts ) - mud * abs( tn )
write( 0, * ) 'S:  ', ( tn * mus - ts ) / ( ts - tn * mud )
write( 0, * ) 'rcrit: ', rho * vs ** 2. * tn * ( mus - mud ) * dc / ( ts - tn * mud ) ** 2

ts = maxval( t )
write( 0, * ) 'Max'
write( 0, * ) 'ts: ', ts
write( 0, * ) 'dt: ', abs( ts ) - mud * abs( tn )
write( 0, * ) 'S:  ', ( tn * mus - ts ) / ( ts - tn * mud )
write( 0, * ) 'rcrit: ', rho * vs ** 2. * tn * ( mus - mud ) * dc / ( ts - tn * mud ) ** 2

end program

