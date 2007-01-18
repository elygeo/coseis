! Acceleration Calculation
module m_acceleration
implicit none
contains

subroutine acceleration
use m_globals
use m_diffcn
use m_hourglass
use m_collective
use m_bc
integer :: i1(3), i2(3), i, j, k, l, ic, iid, id, iz, iq

s1 = 0.

! Loop over component and derivative direction
doic: do ic  = 1, 3
doid: do iid = 1, 3; id = modulo( ic + iid - 2, 3 ) + 1

! Elastic region
! f_i = w_ij,j
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

! PML region
! p_ij' + d_j*p_ij = w_ij,j (no summation convetion here)
! f_j = sum_i( p_ij' )
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
w2 = hourglass(1) * u + dt * hourglass(2) * v
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

! Newton's law: a_i = f_i / m
do i = 1, 3
  w1(:,:,:,i) = w1(:,:,:,i) * mr
end do

! Boundary conditions
call vectorbc( w1, ibc1, ibc2, nhalo )
call vectorswaphalo( w1, nhalo )

end subroutine

end module

