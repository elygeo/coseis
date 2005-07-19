!------------------------------------------------------------------------------!
! HGNC - hourglass corrections, node to cell

subroutine hgnc( hg, f, i, iq, i1, i2 )

implicit none
real hg(:,:,:,:), f(:,:,:,:)
integer i, j, k, l, iq, i1(3), i2(3)

selectcase(iq)
case(1)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) ) hg(j,k,l,1) = &
  - f(j,k,l,i) - f(j+1,k+1,l+1,i) &
  - f(j+1,k,l,i) - f(j,k+1,l+1,i) &
  + f(j,k+1,l,i) + f(j+1,k,l+1,i) &
  + f(j,k,l+1,i) + f(j+1,k+1,l,i);
case(2)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) ) hg(j,k,l,1) = &
  - f(j,k,l,i) - f(j+1,k+1,l+1,i) &
  + f(j+1,k,l,i) + f(j,k+1,l+1,i) &
  - f(j,k+1,l,i) - f(j+1,k,l+1,i) &
  + f(j,k,l+1,i) + f(j+1,k+1,l,i);
case(3)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) ) hg(j,k,l,1) = &
  - f(j,k,l,i) - f(j+1,k+1,l+1,i) &
  + f(j+1,k,l,i) + f(j,k+1,l+1,i) &
  + f(j,k+1,l,i) + f(j+1,k,l+1,i) &
  - f(j,k,l+1,i) - f(j+1,k+1,l,i);
case(4)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) ) hg(j,k,l,1) = &
  - f(j,k,l,i) + f(j+1,k+1,l+1,i) &
  + f(j+1,k,l,i) - f(j,k+1,l+1,i) &
  + f(j,k+1,l,i) - f(j+1,k,l+1,i) &
  + f(j,k,l+1,i) - f(j+1,k+1,l,i);
end select

return
end

