! Collective routines - MPI version
module collective_m
use mpi
implicit none
integer :: c
integer, private :: ip, ipmaster
contains

! Initialize
subroutine initialize( ipout, np0, master )
logical, intent(out) :: master
integer, intent(out) :: ipout, np0
integer :: e
call mpi_init( e )
call mpi_comm_rank( mpi_comm_world, ip, e  )
call mpi_comm_size( mpi_comm_world, np0, e  )
ipout = ip
master = .false.
if ( ip == 0 ) master = .true.
end subroutine

! Finalize
subroutine finalize
integer :: e
call mpi_finalize( e )
end subroutine

! Processor rank
subroutine rank( np, ipout, ip3 )
use tictoc_m
integer, intent(in) :: np(3)
integer, intent(out) :: ipout, ip3(3)
integer :: e
logical :: period(3) = .false.
call mpi_cart_create( mpi_comm_world, 3, np, period, .true., c, e )
if ( c == mpi_comm_null ) then
  call toc( 'Unused processor:', ip )
  call mpi_finalize( e )
  stop
end if
call mpi_comm_rank( c, ip, e  )
call mpi_cart_coords( c, ip, 3, ip3, e )
ipout = ip
end subroutine

! Set master processor
subroutine setmaster( ip3master )
integer, intent(in) :: ip3master(3)
integer :: e
call mpi_cart_rank( c, ip3master, ipmaster, e )
end subroutine

! Broadcast
subroutine broadcast( r )
real, intent(inout) :: r(:)
integer :: i, e
i = size(r)
call mpi_bcast( r, i, mpi_real, ipmaster, c, e )
end subroutine

! Integer minimum
subroutine pimin( i )
integer, intent(inout) :: i
integer :: ii, e
call mpi_allreduce( i, ii, 1, mpi_integer, mpi_min, c, e )
i = ii
end subroutine

! Real sum
subroutine psum( r )
real, intent(inout) :: r
real :: rr
integer :: e
call mpi_allreduce( r, rr, 1, mpi_real, mpi_sum, c, e )
r = rr
end subroutine

! Logical or
subroutine plor( l )
logical, intent(inout) :: l
logical :: ll
integer :: e
call mpi_allreduce( l, ll, 1, mpi_logical, mpi_lor, c, e )
l = ll
end subroutine

! Real minimum
subroutine pmin( r )
real, intent(inout) :: r
real :: rr
integer :: e
call mpi_allreduce( r, rr, 1, mpi_real, mpi_min, c, e )
r = rr
end subroutine

! Real maximum
subroutine pmax( r )
real, intent(inout) :: r
real :: rr
integer :: e
call mpi_allreduce( r, rr, 1, mpi_real, mpi_max, c, e )
r = rr
end subroutine

! Real global minimum & location, send to master
subroutine pminloc( r, i, nnoff )
real, intent(inout) :: r
integer, intent(inout) :: i(3)
integer, intent(in) :: nnoff(3)
integer :: e, iip
real :: local(2), global(2)
local(1) = r
local(2) = ip
call mpi_allreduce( local, global, 1, mpi_2real, mpi_minloc, c, e )
r   = global(1)
iip = global(2)
i = i - nnoff
if ( iip /= ipmaster .and. ip == iip ) then
  call mpi_send( i, 3, mpi_integer, ipmaster, 0, c, e )
end if
if ( iip /= ipmaster .and. ip == ipmaster ) then
  call mpi_recv( i, 3, mpi_integer, iip, 0, c, mpi_status_ignore, e )
end if
i = i + nnoff
end subroutine

! Real global maximum & location, send to master
subroutine pmaxloc( r, i, nnoff )
real, intent(inout) :: r
integer, intent(inout) :: i(3)
integer, intent(in) :: nnoff(3)
integer :: e, iip
real :: local(2), global(2)
local(1) = r
local(2) = ip
call mpi_allreduce( local, global, 1, mpi_2real, mpi_maxloc, c, e )
r   = global(1)
iip = global(2)
i = i - nnoff
if ( iip /= ipmaster .and. ip == iip ) then
  call mpi_send( i, 3, mpi_integer, ipmaster, 0, c, e )
end if
if ( iip /= ipmaster .and. ip == ipmaster ) then
  call mpi_recv( i, 3, mpi_integer, iip, 0, c, mpi_status_ignore, e )
end if
i = i + nnoff
end subroutine

