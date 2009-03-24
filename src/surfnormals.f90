! Find surface normals
module m_surfnormals
implicit none
contains

subroutine surfnormals( nhat, x, i1, i2, ihat )
real, intent(out) :: nhat(:,:,:,:)
real, intent(in) :: x(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), ihat
integer :: j, k, l, a, b, c

nhat = 0.0

do a = 1, 3
  b = modulo( a,   3 ) + 1
  c = modulo( a+1, 3 ) + 1
  select case( ihat )
  case( 1 )
    j = i1(1)
    do l = i1(3), i2(3)
    do k = i1(2), i2(2)
      nhat(1,k,l,a) = 1.0 / 12.0 * &
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
    end do
    end do
  case( 2 )
    k = i1(2)
    do l = i1(3), i2(3)
    do j = i1(1), i2(1)
      nhat(j,1,l,a) = 1.0 / 12.0 * &
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
    end do
    end do
  case( 3 )
    l = i1(3)
    do k = i1(2), i2(2)
    do j = i1(1), i2(1)
      nhat(j,k,1,a) = 1.0 / 12.0 * &
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
    end do
    end do
  case default; stop 'error: surfnormal'
  end select
end do

end subroutine

end module

