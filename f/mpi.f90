!------------------------------------------------------------------------------!
! MPI routines

! MPICH mpi module is broken, so make one
module mpi_m
include 'mpif.h'
end module

module collective_m
use mpi_m
implicit none
integer :: c
integer, private :: ip, ipmaster
contains

! Initialize
subroutine initialize( master )
logical, intent(out) :: master
integer :: e
call mpi_init( e )
call mpi_comm_rank( mpi_comm_world, ip, e  )
master = .false.
if ( ip == 0 ) master = .true.
end subroutine

! Finalize
subroutine finalize
integer :: e
call mpi_finalize( e )
end subroutine

! Processor rank
subroutine rank( np, ip3 )
integer, intent(in) :: np(3)
integer, intent(out) :: ip3(3)
integer :: ip, e
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
subroutine globalmin( i )
integer, intent(inout) :: i
integer :: ii, e
call mpi_allreduce( i, ii, 1, mpi_integer, mpi_min, c, e )
i = ii
end subroutine

! Real global minimum & location, send to master
subroutine globalminloc( rmin, imin, nnoff )
real, intent(inout) :: rmin
integer, intent(inout) :: imin(3)
integer, intent(in) :: nnoff(3)
integer :: ipmin, e, s = mpi_status_ignore
real :: local(2), global(2)
local(1) = rmin
local(2) = ip
call mpi_reduce( local, global, 2, mpi_real, mpi_minloc, ipmaster, c, e )
rmin  = global(1)
ipmin = global(2)
if ( ip == ipmaster .or. ip == ipmin ) then
  imin = imin - nnoff
  call mpi_sendrecv_replace( imin, 3, mpi_integer, ipmaster, 0, ip, 0, c, s, e )
  imin = imin + nnoff
end if
end subroutine

! Real global maximum & location, send to master
subroutine globalmaxloc( rmax, imax, nnoff )
real, intent(inout) :: rmax
integer, intent(inout) :: imax(3)
integer, intent(in) :: nnoff(3)
integer :: ipmax, e, s = mpi_status_ignore
real :: local(2), global(2)
local(1) = rmax
local(2) = ip
call mpi_reduce( local, global, 2, mpi_real, mpi_maxloc, ipmaster, c, e )
rmax  = global(1)
ipmax = global(2)
if ( ip == ipmaster .or. ip == ipmax ) then
  imax = imax - nnoff
  call mpi_sendrecv_replace( imax, 3, mpi_integer, ipmaster, 0, ip, 0, c, s, e )
  imax = imax + nnoff
end if
end subroutine

! Swap halo
subroutine swaphalo( w1, nhalo )
real, intent(inout) :: w1(:,:,:,:)
integer, intent(in) :: nhalo
integer :: i, e, left, right, ng(4), nl(4), isend(4), irecv(4), &
  tsend, trecv, s = mpi_status_ignore, o = mpi_order_fortran
ng = (/ size(w1,1), size(w1,2), size(w1,3), size(w1,4) /)
do i = 1, 3
  call mpi_cart_shift( c, i-1, 1, left, right, e )
  nl = ng
  nl(i) = nhalo
  isend = 0
  irecv = 0
  isend(i) = ng(i) - 2 * nhalo
  call mpi_type_create_subarray( 4, ng, nl, isend, o, mpi_real, tsend, e )
  call mpi_type_create_subarray( 4, ng, nl, irecv, o, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_send_recv( w1, 1, tsend, right, 0, w1, 1, trecv, left, 0, c, s, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
  isend(i) = nhalo
  irecv(i) = ng(i) - nhalo
  call mpi_type_create_subarray( 4, ng, nl, isend, o, mpi_real, tsend, e )
  call mpi_type_create_subarray( 4, ng, nl, irecv, o, mpi_real, trecv, e )
  call mpi_type_commit( tsend, e )
  call mpi_type_commit( trecv, e )
  call mpi_send_recv( w1, 1, tsend, left, 1, w1, 1, trecv, right, 1, c, s, e )
  call mpi_type_free( tsend, e )
  call mpi_type_free( trecv, e )
end do
end subroutine

end module

