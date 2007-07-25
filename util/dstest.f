program asdf
integer :: i, j, n
real :: r
real, allocatable :: v(:,:), w(:,:), s(:)
open( 1, file='n', status='old')
read( 1, * ) n, r
close( 1 )
allocate( v(n,3), w(n,3), s(n) )
call random_number( v )

do i = 1, 3 
do j = 1, n 
  w(j,i) = r * v(j,i)
end do
end do

end program

