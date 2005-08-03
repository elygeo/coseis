!------------------------------------------------------------------------------!
! SNORMALS - surface normals

module snormals_m

contains

subroutine snormals( x, i1, i2, nrm )

implicit none
real, intent(in) :: x(:,:,:,:)
real, intent(out) :: nrm(:,:,:,:)
integer, intent(in) ::, i1(3), i2(3)
integer ::, i, j, k, l, a, b, c, nrmdim

forall( i = 1:3 ) if ( i1(i) == i2(i) ) nrmdim = i
selectcase ( nrmdim )
case 1
  j = i1(1)
  forall( a=1:3, k=i1(2):i2(2), l=i1(3):i2(3) )
    b = mod( a,   3 ) + 1
    c = mod( a+1, 3 ) + 1
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
case 2
  k = i1(2)
  forall( a=1:3, j=i1(1):i2(1), l=i1(3):i2(3) )
    b = mod( a,   3 ) + 1
    c = mod( a+1, 3 ) + 1
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
case 3
  l = i1(3)
  forall( a=1:3, j=i1(1):i2(1), k=i1(2):i2(2) )
    b = mod( a,   3 ) + 1
    c = mod( a+1, 3 ) + 1
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
default
  error( 'snormals' )
  stop
end select

end subroutine

end module

