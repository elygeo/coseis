!------------------------------------------------------------------------------!
! GRIDGEN
!------------------------------------------------------------------------------!

module gridgen_m

implicit none

contains

subroutine gridgen( grid, dx, hypocenter, x, op )

character*(*) :: grid
character :: op
real, parameter :: pi = 3.14159
real :: x(:,:,:,:), dx, l1, l2, l3, theta, tmp
integer :: i, n(4), hypocenter(3)

write(*,*) 'Grid generation'
n = shape( x )
forall( i=2:n(1)-1 ) x(i,:,:,1) = i - 2
forall( i=2:n(2)-1 ) x(:,i,:,2) = i - 2
forall( i=2:n(3)-1 ) x(:,:,i,3) = i - 2
x(1,:,:,:) = x(2,:,:,:)
x(:,1,:,:) = x(:,2,:,:)
x(:,:,1,:) = x(:,:,2,:)
x(n(1),:,:,:) = x(n(1)-1,:,:,:)
x(:,n(2),:,:) = x(:,n(2)-1,:,:)
x(:,:,n(3),:) = x(:,:,n(3)-1,:)
i = hypocenter(nrmdim) + 1
selectcase( nrmdim )
case( 1 ); x(i:,:,:,1) = x(i:,:,:,1) - 1
case( 2 ); x(:,i:,:,2) = x(:,i:,:,2) - 1
case( 3 ); x(:,:,i:,3) = x(:,:,i:,3) - 1
end select
l1 = x(n(1),1,1,1)
l2 = x(1,n(2),1,2)
l3 = x(1,1,n(3),3)
selectcase( grid )
case 'constant'
  op = 'h'
case 'stretch'
  op = 'r'
  x(:,:,:,3) = 2 * x(:,:,:,3)
case 'slant'
  op = 'g'
  theta = 20. * pi / 180.
  scl = sqrt( cos( theta ) ^ 2. + ( 1. - sin( theta ) ) ^ 2. )
  scl = sqrt( 2. ) / scl
  x(:,:,:,1) = x(:,:,:,1) - x(:,:,:,3) * sin( theta );
  x(:,:,:,3) = x(:,:,:,3) * cos( theta );
  x(:,:,:,1) = x(:,:,:,1) * scl;
  x(:,:,:,3) = x(:,:,:,3) * scl;
case default; stop 'Error: grid'
end select
x = x * dx

end subroutine

end module

