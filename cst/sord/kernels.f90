! miscellaneous utilities
module kernels
implicit none
contains

subroutine volume_strain(s, v, w, n)
real, intent(in) :: s(n), v(n)
real, intent(out) :: w(n)
integer, intent(in) :: n
integer :: i
do i = 1, n
    w(i) = s(i) * v(i)
end do
end subroutine

subroutine shear_strain1(s, v, w, n)
real, intent(in) :: s(n), v(n)
real, intent(out) :: w(n)
integer, intent(in) :: n
integer :: i
do i = 1, n
    w(i) = s(i) * v(i) * 0.5
end do
end subroutine

subroutine shear_strain2(s, v, w, n)
real, intent(in) :: s(n), v(n)
real, intent(inout) :: w(n)
integer, intent(in) :: n
integer :: i
do i = 1, n
    w(i) = w(i) + s(i) * v(i) * 0.5
end do
end subroutine

end module
