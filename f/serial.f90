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
subroutine ipmin( imin )
integer, intent(inout) :: imin
imin = imin
end subroutine

! Real sum
subroutine psum( rsum )
real, intent(inout) :: rsum
rsum = rsum
end subroutine

! Real minimum
subroutine pmin( rmin )
real, intent(inout) :: rmin
rmin = rmin
end subroutine

! Real maximum
subroutine pmax( rmax )
real, intent(inout) :: rmax
rmax = rmax
end subroutine

! Real global minimum & location, send to master
subroutine pminloc( rmin, imin, nnoff )
real, intent(inout) :: rmin
integer, intent(inout) :: imin(3)
integer, intent(in) :: nnoff(3)
rmin = rmin
imin = imin - nnoff + nnoff
end subroutine

! Real global maximum & location, send to master
subroutine pmaxloc( rmax, imax, nnoff )
real, intent(inout) :: rmax
integer, intent(inout) :: imax(3)
integer, intent(in) :: nnoff(3)
rmax = rmax
imax = imax - nnoff + nnoff
end subroutine

! Swap halo scalar
subroutine swaphaloscalar( f, nhalo )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: nhalo
integer :: i
f(1,1,1) = f(1,1,1)
i = nhalo
end subroutine

! Swap halo vector
subroutine swaphalovector( f, nhalo )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: nhalo
integer :: i
f(1,1,1,1) = f(1,1,1,1)
i = nhalo
end subroutine

end module

