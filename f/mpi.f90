! MPI routines
module collective_m
use mpi
implicit none
integer :: c
integer, private :: ip, ipmaster
contains

! Initialize
subroutine initialize( master )
implicit none
logical, intent(inout) :: master
integer :: e
call mpi_init( e )
call mpi_comm_rank( mpi_comm_world, ip, e  )
master = .false.
if ( ip == 0 ) master = .true.
end subroutine

! Finalize
subroutine finalize
implicit none
integer :: e
call mpi_finalize( e )
end subroutine

! Processor rank
subroutine rank( np, ip3 )
implicit none
integer, intent(in) :: np(3)
integer, intent(out) :: ip3(3)
integer :: e
logical :: period(3) = .false.
call mpi_cart_create( mpi_comm_world, 3, np, period, .true., c, e )
if ( c == mpi_comm_null ) then
  call mpi_comm_rank( mpi_comm_world, ip, e  )
  print *, 'Unused processor: ', ip
  call mpi_finalize( e )
  stop
end if
call mpi_comm_rank( c, ip, e  )
call mpi_cart_coords( c, ip, 3, ip3, e )
end subroutine

! Set master processor
subroutine setmaster( ip3master )
implicit none
integer, intent(in) :: ip3master(3)
integer :: e
call mpi_cart_rank( c, ip3master, ipmaster, e )
end subroutine

! Broadcast
subroutine broadcast( r )
implicit none
real, intent(inout) :: r(:)
integer :: i, e
i = size(r)
call mpi_bcast( r, i, mpi_real, ipmaster, c, e )
end subroutine

! Integer minimum
subroutine ipmin( imin )
implicit none
integer, intent(inout) :: imin
integer :: ii, e
call mpi_allreduce( imin, ii, 1, mpi_integer, mpi_min, c, e )
imin = ii
end subroutine

! Real minimum
subroutine pmin( rmin )
implicit none
real, intent(inout) :: rmin
real :: r
integer :: e
call mpi_allreduce( rmin, r, 1, mpi_real, mpi_min, c, e )
rmin = r
end subroutine

! Real maximum
subroutine pmax( rmax )
implicit none
real, intent(inout) :: rmax
real :: r
integer :: e
call mpi_allreduce( rmax, r, 1, mpi_real, mpi_max, c, e )
rmax = r
end subroutine

! Real global minimum & location, send to master
subroutine pminloc( rmin, imin, nnoff )
implicit none
real, intent(inout) :: rmin
integer, intent(inout) :: imin(3)
integer, intent(in) :: nnoff(3)
integer :: e, ipmin
real :: local(2), global(2)
local(1) = rmin
local(2) = ip
call mpi_reduce( local, global, 1, mpi_2real, mpi_minloc, ipmaster, c, e )
rmin  = global(1)
ipmin = global(2)
if ( ip == ipmaster .or. ip == ipmin ) then
  imin = imin - nnoff
  call mpi_sendrecv_replace( imin, 3, mpi_integer, ipmaster, 0, ip, 0, c, mpi_status_ignore, e )
  imin = imin + nnoff
end if
end subroutine

! Real global maximum & location, send to master
subroutine pmaxloc( rmax, imax, nnoff )
implicit none
real, intent(inout) :: rmax
integer, intent(inout) :: imax(3)
integer, intent(in) :: nnoff(3)
integer :: e, ipmax
real :: local(2), global(2)
local(1) = rmax
local(2) = ip
call mpi_reduce( local, global, 1, mpi_2real, mpi_maxloc, ipmaster, c, e )
rmax  = global(1)
ipmax = global(2)
if ( ip == ipmaster .or. ip == ipmax ) then
  imax = imax - nnoff
  call mpi_sendrecv_replace( imax, 3, mpi_integer, ipmaster, 0, ip, 0, c, mpi_status_ignore, e )
  imax = imax + nnoff
end if
end subroutine

! Swap halo scalar
subroutine swaphaloscalar( f, nhalo )
implicit none
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: nhalo
integer :: i, e, left, right, ng(3), nl(3), isend(4), irecv(4), tsend, trecv
ng = (/ size(f,1), size(f,2), size(f,3) /)
do i = 1, 3
  call mpi_cart_shift( c, i-1, 1, left, right, e )
  nl = ng
  nl(i) = nhalo
  isend = 0
  irecv = 0
  isend(i) = ng(i) - 2 * nhalo
  call mpi_type_create_subarray( 3, ng, nl, isend, mpi_order_fortran, mpi_real, tsend, e )
  call mpi_type_create_subarray( 3, ng, nl, irecv, mpi_order_fortran, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_sendrecv( f, 1, tsend, right, 0, f, 1, trecv, left, 0, c, mpi_status_ignore, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
  isend(i) = nhalo
  irecv(i) = ng(i) - nhalo
  call mpi_type_create_subarray( 3, ng, nl, isend, mpi_order_fortran, mpi_real, tsend, e )
  call mpi_type_create_subarray( 3, ng, nl, irecv, mpi_order_fortran, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_sendrecv( f, 1, tsend, left, 1, f, 1, trecv, right, 1, c, mpi_status_ignore, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
end do
end subroutine

! Swap halo vector
subroutine swaphalovector( f, nhalo )
implicit none
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: nhalo
integer :: i, e, left, right, ng(4), nl(4), isend(4), irecv(4), tsend, trecv
ng = (/ size(f,1), size(f,2), size(f,3), size(f,4) /)
do i = 1, 3
  call mpi_cart_shift( c, i-1, 1, left, right, e )
  nl = ng
  nl(i) = nhalo
  isend = 0
  irecv = 0
  isend(i) = ng(i) - 2 * nhalo
  call mpi_type_create_subarray( 4, ng, nl, isend, mpi_order_fortran, mpi_real, tsend, e )
  call mpi_type_create_subarray( 4, ng, nl, irecv, mpi_order_fortran, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_sendrecv( f, 1, tsend, right, 0, f, 1, trecv, left, 0, c, mpi_status_ignore, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
  isend(i) = nhalo
  irecv(i) = ng(i) - nhalo
  call mpi_type_create_subarray( 4, ng, nl, isend, mpi_order_fortran, mpi_real, tsend, e )
  call mpi_type_create_subarray( 4, ng, nl, irecv, mpi_order_fortran, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_sendrecv( f, 1, tsend, left, 1, f, 1, trecv, right, 1, c, mpi_status_ignore, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
end do
end subroutine

end module

