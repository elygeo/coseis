!------------------------------------------------------------------------------!
! Dummy routines providing hooks for parallelizaion

module collective_m
implicit none
integer :: ip3(3) = 0, ip3master(3) = 0
logical :: master = .true.
contains

subroutine initialize
end subroutine

subroutine finalize
end subroutine

subroutine rank( np )
integer :: np(3)
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

