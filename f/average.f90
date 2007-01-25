! Averaging
module m_diffnc
implicit none
contains

subroutine averagenc( fa, f, i1, i2 )
real, intent(out) :: fa(:,:,:)
real, intent(in) :: f(:,:,:), i1(3), i2(3)
integer :: j, k, l
forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
  fa(j,k,l) = 0.125 * &
  ( f(j,k,l) + f(j+1,k+1,l+1) &
  + f(j+1,k,l) + f(j,k+1,l+1) &
  + f(j,k+1,l) + f(j+1,k,l+1) &
  + f(j,k,l+1) + f(j+1,k+1,l) )
end forall
end subroutine

subroutine averagecn( af, f, i1, i2 )
real, intent(out) :: af(:,:,:)
real, intent(in) :: f(:,:,:), i1(3), i2(3)
integer :: j, k, l
forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
  fa(j,k,l) = 0.125 * &
  ( f(j,k,l) + f(j-1,k-1,l-1) &
  + f(j-1,k,l) + f(j,k-1,l-1) &
  + f(j,k-1,l) + f(j-1,k,l-1) &
  + f(j,k,l-1) + f(j-1,k-1,l) )
end forall
end subroutine

end module

