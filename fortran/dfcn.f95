!------------------------------------------------------------------------------!
! DFCN - difference operator, cell to node

subroutine dfcn( op, df, f, x, dx, i, a, i1, i2 )

implicit none
character, intent(in) :: op
real, intent(in) :: f(:,:,:,:), x(:,:,:,:), dx
real, intent(out) :: df(:,:,:)
real :: h
integer, intent(in) :: i, a, i1(3), i2(3)
integer :: j, k, l, b, c

select case(op)

case('h') ! constant grid, flops: 1* 7+

h = 0.25 * dx * dx
select case(a)
case(1)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    df(j,k,l) = h * &
    ( f(j,k,l,i) - f(j-1,k-1,l-1,i) &
    - f(j-1,k,l,i) + f(j,k-1,l-1,i) &
    + f(j,k-1,l,i) - f(j-1,k,l-1,i) &
    + f(j,k,l-1,i) - f(j-1,k-1,l,i) )
  end forall
case(2)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    df(j,k,l) = h * &
    ( f(j,k,l,i) - f(j-1,k-1,l-1,i) &
    + f(j-1,k,l,i) - f(j,k-1,l-1,i) &
    - f(j,k-1,l,i) + f(j-1,k,l-1,i) &
    + f(j,k,l-1,i) - f(j-1,k-1,l,i) )
  end forall
case(3)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    df(j,k,l) = h * &
    ( f(j,k,l,i) - f(j-1,k-1,l-1,i) &
    + f(j-1,k,l,i) - f(j,k-1,l-1,i) &
    + f(j,k-1,l,i) - f(j-1,k,l-1,i) &
    - f(j,k,l-1,i) + f(j-1,k-1,l,i) )
  end forall
end select

case('r') ! rectangular grid, flops: 7* 11+

select case(a)
case(1)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    df(j,k,l) = 0.25 * &
    ( ( x(j,k,l+1,3) - x(j,k,l,3) ) * &
    ( ( x(j,k+1,l,2) - x(j,k,l,2) ) * ( f(j,k,l,i) - f(j-1,k,l,i) ) + &
      ( x(j,k,l,2) - x(j,k-1,l,2) ) * ( f(j,k-1,l,i) - f(j-1,k-1,l,i) ) ) &
    + ( x(j,k,l,3) - x(j,k,l-1,3) ) * &
    ( ( x(j,k+1,l,2) - x(j,k,l,2) ) * ( f(j,k,l-1,i) - f(j-1,k,l-1,i) ) + &
      ( x(j,k,l,2) - x(j,k-1,l,2) ) * ( f(j,k-1,l-1,i) - f(j-1,k-1,l-1,i) ) ) )
  end forall
case(2)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    df(j,k,l) = 0.25 * &
    ( ( x(j+1,k,l,1) - x(j,k,l,1) ) * &
    ( ( x(j,k,l+1,3) - x(j,k,l,3) ) * ( f(j,k,l,i) - f(j,k-1,l,i) ) + &
      ( x(j,k,l,3) - x(j,k,l-1,3) ) * ( f(j,k,l-1,i) - f(j,k-1,l-1,i) ) ) &
    + ( x(j,k,l,1) - x(j-1,k,l,1) ) * &
    ( ( x(j,k,l+1,3) - x(j,k,l,3) ) * ( f(j-1,k,l,i) - f(j-1,k-1,l,i) ) + &
      ( x(j,k,l,3) - x(j,k,l-1,3) ) * ( f(j-1,k,l-1,i) - f(j-1,k-1,l-1,i) ) ) )
  end forall
case(3)
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    df(j,k,l) = 0.25 * &
    ( ( x(j,k+1,l,2) - x(j,k,l,2) ) * &
    ( ( x(j+1,k,l,1) - x(j,k,l,1) ) * ( f(j,k,l,i) - f(j,k,l-1,i) ) + &
      ( x(j,k,l,1) - x(j-1,k,l,1) ) * ( f(j-1,k,l,i) - f(j-1,k,l-1,i) ) ) &
    + ( x(j,k,l,2) - x(j,k-1,l,2) ) * &
    ( ( x(j+1,k,l,1) - x(j,k,l,1) ) * ( f(j,k-1,l,i) - f(j,k-1,l-1,i) ) + &
      ( x(j,k,l,1) - x(j-1,k,l,1) ) * ( f(j-1,k-1,l,i) - f(j-1,k-1,l-1,i) ) ) )
  end forall
end select

case('g') ! general grid, flops: 55* 90+

