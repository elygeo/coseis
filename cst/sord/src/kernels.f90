! miscellaneous utilities
module kernels
implicit none
contains

subroutine shear_strain1(s, v, w, n)
real, intent(in) :: s(*), v(*)
real, intent(out) :: w(*)
integer, intent(in) :: n
integer :: i
do i = 1, n
    w(i) = s(i) * v(i) * 0.5
end do
end subroutine

subroutine shear_strain2(s, v, w, n)
real, intent(in) :: s(*), v(*)
real, intent(inout) :: w(*)
integer, intent(in) :: n
integer :: i
do i = 1, n
    w(i) = w(i) + s(i) * v(i) * 0.5
end do
end subroutine

subroutine volume_strain(s, v, w, n)
real, intent(in) :: s(*), v(*)
real, intent(out) :: w(*)
integer, intent(in) :: n
integer :: i
do i = 1, n
    w(i) = s(i) * v(i)
end do
end subroutine

end module
