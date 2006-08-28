! Hourglass corrections
module m_hourglass
implicit none
contains

! Node to cell
subroutine hourglassnc( hg, f, i, iq, i1, i2 )
real, intent(out) :: hg(:,:,:)
real, intent(in) :: f(:,:,:,:)
integer, intent(in) :: i, iq, i1(3), i2(3)
integer :: j, k, l, j1, k1, l1, j2, k2, l2

if ( any( i2 < i1 ) ) return

j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

select case( iq )
case( 1 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    hg(j,k,l) = &
    - f(j,k,l,i) - f(j+1,k+1,l+1,i) &
    - f(j+1,k,l,i) - f(j,k+1,l+1,i) &
    + f(j,k+1,l,i) + f(j+1,k,l+1,i) &
    + f(j,k,l+1,i) + f(j+1,k+1,l,i)
  end forall
case( 2 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    hg(j,k,l) = &
    - f(j,k,l,i) - f(j+1,k+1,l+1,i) &
    + f(j+1,k,l,i) + f(j,k+1,l+1,i) &
    - f(j,k+1,l,i) - f(j+1,k,l+1,i) &
    + f(j,k,l+1,i) + f(j+1,k+1,l,i)
  end forall
case( 3 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    hg(j,k,l) = &
    - f(j,k,l,i) - f(j+1,k+1,l+1,i) &
    + f(j+1,k,l,i) + f(j,k+1,l+1,i) &
    + f(j,k+1,l,i) + f(j+1,k,l+1,i) &
    - f(j,k,l+1,i) - f(j+1,k+1,l,i)
  end forall
case( 4 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    hg(j,k,l) = &
    - f(j,k,l,i) + f(j+1,k+1,l+1,i) &
    + f(j+1,k,l,i) - f(j,k+1,l+1,i) &
    + f(j,k+1,l,i) - f(j+1,k,l+1,i) &
    + f(j,k,l+1,i) - f(j+1,k+1,l,i)
  end forall
end select

end subroutine

!------------------------------------------------------------------------------!

! Cell to node
subroutine hourglasscn( hg, f, iq, i1, i2 )
real, intent(out) :: hg(:,:,:)
real, intent(in) :: f(:,:,:)
integer, intent(in) :: iq, i1(3), i2(3)
integer :: j, k, l, j1, k1, l1, j2, k2, l2

if ( any( i2 < i1 ) ) return

j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

select case( iq )
case( 1 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    hg(j,k,l) = &
    - f(j,k,l) - f(j-1,k-1,l-1) &
    - f(j-1,k,l) - f(j,k-1,l-1) &
    + f(j,k-1,l) + f(j-1,k,l-1) &
    + f(j,k,l-1) + f(j-1,k-1,l)
  end forall
case( 2 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    hg(j,k,l) = &
    - f(j,k,l) - f(j-1,k-1,l-1) &
    + f(j-1,k,l) + f(j,k-1,l-1) &
    - f(j,k-1,l) - f(j-1,k,l-1) &
    + f(j,k,l-1) + f(j-1,k-1,l)
  end forall
case( 3 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    hg(j,k,l) = &
    - f(j,k,l) - f(j-1,k-1,l-1) &
    + f(j-1,k,l) + f(j,k-1,l-1) &
    + f(j,k-1,l) + f(j-1,k,l-1) &
    - f(j,k,l-1) - f(j-1,k-1,l)
  end forall
case( 4 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    hg(j,k,l) = &
    - f(j,k,l) + f(j-1,k-1,l-1) &
    + f(j-1,k,l) - f(j,k-1,l-1) &
    + f(j,k-1,l) - f(j-1,k,l-1) &
    + f(j,k,l-1) - f(j-1,k-1,l)
  end forall
end select

end subroutine

end module

