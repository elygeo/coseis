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
use m_util
integer :: i1(3), i2(3), i, j, k, l, ic, iid, id, iq

call scalarsethalo( s1, 0., i1node, i2node )

! Loop over component and derivative direction
doic: do ic  = 1, 3
doid: do iid = 1, 3; id = modulo( ic + iid - 2, 3 ) + 1

! Elastic region
! f_i = w_ij,j
i1 = i1node
i2 = i2node
if ( ic == id ) then
  call diffcn( s1, w1, ic, id, i1, i2, oplevel, bb, x, dx1, dx2, dx3, dx )
else
  i = 6 - ic - id
  call diffcn( s1, w2, i, id, i1, i2, oplevel, bb, x, dx1, dx2, dx3, dx )
end if

! PML region
! p'_ij + d_j*p_ij = w_ij,j (no summation convention)
! f_i = sum_j( p_ij' )
select case( id )
case( 1 )
  do j = i1(1), min( i2(1), i1pml(1) )
  i = j + nnoff(1)
  forall( k=i1(2):i2(2), l=i1(3):i2(3) )
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p1(i,k,l,ic)
    p1(i,k,l,ic) = p1(i,k,l,ic) + dt * s1(j,k,l)
  end forall
  end do
  do j = max( i1(1), i2pml(1) ), i2(1)
  i = nn(1) - j - nnoff(1) + 1
  forall( k=i1(2):i2(2), l=i1(3):i2(3) )
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p4(i,k,l,ic)
    p4(i,k,l,ic) = p4(i,k,l,ic) + dt * s1(j,k,l)
  end forall
  end do
case( 2 )
  do k = i1(2), min( i2(2), i1pml(2) )
  i = k + nnoff(2)
  forall( j=i1(1):i2(1), l=i1(3):i2(3) )
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p2(j,i,l,ic)
    p2(j,i,l,ic) = p2(j,i,l,ic) + dt * s1(j,k,l)
  end forall
  end do
  do k = max( i1(2), i2pml(2) ), i2(2)
  i = nn(2) - k - nnoff(2) + 1
  forall( j=i1(1):i2(1), l=i1(3):i2(3) )
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p5(j,i,l,ic)
    p5(j,i,l,ic) = p5(j,i,l,ic) + dt * s1(j,k,l)
  end forall
  end do
case( 3 )
  do l = i1(3), min( i2(3), i1pml(3) )
  i = l + nnoff(3)
  forall( j=i1(1):i2(1), k=i1(2):i2(2) )
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p3(j,k,i,ic)
    p3(j,k,i,ic) = p3(j,k,i,ic) + dt * s1(j,k,l)
  end forall
  end do
  do l = max( i1(3), i2pml(3) ), i2(3)
  i = nn(3) - l - nnoff(3) + 1
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

! Hourglass control. Only viscous in PML
if ( any( hourglass > 0. ) ) then
call scalarsethalo( s1, 0., i1cell, i2cell )
call scalarsethalo( s2, 0., i1node, i2node )
w2 = hourglass(1) * u + dt * hourglass(2) * v
do iq = 1, 4
do ic = 1, 3
  i1 = max( i1pml    , i1cell )
  i2 = min( i2pml - 1, i2cell )
  call hourglassnc( s1, w2, iq, ic, i1, i2 )
  s1 = y * s1
  i1 = max( i1pml + 1, i1node )
  i2 = min( i2pml - 1, i2node )
  call hourglasscn( s2, s1, iq, i1, i2 )
  if ( hourglass(2) > 0. .and. npml > 0 .and. any( ibc1 == 1 .or. ibc2 == 1 ) ) then
    do i = 1, 3
      i1 = i1cell
      i2 = i2cell
      i2(i) = min( i2(i), i1pml(i) )
      call hourglassnc( s1, v, iq, ic, i1, i2 )
      forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
        s1(j,k,l) = dt * hourglass(2) * y(j,k,l) * s1(j,k,l)
      end forall
      i1 = i1cell
      i2 = i2cell
      i1(i) = max( i1(i), i2pml(i) - 1 )
      call hourglassnc( s1, v, iq, ic, i1, i2 )
      forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
        s1(j,k,l) = dt * hourglass(2) * y(j,k,l) * s1(j,k,l)
      end forall
    end do
    do i = 1, 3
      i1 = i1node
      i2 = i2node
      i2(i) = min( i2(i), i1pml(i) )
      call hourglasscn( s2, s1, iq, i1, i2 )
      i1 = i1node
      i2 = i2node
      i1(i) = max( i1(i), i2pml(i) )
      call hourglasscn( s2, s1, iq, i1, i2 )
    end do
  end if
  w1(:,:,:,ic) = w1(:,:,:,ic) - s2
end do
end do
end if

! Newton's law: a_i = f_i / m
do i = 1, 3
  w1(:,:,:,i) = w1(:,:,:,i) * mr
end do

! Boundary conditions
call vectorbc( w1, ibc1, ibc2, nhalo )

end subroutine

end module

