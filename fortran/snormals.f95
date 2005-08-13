!------------------------------------------------------------------------------!
! SNORMALS - surface normals

subroutine snormals( x, i1, i2, nrm )

implicit none
real, intent(in) :: x(:,:,:,:)
real, intent(out) :: nrm(:,:,:,:)
integer, intent(in) :: i1(3), i2(3)
integer :: i, j, k, l, a, b, c, nrmdim

nrm = 0.
do i = 1, 3; if ( i1(i) == i2(i) ) nrmdim = i; end do
do a = 1, 3
  b = mod( a,   3 ) + 1
  c = mod( a+1, 3 ) + 1
  selectcase ( nrmdim )
  case( 1 )
    j = i1(1)
    forall( k=i1(2):i2(2), l=i1(3):i2(3) )
      nrm(1,k,l,a) = 1 / 12 * &
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
    forall( j=i1(1):i2(1), l=i1(3):i2(3) )
      nrm(j,1,l,a) = 1 / 12 * &
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
    forall( j=i1(1):i2(1), k=i1(2):i2(2) )
      nrm(j,k,1,a) = 1 / 12 * &
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
  case default; stop 'Error: snormals'
  end select
end do

end subroutine

