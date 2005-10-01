!------------------------------------------------------------------------------!
! Difference operators, node to cell

module diffnc_m
contains
subroutine diffnc( df, oper, f, x, dx, i, a, i1, i2 )

implicit none
real, intent(out) :: df(:,:,:)
character, intent(in) :: oper
real, intent(in) :: f(:,:,:,:), x(:,:,:,:), dx
integer, intent(in) :: i, a, i1(3), i2(3)
real :: h
integer :: j, k, l, j1, k1, l1, j2, k2, l2, b, c

j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

select case( oper )

case( 'h' ) ! constant grid, flops: 1* 7+

h = 0.25 * dx * dx
select case( a )
case( 1 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    df(j,k,l) = h * &
    ( f(j+1,k+1,l+1,i) - f(j,k,l,i) &
    - f(j,k+1,l+1,i) + f(j+1,k,l,i) &
    + f(j+1,k,l+1,i) - f(j,k+1,l,i) &
    + f(j+1,k+1,l,i) - f(j,k,l+1,i) )
  end forall
case( 2 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    df(j,k,l) = h * &
    ( f(j+1,k+1,l+1,i) - f(j,k,l,i) &
    + f(j,k+1,l+1,i) - f(j+1,k,l,i) &
    - f(j+1,k,l+1,i) + f(j,k+1,l,i) &
    + f(j+1,k+1,l,i) - f(j,k,l+1,i))
  end forall
case( 3 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    df(j,k,l) = h * &
    ( f(j+1,k+1,l+1,i) - f(j,k,l,i) &
    + f(j,k+1,l+1,i) - f(j+1,k,l,i) &
    + f(j+1,k,l+1,i) - f(j,k+1,l,i) &
    - f(j+1,k+1,l,i) + f(j,k,l+1,i) )
  end forall
end select
 
case( 'r' ) ! rectangular grid, flops: 3* 9+

select case( a )
case( 1 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    df(j,k,l) = 0.25 * &
    ( ( x(j,k+1,l,2) - x(j,k,l,2) ) &
    * ( x(j,k,l+1,3) - x(j,k,l,3) ) &
    * ( f(j+1,k+1,l+1,i) - f(j,k,l,i) &
      - f(j,k+1,l+1,i) + f(j+1,k,l,i) &
      + f(j+1,k,l+1,i) - f(j,k+1,l,i) &
      + f(j+1,k+1,l  ,i) - f(j,k,l+1,i) ) )
  end forall
case( 2 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    df(j,k,l) = 0.25 * &
    ( ( x(j,k,l+1,3) - x(j,k,l,3) ) &
    * ( x(j+1,k,l,1) - x(j,k,l,1) ) &
    * ( f(j+1,k+1,l+1,i) - f(j,k,l,i) &
      + f(j,k+1,l+1,i) - f(j+1,k,l,i) &
      - f(j+1,k,l+1,i) + f(j,k+1,l,i) &
      + f(j+1,k+1,l,i) - f(j,k,l+1,i) ) )
  end forall
case( 3 )
  forall( j=j1:j2, k=k1:k2, l=l1:l2 )
    df(j,k,l) = 0.25 * &
    ( ( x(j+1,k,l,1) - x(j,k,l,1) ) &
    * ( x(j,k+1,l,2) - x(j,k,l,2) ) &
    * ( f(j+1,k+1,l+1,i) - f(j,k,l,i) &
      + f(j,k+1,l+1,i) - f(j+1,k,l,i) &
      + f(j+1,k,l+1,i) - f(j,k+1,l,i) &
      - f(j+1,k+1,l,i) + f(j,k,l+1,i) ) )
  end forall
end select

case( 'g' ) ! general grid, flops: 57* 112+

b = modulo( a, 3 ) + 1
c = modulo( a + 1, 3 ) + 1
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
df(j,k,l) = 1. / 12. * &
(x(j+1,k+1,l+1,c)*((x(j+1,k,l,b)-x(j,k+1,l+1,b))*(f(j+1,k,l+1,i)-f(j+1,k+1,l,i))+x(j,k+1,l+1,b)*(f(j,k+1,l,i)-f(j,k,l+1,i)) &
      +(x(j,k+1,l,b)-x(j+1,k,l+1,b))*(f(j+1,k+1,l,i)-f(j,k+1,l+1,i))+x(j+1,k,l+1,b)*(f(j,k,l+1,i)-f(j+1,k,l,i)) &
      +(x(j,k,l+1,b)-x(j+1,k+1,l,b))*(f(j,k+1,l+1,i)-f(j+1,k,l+1,i))+x(j+1,k+1,l,b)*(f(j+1,k,l,i)-f(j,k+1,l,i))) &
+x(j,k,l,c)*((x(j,k+1,l+1,b)-x(j+1,k,l,b))*(f(j,k,l+1,i)-f(j,k+1,l,i))+x(j+1,k,l,b)*(f(j+1,k+1,l,i)-f(j+1,k,l+1,i)) &
      +(x(j+1,k,l+1,b)-x(j,k+1,l,b))*(f(j+1,k,l,i)-f(j,k,l+1,i))+x(j,k+1,l,b)*(f(j,k+1,l+1,i)-f(j+1,k+1,l,i)) &
      +(x(j+1,k+1,l,b)-x(j,k,l+1,b))*(f(j,k+1,l,i)-f(j+1,k,l,i))+x(j,k,l+1,b)*(f(j+1,k,l+1,i)-f(j,k+1,l+1,i))) &
+x(j,k+1,l+1,c)*((x(j,k,l,b)-x(j+1,k+1,l+1,b))*(f(j,k+1,l,i)-f(j,k,l+1,i))+x(j+1,k+1,l+1,b)*(f(j+1,k,l+1,i)-f(j+1,k+1,l,i)) &
      +(x(j+1,k,l+1,b)-x(j,k+1,l,b))*(f(j,k,l+1,i)-f(j+1,k+1,l+1,i))+x(j,k+1,l,b)*(f(j+1,k+1,l,i)-f(j,k,l,i)) &
      +(x(j+1,k+1,l,b)-x(j,k,l+1,b))*(f(j+1,k+1,l+1,i)-f(j,k+1,l,i))+x(j,k,l+1,b)*(f(j,k,l,i)-f(j+1,k,l+1,i))) &
+x(j+1,k,l,c)*((x(j+1,k+1,l+1,b)-x(j,k,l,b))*(f(j+1,k+1,l,i)-f(j+1,k,l+1,i))+x(j,k,l,b)*(f(j,k,l+1,i)-f(j,k+1,l,i)) &
      +(x(j,k+1,l,b)-x(j+1,k,l+1,b))*(f(j,k,l,i)-f(j+1,k+1,l,i))+x(j+1,k,l+1,b)*(f(j+1,k+1,l+1,i)-f(j,k,l+1,i)) &
      +(x(j,k,l+1,b)-x(j+1,k+1,l,b))*(f(j+1,k,l+1,i)-f(j,k,l,i))+x(j+1,k+1,l,b)*(f(j,k+1,l,i)-f(j+1,k+1,l+1,i))) &
+x(j+1,k,l+1,c)*((x(j,k,l,b)-x(j+1,k+1,l+1,b))*(f(j,k,l+1,i)-f(j+1,k,l,i))+x(j+1,k+1,l+1,b)*(f(j+1,k+1,l,i)-f(j,k+1,l+1,i)) &
      +(x(j,k+1,l+1,b)-x(j+1,k,l,b))*(f(j+1,k+1,l+1,i)-f(j,k,l+1,i))+x(j+1,k,l,b)*(f(j,k,l,i)-f(j+1,k+1,l,i)) &
      +(x(j+1,k+1,l,b)-x(j,k,l+1,b))*(f(j+1,k,l,i)-f(j+1,k+1,l+1,i))+x(j,k,l+1,b)*(f(j,k+1,l+1,i)-f(j,k,l,i))) &
+x(j,k+1,l,c)*((x(j+1,k+1,l+1,b)-x(j,k,l,b))*(f(j,k+1,l+1,i)-f(j+1,k+1,l,i))+x(j,k,l,b)*(f(j+1,k,l,i)-f(j,k,l+1,i)) &
      +(x(j+1,k,l,b)-x(j,k+1,l+1,b))*(f(j+1,k+1,l,i)-f(j,k,l,i))+x(j,k+1,l+1,b)*(f(j,k,l+1,i)-f(j+1,k+1,l+1,i)) &
      +(x(j,k,l+1,b)-x(j+1,k+1,l,b))*(f(j,k,l,i)-f(j,k+1,l+1,i))+x(j+1,k+1,l,b)*(f(j+1,k+1,l+1,i)-f(j+1,k,l,i))) &
+x(j+1,k+1,l,c)*((x(j,k,l,b)-x(j+1,k+1,l+1,b))*(f(j+1,k,l,i)-f(j,k+1,l,i))+x(j+1,k+1,l+1,b)*(f(j,k+1,l+1,i)-f(j+1,k,l+1,i)) &
      +(x(j,k+1,l+1,b)-x(j+1,k,l,b))*(f(j,k+1,l,i)-f(j+1,k+1,l+1,i))+x(j+1,k,l,b)*(f(j+1,k,l+1,i)-f(j,k,l,i)) &
      +(x(j+1,k,l+1,b)-x(j,k+1,l,b))*(f(j+1,k+1,l+1,i)-f(j+1,k,l,i))+x(j,k+1,l,b)*(f(j,k,l,i)-f(j,k+1,l+1,i))) &
+x(j,k,l+1,c)*((x(j+1,k+1,l+1,b)-x(j,k,l,b))*(f(j+1,k,l+1,i)-f(j,k+1,l+1,i))+x(j,k,l,b)*(f(j,k+1,l,i)-f(j+1,k,l,i)) &
      +(x(j+1,k,l,b)-x(j,k+1,l+1,b))*(f(j,k,l,i)-f(j+1,k,l+1,i))+x(j,k+1,l+1,b)*(f(j+1,k+1,l+1,i)-f(j,k+1,l,i)) &
      +(x(j,k+1,l,b)-x(j+1,k,l+1,b))*(f(j,k+1,l+1,i)-f(j,k,l,i))+x(j+1,k,l+1,b)*(f(j+1,k,l,i)-f(j+1,k+1,l+1,i))))
end forall

end select

end subroutine
end module

