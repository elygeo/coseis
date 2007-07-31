! Curved mesh
program main
implicit none
real :: 
real, allocatable :: x(:,:,:,:)
integer :: n(3), i
character :: endian

allocate( x(n(1),n(2),1,3) )
forall( i=1:n(1) ) x(i,:,:,1) = dx * ( i - 1 )
forall( i=1:n(2) ) x(:,i,:,2) = dx * ( i - 1 )

! Output
open( 1, file='nn' )
write( 1, * ) product( n )
close( 1 )
inquire( iolength=i ) x(:,:,:,1)
open( 1, file='x1', recl=i, form='unformatted', access='direct', status='replace' )
open( 2, file='x2', recl=i, form='unformatted', access='direct', status='replace' )
do i = 1, n(3)
  write( 1, rec=i ) x(:,:,:,1)
  write( 2, rec=i ) x(:,:,:,2)
end do
close( 1 )
close( 2 )

end program

