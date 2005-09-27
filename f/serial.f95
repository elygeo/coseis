!------------------------------------------------------------------------------!
! Dummy routines providing hooks for parallelizaion

module collective_m
implicit none
contains

subroutine initialize( master )
logical, intent(out) :: master
master = .true.
end subroutine

subroutine finalize
end subroutine

subroutine rank( np, ip3 )
integer, intent(in) :: np(3)
integer, intent(out) :: ip3(3)
ip3 = 0
end subroutine

subroutine setmaster( ip3master )
integer, intent(in) :: ip3master(3)
end subroutine

subroutine broadcast( r )
real :: r(:)
end subroutine

subroutine globalmin( i )
integer :: i
end subroutine

subroutine globalminloc( rmin, imin, nnoff )
real :: rmin
integer :: imin(3), nnoff(3)
end subroutine

subroutine globalmaxloc( rmax, imax, nnoff )
real :: rmax
integer :: imax(3), nnoff(3)
end subroutine

subroutine swaphalo( w1, nhalo )
real :: w1(:,:,:,:)
integer :: nhalo
end subroutine

end module

