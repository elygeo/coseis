! Dummy routines providing hooks for parallelizaion
module collective_m
implicit none
contains

! Initialize
subroutine initialize( master )
logical, intent(out) :: master
master = .true.
end subroutine

! Finalize
subroutine finalize
end subroutine

! Processor rank
subroutine rank( np, ip3 )
integer, intent(in) :: np(3)
integer, intent(out) :: ip3(3)
ip3 = ip3 - np + np
end subroutine

! Set master processor
subroutine setmaster( ip3master )
integer, intent(in) :: ip3master(3)
integer :: i
i = ip3master(1)
end subroutine

! Broadcast
subroutine broadcast( r )
real, intent(inout) :: r(:)
r(1) = r(1)
end subroutine

! Integer Minimum
subroutine globalmin( i )
integer, intent(inout) :: i
i = i
end subroutine

! Real global minimum & location, send to master
subroutine globalminloc( rmin, imin, nnoff )
real, intent(inout) :: rmin
integer, intent(inout) :: imin(3)
integer, intent(in) :: nnoff(3)
rmin = rmin
imin = imin - nnoff + nnoff
end subroutine

! Real global maximum & location, send to master
subroutine globalmaxloc( rmax, imax, nnoff )
real, intent(inout) :: rmax
integer, intent(inout) :: imax(3)
integer, intent(in) :: nnoff(3)
rmax = rmax
imax = imax - nnoff + nnoff
end subroutine

! Swap halo
subroutine swaphalo( w1, nhalo )
real, intent(inout) :: w1(:,:,:,:)
integer, intent(in) :: nhalo
integer :: i
w1(1,1,1,1) = w1(1,1,1,1)
i = nhalo
end subroutine

end module

