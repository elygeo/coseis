! difference operator, node to cell
module diff_nc_op
implicit none
contains

subroutine diff_nc(df, f, i, a, i1, i2, x, dx)
real, intent(out) :: df(:,:,:)
real, intent(in) :: f(:,:,:,:), x(:,:,:,:), dx(3)
integer, intent(in) :: i, a, i1(3), i2(3)
real :: h
integer :: j, k, l, b, c

if (any(i1 > i2)) return

h = sign(1.0 / 12.0, product(dx))
b = modulo(a, 3) + 1
c = modulo(a + 1, 3) + 1
!$omp parallel do schedule(static) private(j, k, l)
do l = i1(3), i2(3)
do k = i1(2), i2(2)
do j = i1(1), i2(1)
df(j,k,l) = h * f(j,k,l,i) * &
( (x(j,k+1,l+1,b) - x(j+1,k,l,b)) * (x(j,k+1,l,c) - x(j,k,l+1,c)) + x(j+1,k,l,b) * (x(j+1,k,l+1,c) - x(j+1,k+1,l,c)) &
+ (x(j+1,k,l+1,b) - x(j,k+1,l,b)) * (x(j,k,l+1,c) - x(j+1,k,l,c)) + x(j,k+1,l,b) * (x(j+1,k+1,l,c) - x(j,k+1,l+1,c)) &
+ (x(j+1,k+1,l,b) - x(j,k,l+1,b)) * (x(j+1,k,l,c) - x(j,k+1,l,c)) + x(j,k,l+1,b) * (x(j,k+1,l+1,c) - x(j+1,k,l+1,c)) )
end do
do j = i1(1), i2(1)
df(j,k,l) = df(j,k,l) + h * f(j+1,k,l,i) * &
( (x(j+1,k+1,l+1,b) - x(j,k,l,b)) * (x(j+1,k,l+1,c) - x(j+1,k+1,l,c)) + x(j,k,l,b) * (x(j,k+1,l,c) - x(j,k,l+1,c)) &
+ (x(j,k+1,l,b) - x(j+1,k,l+1,b)) * (x(j+1,k+1,l,c) - x(j,k,l,c)) + x(j+1,k,l+1,b) * (x(j,k,l+1,c) - x(j+1,k+1,l+1,c)) &
+ (x(j,k,l+1,b) - x(j+1,k+1,l,b)) * (x(j,k,l,c) - x(j+1,k,l+1,c)) + x(j+1,k+1,l,b) * (x(j+1,k+1,l+1,c) - x(j,k+1,l,c)) )
end do
do j = i1(1), i2(1)
df(j,k,l) = df(j,k,l) + h * f(j,k+1,l,i) * &
( (x(j+1,k+1,l+1,b) - x(j,k,l,b)) * (x(j+1,k+1,l,c) - x(j,k+1,l+1,c)) + x(j,k,l,b) * (x(j,k,l+1,c) - x(j+1,k,l,c)) &
+ (x(j+1,k,l,b) - x(j,k+1,l+1,b)) * (x(j,k,l,c) - x(j+1,k+1,l,c)) + x(j,k+1,l+1,b) * (x(j+1,k+1,l+1,c) - x(j,k,l+1,c)) &
+ (x(j,k,l+1,b) - x(j+1,k+1,l,b)) * (x(j,k+1,l+1,c) - x(j,k,l,c)) + x(j+1,k+1,l,b) * (x(j+1,k,l,c) - x(j+1,k+1,l+1,c)) )
end do
do j = i1(1), i2(1)
df(j,k,l) = df(j,k,l) + h * f(j+1,k+1,l,i) * &
( (x(j,k,l,b) - x(j+1,k+1,l+1,b)) * (x(j,k+1,l,c) - x(j+1,k,l,c)) + x(j+1,k+1,l+1,b) * (x(j+1,k,l+1,c) - x(j,k+1,l+1,c)) &
+ (x(j,k+1,l+1,b) - x(j+1,k,l,b)) * (x(j+1,k+1,l+1,c) - x(j,k+1,l,c)) + x(j+1,k,l,b) * (x(j,k,l,c) - x(j+1,k,l+1,c)) &
+ (x(j+1,k,l+1,b) - x(j,k+1,l,b)) * (x(j+1,k,l,c) - x(j+1,k+1,l+1,c)) + x(j,k+1,l,b) * (x(j,k+1,l+1,c) - x(j,k,l,c)) )
end do
do j = i1(1), i2(1)
df(j,k,l) = df(j,k,l) + h * f(j,k,l+1,i) * &
( (x(j+1,k+1,l+1,b) - x(j,k,l,b)) * (x(j,k+1,l+1,c) - x(j+1,k,l+1,c)) + x(j,k,l,b) * (x(j+1,k,l,c) - x(j,k+1,l,c)) &
+ (x(j+1,k,l,b) - x(j,k+1,l+1,b)) * (x(j+1,k,l+1,c) - x(j,k,l,c)) + x(j,k+1,l+1,b) * (x(j,k+1,l,c) - x(j+1,k+1,l+1,c)) &
+ (x(j,k+1,l,b) - x(j+1,k,l+1,b)) * (x(j,k,l,c) - x(j,k+1,l+1,c)) + x(j+1,k,l+1,b) * (x(j+1,k+1,l+1,c) - x(j+1,k,l,c)) )
end do
do j = i1(1), i2(1)
df(j,k,l) = df(j,k,l) + h * f(j+1,k,l+1,i) * &
( (x(j,k,l,b) - x(j+1,k+1,l+1,b)) * (x(j+1,k,l,c) - x(j,k,l+1,c)) + x(j+1,k+1,l+1,b) * (x(j,k+1,l+1,c) - x(j+1,k+1,l,c)) &
+ (x(j,k+1,l+1,b) - x(j+1,k,l,b)) * (x(j,k,l+1,c) - x(j+1,k+1,l+1,c)) + x(j+1,k,l,b) * (x(j+1,k+1,l,c) - x(j,k,l,c)) &
+ (x(j+1,k+1,l,b) - x(j,k,l+1,b)) * (x(j+1,k+1,l+1,c) - x(j+1,k,l,c)) + x(j,k,l+1,b) * (x(j,k,l,c) - x(j,k+1,l+1,c)) )
end do
do j = i1(1), i2(1)
df(j,k,l) = df(j,k,l) + h * f(j+1,k+1,l+1,i) * &
( (x(j+1,k,l,b) - x(j,k+1,l+1,b)) * (x(j+1,k+1,l,c) - x(j+1,k,l+1,c)) + x(j,k+1,l+1,b) * (x(j,k,l+1,c) - x(j,k+1,l,c)) &
+ (x(j,k+1,l,b) - x(j+1,k,l+1,b)) * (x(j,k+1,l+1,c) - x(j+1,k+1,l,c)) + x(j+1,k,l+1,b) * (x(j+1,k,l,c) - x(j,k,l+1,c)) &
+ (x(j,k,l+1,b) - x(j+1,k+1,l,b)) * (x(j+1,k,l+1,c) - x(j,k+1,l+1,c)) + x(j+1,k+1,l,b) * (x(j,k+1,l,c) - x(j+1,k,l,c)) )
end do
do j = i1(1), i2(1)
df(j,k,l) = df(j,k,l) + h * f(j,k+1,l+1,i) * &
( (x(j,k,l,b) - x(j+1,k+1,l+1,b)) * (x(j,k,l+1,c) - x(j,k+1,l,c)) + x(j+1,k+1,l+1,b) * (x(j+1,k+1,l,c) - x(j+1,k,l+1,c)) &
+ (x(j+1,k,l+1,b) - x(j,k+1,l,b)) * (x(j+1,k+1,l+1,c) - x(j,k,l+1,c)) + x(j,k+1,l,b) * (x(j,k,l,c) - x(j+1,k+1,l,c)) &
+ (x(j+1,k+1,l,b) - x(j,k,l+1,b)) * (x(j,k+1,l,c) - x(j+1,k+1,l+1,c)) + x(j,k,l+1,b) * (x(j+1,k,l+1,c) - x(j,k,l,c)) )
end do
end do
end do
!$omp end parallel do

end subroutine

end module

