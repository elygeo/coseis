!------------------------------------------------------------------------------!
! HGCN - hourglass corrections, cell to node

subroutine hgcn( f, i, iq, i1, i2, hg )

implicit none
real, intent(in) :: f(:,:,:,:)
real, intent(out) :: hg(:,:,:,:)
integer, intent(in) :: i, iq, i1(3), i2(3)
integer :: j, k, l

selectcase(iq)
case(1)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    hg(j,k,l,1) = &
    - f(j,k,l,i) - f(j-1,k-1,l-1,i) &
    - f(j-1,k,l,i) - f(j,k-1,l-1,i) &
    + f(j,k-1,l,i) + f(j-1,k,l-1,i) &
    + f(j,k,l-1,i) + f(j-1,k-1,l,i);
  end forall
case(2)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    hg(j,k,l,1) = &
    - f(j,k,l,i) - f(j-1,k-1,l-1,i) &
    + f(j-1,k,l,i) + f(j,k-1,l-1,i) &
    - f(j,k-1,l,i) - f(j-1,k,l-1,i) &
    + f(j,k,l-1,i) + f(j-1,k-1,l,i);
  end forall
case(3)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    hg(j,k,l,1) = &
    - f(j,k,l,i) - f(j-1,k-1,l-1,i) &
    + f(j-1,k,l,i) + f(j,k-1,l-1,i) &
    + f(j,k-1,l,i) + f(j-1,k,l-1,i) &
    - f(j,k,l-1,i) - f(j-1,k-1,l,i);
  end forall
case(4)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    hg(j,k,l,1) = &
    - f(j,k,l,i) + f(j-1,k-1,l-1,i) &
    + f(j-1,k,l,i) - f(j,k-1,l-1,i) &
    + f(j,k-1,l,i) - f(j-1,k,l-1,i) &
    + f(j,k,l-1,i) - f(j-1,k-1,l,i);
  end forall
end select

end subroutine

