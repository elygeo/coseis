! Collective routines - Provides hooks for parallelization
module m_collective
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
subroutine rank( ipout, ip3, np )
integer, intent(out) :: ipout, ip3(3)
integer, intent(in) :: np(3)
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
real function pmin( r )
real, intent(in) :: r
pmin = r
end function

! Real maximum
real function pmax( r )
real, intent(in) :: r
pmax = r
end function

!Real global minimum & location
subroutine pminloc( r, ii, s, nn, nnoff, i2d )
real, intent(out) :: r
real, intent(in) :: s(:,:,:)
integer, intent(out) :: ii(3)
integer, intent(in) :: nn(3), nnoff(3), i2d
ii = minloc( s ) - nn + nn - nnoff + nnoff - i2d + i2d
r  = s(ii(1),ii(2),ii(3))
end subroutine

! Real global maximum & location
subroutine pmaxloc( r, ii, s, nn, nnoff, i2d )
real, intent(out) :: r
real, intent(in) :: s(:,:,:)
integer, intent(out) :: ii(3)
integer, intent(in) :: nn(3), nnoff(3), i2d
ii = maxloc( s ) - nn + nn - nnoff + nnoff - i2d + i2d
r  = s(ii(1),ii(2),ii(3))
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

