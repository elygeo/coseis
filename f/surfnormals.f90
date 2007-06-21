! Find surface normals
module m_surfnormals
implicit none
contains

subroutine surfnormals( nhat, x, i1, i2, ihat )
real, intent(out) :: nhat(:,:,:,:)
real, intent(in) :: x(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), ihat
integer :: j, k, l, j1, k1, l1, j2, k2, l2, a, b, c

j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
nhat = 0.

do a = 1, 3
  b = modulo( a,   3 ) + 1
  c = modulo( a+1, 3 ) + 1
  select case( ihat )
  case( 1 )
    j = i1(1)
    forall( k=k1:k2, l=l1:l2 )
      nhat(1,k,l,a) = 1. / 12. * &
      ( x(j,k+1,l,b) * ( x(j,k,l+1,c) + x(j,k+1,l+1,c)   &
                       - x(j,k,l-1,c) - x(j,k+1,l-1,c) ) &
      + x(j,k-1,l,b) * ( x(j,k,l-1,c) + x(j,k-1,l-1,c)   &
                       - x(j,k,l+1,c) - x(j,k-1,l+1,c) ) &
      + x(j,k,l+1,b) * ( x(j,k-1,l,c) + x(j,k-1,l+1,c)   &
                       - x(j,k+1,l,c) - x(j,k+1,l+1,c) ) &
      + x(j,k,l-1,b) * ( x(j,k+1,l,c) + x(j,k+1,l-1,c)   &
                       - x(j,k-1,l,c) - x(j,k-1,l-1,c) ) &
      + x(j,k+1,l+1,b) * ( x(j,k,l+1,c) - x(j,k+1,l,c) ) &
      + x(j,k-1,l-1,b) * ( x(j,k,l-1,c) - x(j,k-1,l,c) ) &
      + x(j,k-1,l+1,b) * ( x(j,k-1,l,c) - x(j,k,l+1,c) ) &
      + x(j,k+1,l-1,b) * ( x(j,k+1,l,c) - x(j,k,l-1,c) ) )
    end forall
  case( 2 )
    k = i1(2)
    forall( j=j1:j2, l=l1:l2 )
      nhat(j,1,l,a) = 1. / 12. * &
      ( x(j,k,l+1,b) * ( x(j+1,k,l,c) + x(j+1,k,l+1,c)   &
                       - x(j-1,k,l,c) - x(j-1,k,l+1,c) ) &
      + x(j,k,l-1,b) * ( x(j-1,k,l,c) + x(j-1,k,l-1,c)   &
                       - x(j+1,k,l,c) - x(j+1,k,l-1,c) ) &
      + x(j+1,k,l,b) * ( x(j,k,l-1,c) + x(j+1,k,l-1,c)   &
                       - x(j,k,l+1,c) - x(j+1,k,l+1,c) ) &
      + x(j-1,k,l,b) * ( x(j,k,l+1,c) + x(j-1,k,l+1,c)   &
                       - x(j,k,l-1,c) - x(j-1,k,l-1,c) ) &
      + x(j+1,k,l+1,b) * ( x(j+1,k,l,c) - x(j,k,l+1,c) ) &
      + x(j-1,k,l-1,b) * ( x(j-1,k,l,c) - x(j,k,l-1,c) ) &
      + x(j+1,k,l-1,b) * ( x(j,k,l-1,c) - x(j+1,k,l,c) ) &
      + x(j-1,k,l+1,b) * ( x(j,k,l+1,c) - x(j-1,k,l,c) ) )
    end forall
  case( 3 )
    l = i1(3)
    forall( j=j1:j2, k=k1:k2 )
      nhat(j,k,1,a) = 1. / 12. * &
      ( x(j+1,k,l,b) * ( x(j,k+1,l,c) + x(j+1,k+1,l,c)   &
                       - x(j,k-1,l,c) - x(j+1,k-1,l,c) ) &
      + x(j-1,k,l,b) * ( x(j,k-1,l,c) + x(j-1,k-1,l,c)   &
                       - x(j,k+1,l,c) - x(j-1,k+1,l,c) ) &
      + x(j,k+1,l,b) * ( x(j-1,k,l,c) + x(j-1,k+1,l,c)   &
                       - x(j+1,k,l,c) - x(j+1,k+1,l,c) ) &
      + x(j,k-1,l,b) * ( x(j+1,k,l,c) + x(j+1,k-1,l,c)   &
                       - x(j-1,k,l,c) - x(j-1,k-1,l,c) ) &
      + x(j+1,k+1,l,b) * ( x(j,k+1,l,c) - x(j+1,k,l,c) ) &
      + x(j-1,k-1,l,b) * ( x(j,k-1,l,c) - x(j-1,k,l,c) ) &
      + x(j-1,k+1,l,b) * ( x(j-1,k,l,c) - x(j,k+1,l,c) ) &
      + x(j+1,k-1,l,b) * ( x(j+1,k,l,c) - x(j,k-1,l,c) ) )
    end forall
  case default; stop 'error: surfnormal'
  end select
end do

end subroutine

end module

