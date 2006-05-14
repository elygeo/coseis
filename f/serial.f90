! Collective routines - Provides hooks for parallelization
module collective_m
implicit none
contains

! Initialize
subroutine initialize( ipout, np0, master )
logical, intent(out) :: master
integer, intent(out) :: ipout, np0
ipout = 0
np0 = 1
master = .true.
end subroutine

! Finalize
subroutine finalize
end subroutine

! Processor rank
subroutine rank( np, ipout, ip3 )
integer, intent(in) :: np(3)
integer, intent(out) :: ipout, ip3(3)
ipout = 0
ip3 = np - np
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
r = r
end subroutine

! Integer minimum
subroutine pimin( i )
integer, intent(inout) :: i
i = i
end subroutine

! Real sum
subroutine psum( r )
real, intent(inout) :: r
r = r
end subroutine

! Logical or
subroutine plor( l )
logical, intent(inout) :: l
l = l
end subroutine

! Real minimum
subroutine pmin( r )
real, intent(inout) :: r
r = r
end subroutine

! Real maximum
subroutine pmax( r )
real, intent(inout) :: r
r = r
end subroutine

! Real global minimum & location, send to master
subroutine pminloc( r, i, nnoff )
real, intent(inout) :: r
integer, intent(inout) :: i(3)
integer, intent(in) :: nnoff(3)
r = r
i = i - nnoff + nnoff
end subroutine

! Real global maximum & location, send to master
subroutine pmaxloc( r, i, nnoff )
real, intent(inout) :: r
integer, intent(inout) :: i(3)
integer, intent(in) :: nnoff(3)
r = r
i = i - nnoff + nnoff
end subroutine

! Vector send
subroutine vectorsend( f, i1, i2, i )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
integer :: ii
f(1,1,1,1) = f(1,1,1,1)
ii = i1(1) + i2(1) + i
end subroutine

! Vector recieve
subroutine vectorrecv( f, i1, i2, i )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
integer ::  ii
f(1,1,1,1) = f(1,1,1,1)
ii = i1(1) + i2(1) + i
end subroutine

! Scalar swap halo
subroutine scalarswaphalo( f, nhalo )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: nhalo
integer :: i
f(1,1,1) = f(1,1,1)
i = nhalo
end subroutine

! Vector swap halo
subroutine vectorswaphalo( f, nhalo )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: nhalo
integer :: i
f(1,1,1,1) = f(1,1,1,1)
i = nhalo
end subroutine

end module

