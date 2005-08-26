!------------------------------------------------------------------------------!
! HGCN - hourglass corrections, cell to node

module hgcn_m
contains
subroutine hgcn( hg, f, i, iq, i1, i2 )

implicit none
real, intent(out) :: hg(:,:,:)
real, intent(in) :: f(:,:,:,:)
integer, intent(in) :: i, iq, i1(3), i2(3)
integer :: j, j1, j2, k, k1, k2, l, l1, l2

j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

select case( iq )
case( 1 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    hg(j,k,l) = &
    - f(j,k,l,i) - f(j-1,k-1,l-1,i) &
    - f(j-1,k,l,i) - f(j,k-1,l-1,i) &
    + f(j,k-1,l,i) + f(j-1,k,l-1,i) &
    + f(j,k,l-1,i) + f(j-1,k-1,l,i)
  end forall
case( 2 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    hg(j,k,l) = &
    - f(j,k,l,i) - f(j-1,k-1,l-1,i) &
    + f(j-1,k,l,i) + f(j,k-1,l-1,i) &
    - f(j,k-1,l,i) - f(j-1,k,l-1,i) &
    + f(j,k,l-1,i) + f(j-1,k-1,l,i)
  end forall
case( 3 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    hg(j,k,l) = &
    - f(j,k,l,i) - f(j-1,k-1,l-1,i) &
    + f(j-1,k,l,i) + f(j,k-1,l-1,i) &
    + f(j,k-1,l,i) + f(j-1,k,l-1,i) &
    - f(j,k,l-1,i) - f(j-1,k-1,l,i)
  end forall
case( 4 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    hg(j,k,l) = &
    - f(j,k,l,i) + f(j-1,k-1,l-1,i) &
    + f(j-1,k,l,i) - f(j,k-1,l-1,i) &
    + f(j,k-1,l,i) - f(j-1,k,l-1,i) &
    + f(j,k,l-1,i) - f(j-1,k-1,l,i)
  end forall
end select

end subroutine
end module