b = mod( a, 3 ) + 1
c = mod( a + 1, 3 ) + 1
forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
df(j,k,l) = 1 / 12 * &
(x(j+1,k,l,c)*((x(j,k+1,l,b)+x(j+1,k+1,l,b))*(f(j,k,l-1,i)-f(j,k,l,i)) &
              +(x(j,k-1,l,b)+x(j+1,k-1,l,b))*(f(j,k-1,l,i)-f(j,k-1,l-1,i)) &
              +(x(j,k,l+1,b)+x(j+1,k,l+1,b))*(f(j,k,l,i)-f(j,k-1,l,i)) &
              +(x(j,k,l-1,b)+x(j+1,k,l-1,b))*(f(j,k-1,l-1,i)-f(j,k,l-1,i))) &
+x(j-1,k,l,c)*((x(j,k+1,l,b)+x(j-1,k+1,l,b))*(f(j-1,k,l,i)-f(j-1,k,l-1,i)) &
              +(x(j,k-1,l,b)+x(j-1,k-1,l,b))*(f(j-1,k-1,l-1,i)-f(j-1,k-1,l,i)) &
              +(x(j,k,l+1,b)+x(j-1,k,l+1,b))*(f(j-1,k-1,l,i)-f(j-1,k,l,i)) &
              +(x(j,k,l-1,b)+x(j-1,k,l-1,b))*(f(j-1,k,l-1,i)-f(j-1,k-1,l-1,i))) &
+x(j,k+1,l,c)*((x(j+1,k,l,b)+x(j+1,k+1,l,b))*(f(j,k,l,i)-f(j,k,l-1,i)) &
              +(x(j-1,k,l,b)+x(j-1,k+1,l,b))*(f(j-1,k,l-1,i)-f(j-1,k,l,i)) &
              +(x(j,k,l+1,b)+x(j,k+1,l+1,b))*(f(j-1,k,l,i)-f(j,k,l,i)) &
              +(x(j,k,l-1,b)+x(j,k+1,l-1,b))*(f(j,k,l-1,i)-f(j-1,k,l-1,i))) &
+x(j,k-1,l,c)*((x(j+1,k,l,b)+x(j+1,k-1,l,b))*(f(j,k-1,l-1,i)-f(j,k-1,l,i)) &
              +(x(j-1,k,l,b)+x(j-1,k-1,l,b))*(f(j-1,k-1,l,i)-f(j-1,k-1,l-1,i)) &
              +(x(j,k,l+1,b)+x(j,k-1,l+1,b))*(f(j,k-1,l,i)-f(j-1,k-1,l,i)) &
              +(x(j,k,l-1,b)+x(j,k-1,l-1,b))*(f(j-1,k-1,l-1,i)-f(j,k-1,l-1,i))) &
+x(j,k,l+1,c)*((x(j+1,k,l,b)+x(j+1,k,l+1,b))*(f(j,k-1,l,i)-f(j,k,l,i)) &
              +(x(j-1,k,l,b)+x(j-1,k,l+1,b))*(f(j-1,k,l,i)-f(j-1,k-1,l,i)) &
              +(x(j,k+1,l,b)+x(j,k+1,l+1,b))*(f(j,k,l,i)-f(j-1,k,l,i)) &
              +(x(j,k-1,l,b)+x(j,k-1,l+1,b))*(f(j-1,k-1,l,i)-f(j,k-1,l,i))) &
+x(j,k,l-1,c)*((x(j+1,k,l,b)+x(j+1,k,l-1,b))*(f(j,k,l-1,i)-f(j,k-1,l-1,i)) &
              +(x(j-1,k,l,b)+x(j-1,k,l-1,b))*(f(j-1,k-1,l-1,i)-f(j-1,k,l-1,i)) &
              +(x(j,k+1,l,b)+x(j,k+1,l-1,b))*(f(j-1,k,l-1,i)-f(j,k,l-1,i)) &
              +(x(j,k-1,l,b)+x(j,k-1,l-1,b))*(f(j,k-1,l-1,i)-f(j-1,k-1,l-1,i))) &
 +x(j,k+1,l+1,c)*(x(j,k+1,l,b)-x(j,k,l+1,b))*(f(j,k,l,i)-f(j-1,k,l,i)) &
 +x(j,k-1,l-1,c)*(x(j,k-1,l,b)-x(j,k,l-1,b))*(f(j,k-1,l-1,i)-f(j-1,k-1,l-1,i)) &
 +x(j+1,k,l+1,c)*(x(j+1,k,l,b)-x(j,k,l+1,b))*(f(j,k-1,l,i)-f(j,k,l,i)) &
 +x(j-1,k,l-1,c)*(x(j-1,k,l,b)-x(j,k,l-1,b))*(f(j-1,k-1,l-1,i)-f(j-1,k,l-1,i)) &
 +x(j+1,k+1,l,c)*(x(j+1,k,l,b)-x(j,k+1,l,b))*(f(j,k,l,i)-f(j,k,l-1,i)) &
 +x(j-1,k-1,l,c)*(x(j-1,k,l,b)-x(j,k-1,l,b))*(f(j-1,k-1,l,i)-f(j-1,k-1,l-1,i)) &
 +x(j+1,k,l-1,c)*(x(j+1,k,l,b)-x(j,k,l-1,b))*(f(j,k,l-1,i)-f(j,k-1,l-1,i)) &
 +x(j-1,k,l+1,c)*(x(j-1,k,l,b)-x(j,k,l+1,b))*(f(j-1,k,l,i)-f(j-1,k-1,l,i)) &
 +x(j-1,k+1,l,c)*(x(j-1,k,l,b)-x(j,k+1,l,b))*(f(j-1,k,l-1,i)-f(j-1,k,l,i)) &
 +x(j+1,k-1,l,c)*(x(j+1,k,l,b)-x(j,k-1,l,b))*(f(j,k-1,l-1,i)-f(j,k-1,l,i)) &
 +x(j,k-1,l+1,c)*(x(j,k-1,l,b)-x(j,k,l+1,b))*(f(j-1,k-1,l,i)-f(j,k-1,l,i)) &
 +x(j,k+1,l-1,c)*(x(j,k+1,l,b)-x(j,k,l-1,b))*(f(j-1,k,l-1,i)-f(j,k,l-1,i)))
end forall

end select

end subroutine

