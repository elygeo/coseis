! Generate TeraShake mesh
program main
use m_tscoords
implicit none
real :: ell(2), dx, x1, x2, o1, o2, h, h1, h2, h3, h4, z
real, allocatable :: x(:,:,:,:), t(:,:)
integer :: n(2), i, j, k, j1, k1
character :: endian0, endian, b1(4), b2(4)
equivalence (h1,b1), (h2,b2)

! Byte order
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
open( 1, file='endian0', status='old' )
read( 1, * ) endian0
close( 1 )

! Dimensions
z = 500.
dx = 200.
ell = (/ 600, 300 /) * 1000

! Cell centered mesh for SCECVM input
n = nint( ell / dx )
allocate( x(n(1),n(2),1,3), t(960,780) )
forall( i=1:n(1) ) x(i,:,:,1) = dx * ( i - 1 ) + .5 * dx
forall( i=1:n(2) ) x(:,i,:,2) = dx * ( i - 1 ) + .5 * dx
call ts2ll( x, 1, 2 )
x(:,:,:,3) = z

! Output
open( 1, file='nc' )
write( 1, * ) product( n )
close( 1 )
inquire( iolength=i ) x(:,:,:,1)
open( 1, file='rlon', recl=i, form='unformatted', access='direct', status='replace' )
open( 2, file='rlat', recl=i, form='unformatted', access='direct', status='replace' )
open( 3, file='rdep', recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) x(:,:,:,1)
write( 2, rec=1 ) x(:,:,:,2)
write( 3, rec=1 ) x(:,:,:,3)
close( 1 )
close( 2 )
close( 3 )

! Node centered mesh for topography
n = nint( ell / dx ) + 1
deallocate( x )
allocate( x(n(1),n(2),1,3), t(960,780) )
forall( i=1:n(1) ) x(i,:,:,1) = dx * ( i - 1 )
forall( i=1:n(2) ) x(:,i,:,2) = dx * ( i - 1 )
call ts2ll( x, 1, 2 )

! Interpolate topography
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
do k1 = 1, size( x, 2 )
do j1 = 1, size( x, 1 )
  x1 = ( ( x(j1,k1,1,1) * 3600 ) - o1 ) / h
  x2 = ( ( x(j1,k1,1,2) * 3600 ) - o2 ) / h
  j = int( x1 ) + 1
  k = int( x2 ) + 1
  h1 =  x1 - j + 1
  h2 = -x1 + j
  h3 =  x2 - k + 1
  h4 = -x2 + k
  x(j1,k1,1,3) = ( &
    h2 * h4 * t(j,k)   + &
    h1 * h4 * t(j+1,k) + &
    h2 * h3 * t(j,k+1) + &
    h1 * h3 * t(j+1,k+1) )
end do
end do

! Output
forall( i=1:n(1) ) x(i,:,:,1) = dx * ( i - 1 )
forall( i=1:n(2) ) x(:,i,:,2) = dx * ( i - 1 )
inquire( iolength=i ) x(:,:,:,1)
open( 1, file='x1', recl=i, form='unformatted', access='direct', status='replace' )
open( 2, file='x2', recl=i, form='unformatted', access='direct', status='replace' )
open( 3, file='x3', recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) x(:,:,:,1)
write( 2, rec=1 ) x(:,:,:,2)
write( 3, rec=1 ) x(:,:,:,3)
close( 1 )
close( 2 )
close( 3 )

! Mesh metadata
open( 1, file='meta.m', status='replace' )
write( 1, '(a)'         ) '% SORD metadata'
write( 1, '(a,g15.7,a)' ) '  dx          = ', dx, ';'
write( 1, '(a)'         ) '  nt          = 0;'
write( 1, '(a,2i8,a)'   ) '  nn          = [ ', n, ' 1 ];'
write( 1, '(a,2i8,a)'   ) '  out{1}      = { 3 ''x''    0   1 1 1 0 ', n,   ' 1 0 };'
write( 1, '(a,2i8,a)'   ) '  out{2}      = { 1 ''rho''  0   1 1 1 0 ', n-1, ' 1 0 };'
write( 1, '(a,2i8,a)'   ) '  out{3}      = { 1 ''vp''   0   1 1 1 0 ', n-1, ' 1 0 };'
write( 1, '(a,2i8,a)'   ) '  out{4}      = { 1 ''vs''   0   1 1 1 0 ', n-1, ' 1 0 };'
write( 1, '(3a)'        ) '  endian      = ''', endian, ''';'
close( 1 )

end program

