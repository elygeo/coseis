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

! Integer broadcast
subroutine ibroadcast( i )
real, intent(inout) :: i
i = i
end subroutine

! Real broadcast
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
subroutine psum( r, i )
real, intent(inout) :: r
integer, intent(in) :: i
integer :: ii
r = r
ii = i
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
subroutine pminloc( r, i, nnoff, i2d )
real, intent(inout) :: r
integer, intent(inout) :: i(3)
integer, intent(in) :: nnoff(3), i2d
r = r
i = i - nnoff + nnoff - i2d + i2d
end subroutine

! Real global maximum & location, send to master
subroutine pmaxloc( r, i, nnoff, i2d )
real, intent(inout) :: r
integer, intent(inout) :: i(3)
integer, intent(in) :: nnoff(3), i2d
r = r
i = i - nnoff + nnoff - i2d + i2d
end subroutine

! Vector send
subroutine vectorsend( f, i1, i2, i )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
f(1,1,1,1) = f(1,1,1,1) - i1(1) + i1(1) - i2(1) + i2(1) - i + i
end subroutine

! Vector recieve
subroutine vectorrecv( f, i1, i2, i )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
f(1,1,1,1) = f(1,1,1,1) - i1(1) + i1(1) - i2(1) + i2(1) - i + i
end subroutine

! Scalar swap halo
subroutine scalarswaphalo( f, nhalo )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: nhalo
f(1,1,1) = f(1,1,1) - nhalo + nhalo
end subroutine

! Vector swap halo
subroutine vectorswaphalo( f, nhalo )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: nhalo
f(1,1,1,1) = f(1,1,1,1) - nhalo + nhalo
end subroutine

end module

