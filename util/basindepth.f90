! Find basin depth from Vs
program main
implicit none
integer :: nn(3), i, j, k, l
real :: vb, h, z1_, z2_, z3_
real, allocatable :: v1(:,:), v2(:,:), bd1(:,:), bd2(:,:), z0(:,:), z1(:,:), z2(:,:), z3(:,:)

write( 0, '(a)' ) 'Basin Depth'

open( 1, file='basindepth.in', status='old' )
read( 1, * ) vb
read( 1, * ) nn
close( 1 )

j = nn(1)-1
k = nn(2)-1
l = nn(3)-1
allocate( v1(j,k), v2(j,k), bd1(j,k), bd2(j,k) )
inquire( iolength=i ) v1
open( 1, file='vs', recl=i, form='unformatted', access='direct', status='old' )
read( 1, rec=l ) v2

j = nn(1)
k = nn(2)
l = nn(3)
allocate( z0(j,k), z1(j,k), z2(j,k), z3(j,k) )
inquire( iolength=i ) z0
open( 2, file='x3', recl=i, form='unformatted', access='direct', status='old' )
read( 2, rec=l   ) z0
read( 2, rec=l-1 ) z3
z2 = 0.
z3 = z0 - z3

bd1 = 1e9
do j = 1, nn(1)-1
do k = 1, nn(2)-1
  if ( v2(j,k) >= vb ) bd1(j,k) = 0.
end do
end do
bd2 = 0.

do l = nn(3)-2, 1, -1
  v1 = v2
  read( 1, rec=l ) v2
  z1 = z2
  z2 = z3
  read( 2, rec=l ) z3
  z3 = z0 - z3
  do j = 1, nn(1)-1
  do k = 1, nn(2)-1
    if ( v1(j,k) < vb .and. v2(j,k) >= vb ) then
      z1_ = z1(j,k) + z1(j+1,k) + z1(j,k+1) + z1(j+1,k+1)
      z2_ = z2(j,k) + z2(j+1,k) + z2(j,k+1) + z2(j+1,k+1)
      z3_ = z3(j,k) + z3(j+1,k) + z3(j,k+1) + z3(j+1,k+1)
      h = min( 1., ( vb - v1(j,k) ) / ( v2(j,k) - v1(j,k) ) )
      bd2(j,k) = .125 * ( z1_ + z2_ + h * ( z3_ - z1_ ) )
      if ( bd1(j,k) > 1e8 ) bd1(j,k) = bd2(j,k)
    end if
  end do
  end do
end do

close(1)
close(2)

do j = 1, nn(1)-1
do k = 1, nn(2)-1
  if ( v2(j,k) < vb ) bd2(j,k) = 1e9
end do
end do

inquire( iolength=i ) bd1
open( 1, file='bd1', recl=i, form='unformatted', access='direct', status='replace' )
open( 2, file='bd2', recl=i, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) bd1
write( 2, rec=1 ) bd2
close( 1 )
close( 2 )

end program