! Vector send
subroutine vectorsend( f, i1, i2, i )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
integer :: ng(4), nl(4), i0(4), prev, next, dtype, e
ng = (/ size(f,1), size(f,2), size(f,3), size(f,4) /)
nl = (/ i2 - i1 + 1, ng(4) /)
i0 = (/ i1 - 1, 0 /)
call mpi_cart_shift( c, abs(i)-1, sign(1,i), prev, next, e )
call mpi_type_create_subarray( 4, ng, nl, i0, mpi_order_fortran, mpi_real, dtype, e )
call mpi_type_commit( dtype, e )
call mpi_send( f(1,1,1,1), 1, dtype, next, 0, c, e )
do e = 1,1; end do ! bug work-around, need slight delay here for MPICH2
call mpi_type_free( dtype, e )
end subroutine

! Vector recieve
subroutine vectorrecv( f, i1, i2, i )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
integer :: ng(4), nl(4), i0(4), prev, next, dtype, e
ng = (/ size(f,1), size(f,2), size(f,3), size(f,4) /)
nl = (/ i2 - i1 + 1, ng(4) /)
i0 = (/ i1 - 1, 0 /)
call mpi_cart_shift( c, abs(i)-1, sign(1,i), prev, next, e )
call mpi_type_create_subarray( 4, ng, nl, i0, mpi_order_fortran, mpi_real, dtype, e )
call mpi_type_commit( dtype, e )
call mpi_recv( f(1,1,1,1), 1, dtype, next, 0, c, mpi_status_ignore, e )
call mpi_type_free( dtype, e )
end subroutine

! Scalar swap halo
subroutine scalarswaphalo( f, nhalo )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: nhalo
integer :: i, e, prev, next, ng(3), nl(3), isend(4), irecv(4), tsend, trecv
ng = (/ size(f,1), size(f,2), size(f,3) /)
do i = 1, 3
if ( ng(i) > 1 ) then
  call mpi_cart_shift( c, i-1, 1, prev, next, e )
  nl = ng
  nl(i) = nhalo
  isend = 0
  irecv = 0
  isend(i) = ng(i) - 2 * nhalo
  call mpi_type_create_subarray( 3, ng, nl, isend, mpi_order_fortran, mpi_real, tsend, e )
  call mpi_type_create_subarray( 3, ng, nl, irecv, mpi_order_fortran, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_sendrecv( f(1,1,1), 1, tsend, next, 0, f(1,1,1), 1, trecv, prev, 0, c, mpi_status_ignore, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
  isend(i) = nhalo
  irecv(i) = ng(i) - nhalo
  call mpi_type_create_subarray( 3, ng, nl, isend, mpi_order_fortran, mpi_real, tsend, e )
  call mpi_type_create_subarray( 3, ng, nl, irecv, mpi_order_fortran, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_sendrecv( f(1,1,1), 1, tsend, prev, 1, f(1,1,1), 1, trecv, next, 1, c, mpi_status_ignore, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
end if
end do
end subroutine

! Vector swap halo
subroutine vectorswaphalo( f, nhalo )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: nhalo
integer :: i, e, prev, next, ng(4), nl(4), isend(4), irecv(4), tsend, trecv
ng = (/ size(f,1), size(f,2), size(f,3), size(f,4) /)
do i = 1, 3
if ( ng(i) > 1 ) then
  call mpi_cart_shift( c, i-1, 1, prev, next, e )
  nl = ng
  nl(i) = nhalo
  isend = 0
  irecv = 0
  isend(i) = ng(i) - 2 * nhalo
  call mpi_type_create_subarray( 4, ng, nl, isend, mpi_order_fortran, mpi_real, tsend, e )
  call mpi_type_create_subarray( 4, ng, nl, irecv, mpi_order_fortran, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_sendrecv( f(1,1,1,1), 1, tsend, next, 0, f(1,1,1,1), 1, trecv, prev, 0, c, mpi_status_ignore, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
  isend(i) = nhalo
  irecv(i) = ng(i) - nhalo
  call mpi_type_create_subarray( 4, ng, nl, isend, mpi_order_fortran, mpi_real, tsend, e )
  call mpi_type_create_subarray( 4, ng, nl, irecv, mpi_order_fortran, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_sendrecv( f(1,1,1,1), 1, tsend, prev, 1, f(1,1,1,1), 1, trecv, next, 1, c, mpi_status_ignore, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
end if
end do
end subroutine

end module

