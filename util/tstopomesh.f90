! Project topo lon/lat mesh to TeraShake coordinates
program main
use m_tscoords
implicit none
real :: dx, o1, o2
real, allocatable :: x(:,:,:,:)
integer :: i, n(2)
character :: endian

! Dimentions
n = (/ 960, 780 /)
dx = .5 / 60
o1 = .5 * dx - 121.5
o2 = .5 * dx +  30.5

! Byte order
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
print *, 'endian = ', endian

! 2D mesh
allocate( x(n(1),n(2),1,2) )
forall( i=1:n(1) ) x(i,:,:,1) = o1 + dx * ( i - 1 )
forall( i=1:n(2) ) x(:,i,:,2) = o2 + dx * ( i - 1 )

! Project mesh
call ll2ts( x, 1, 2 )

! Write files
inquire( iolength=i ) x(:,:,:,1)
open( 1, file='topo1.'//endian, recl=i, form='unformatted', access='direct', status='replace' )
open( 2, file='topo2.'//endian, recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) x(:,:,:,1)
write( 2, rec=1 ) x(:,:,:,2)
close( 1 )
close( 2 )

end program
