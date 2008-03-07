! Generate ShakeOut mesh in CMU coordinates
! Cell center registration, z index starts at depth
program main
use m_cmucoords
implicit none
real, parameter :: dx = 100.
integer, parameter :: n1 = 6000, n2 = 3000, n3 = 800
real :: x(n1,n2,1,3)
integer :: io, i
forall( i=1:n1 ) x(i,:,:,1) = dx * ( -.5 + i )
forall( i=1:n2 ) x(:,i,:,2) = dx * ( -.5 + i )
call cmu2ll( x, 1, 2 )
inquire( iolength=io ) x(:,:,:,1)
open( 1, file='rlon', recl=io, form='unformatted', access='direct', status='replace' )
open( 2, file='rlat', recl=io, form='unformatted', access='direct', status='replace' )
open( 3, file='rdep', recl=io, form='unformatted', access='direct', status='replace' )
do i = 1, n3
  x(:,:,:,3) = dx * ( .5 + n3 - i )
  write( 1, rec=i ) x(:,:,:,1)
  write( 2, rec=i ) x(:,:,:,2)
  write( 3, rec=i ) x(:,:,:,3)
end do
close( 1 )
close( 2 )
close( 3 )
end program

