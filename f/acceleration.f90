! Acceleration calculation
module acceleration_m
use globals_m
use diffcn_m
use hourglassnc_m
use hourglasscn_m
use collective_m
contains
subroutine acceleration

implicit none
integer :: i1(3), i2(3), &
  i, j, k, l, j1, k1, l1, j2, k2, l2, ic, iid, id, iz, iq

if ( master ) then
  open( 9, file='log', position='append' )
  write( 9, * ) 'Acceleration calculation'
  close( 9 )
end if

s1 = 0.

! Loop over component and derivative direction
doic: do ic  = 1, 3
doid: do iid = 1, 3; id = modulo( ic + iid - 2, 3 ) + 1

! Elastic region: F = divS
do iz = 1, noper
  i1 = max( i1oper(iz,:), i1node )
  i2 = min( i2oper(iz,:), i2node )
  if ( ic == id ) then
    call diffcn( s1, oper(iz), w1, x, dx, ic, id, i1, i2 )
  else
    i = 6 - ic - id
    call diffcn( s1, oper(iz), w2, x, dx, i, id, i1, i2 )
  end if
end do

! PML region: P' + DP = [del]S, F = 1.P'
i1 = i1node
i2 = i2node
select case( id )
case( 1 )
  do j = i1(1), min( i2(1), i1pml(1) )
  i = j - nnoff(1)
  forall( k=i1(2):i2(2), l=i1(3):i2(3) )
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p1(i,k,l,ic)
    p1(i,k,l,ic) = p1(i,k,l,ic) + dt * s1(j,k,l)
  end forall
  end do
  do j = max( i1(1), i2pml(1) ), i2(1)
  i = nn(1) - j + nnoff(1) + 1
  forall( k=i1(2):i2(2), l=i1(3):i2(3) )
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p4(i,k,l,ic)
    p4(i,k,l,ic) = p4(i,k,l,ic) + dt * s1(j,k,l)
  end forall
  end do
case( 2 )
  do k = i1(2), min( i2(2), i1pml(2) )
  i = k - nnoff(2)
  forall( j=i1(1):i2(1), l=i1(3):i2(3) )
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p2(j,i,l,ic)
    p2(j,i,l,ic) = p2(j,i,l,ic) + dt * s1(j,k,l)
  end forall
  end do
  do k = max( i1(2), i2pml(2) ), i2(2)
  i = nn(2) - k + nnoff(2) + 1
  forall( j=i1(1):i2(1), l=i1(3):i2(3) )
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p5(j,i,l,ic)
    p5(j,i,l,ic) = p5(j,i,l,ic) + dt * s1(j,k,l)
  end forall
  end do
case( 3 )
  do l = i1(3), min( i2(3), i1pml(3) )
  i = l - nnoff(3)
  forall( j=i1(1):i2(1), k=i1(2):i2(2) )
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p3(j,k,i,ic)
    p3(j,k,i,ic) = p3(j,k,i,ic) + dt * s1(j,k,l)
  end forall
  end do
  do l = max( i1(3), i2pml(3) ), i2(3)
  i = nn(3) - l + nnoff(3) + 1
  forall( j=i1(1):i2(1), k=i1(2):i2(2) )
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p6(j,k,i,ic)
    p6(j,k,i,ic) = p6(j,k,i,ic) + dt * s1(j,k,l)
  end forall
  end do
end select

! Add contribution to force vector
if ( ic == id ) then
  w1(:,:,:,ic) = s1
else
  w1(:,:,:,ic) = w1(:,:,:,ic) + s1
end if

end do doid
end do doic

! Hourglass correction
w2 = u + dt * viscosity(2) * v
s1 = 0.
s2 = 0.
do ic = 1, 3
do iq = 1, 4
  call hourglassnc( s1, w2, ic, iq, i1cell, i2cell )
  s1 = y * s1
  call hourglasscn( s2, s1, iq, i1node, i2node )
  w1(:,:,:,ic) = w1(:,:,:,ic) - s2
end do
end do

! Newton's Law: A = F / m
do i = 1, 3
  w1(:,:,:,i) = w1(:,:,:,i) * mr
end do

! Boundaries
i1 = i1node
i2 = i2node
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
do i = 1, nhalo
  w1(j1-i,:,:,1) = -w1(j1+i,:,:,1)
  w1(j1-i,:,:,2) =  w1(j1+i,:,:,2)
  w1(j1-i,:,:,3) =  w1(j1+i,:,:,3)
  w1(j2+i,:,:,1) = -w1(j2-i,:,:,1)
  w1(j2+i,:,:,2) =  w1(j2-i,:,:,2)
  w1(j2+i,:,:,3) =  w1(j2-i,:,:,3)
  w1(:,k1-i,:,1) =  w1(:,k1+i,:,1)
  w1(:,k1-i,:,2) = -w1(:,k1+i,:,2)
  w1(:,k1-i,:,3) =  w1(:,k1+i,:,3)
  w1(:,k2+i,:,1) =  w1(:,k2-i,:,1)
  w1(:,k2+i,:,2) = -w1(:,k2-i,:,2)
  w1(:,k2+i,:,3) =  w1(:,k2-i,:,3)
  w1(:,:,l1-i,1) =  w1(:,:,l1+i,1)
  w1(:,:,l1-i,2) =  w1(:,:,l1+i,2)
  w1(:,:,l1-i,3) = -w1(:,:,l1+i,3)
  w1(:,:,l2+i,1) =  w1(:,:,l2-i,1)
  w1(:,:,l2+i,2) =  w1(:,:,l2-i,2)
  w1(:,:,l2+i,3) = -w1(:,:,l2-i,3)
end do
call swaphalovector( w1, nhalo )

end subroutine

end module

