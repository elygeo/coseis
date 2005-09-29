!------------------------------------------------------------------------------!
! MPI routines

module collective_m
use mpi
implicit none
integer :: comm
integer, private :: ip, ipmaster
contains

subroutine initialize( master )
logical, intent(out) :: master
integer :: err
call mpi_init( err )
call mpi_comm_rank( mpi_comm_world, ip, err  )
master = .false.
if ( ip == 0 ) master = .true.
end subroutine

! Finalize
subroutine finalize
integer :: err
call mpi_finalize( err )
end subroutine

! Processor rank
subroutine rank( np, ip3 )
integer, intent(in) :: np(3)
integer, intent(out) :: ip3(3)
integer :: ip, err
logical :: period(3) = .false.
call mpi_cart_create( mpi_comm_world, 3, np, period, .true., comm, err )
if ( comm == mpi_comm_null ) then
  call mpi_comm_rank( mpi_comm_world, ip, err  )
  print *, 'Unused processor: ', ip
  call mpi_finalize( err )
  stop
end if
call mpi_comm_rank( comm, ip, err  )
call mpi_cart_coords( comm, ip, 3, ip3, err )
end subroutine

! Set master processor
subroutine setmaster( ip3master )
integer, intent(in) :: ip3master(3)
integer :: err
call mpi_cart_rank( comm, ip3master, ipmaster, err )
end subroutine

! Broadcast
subroutine broadcast( r )
real, intent(inout) :: r(:)
integer :: i, err
i = size(r)
call mpi_bcast( r, i, mpi_real, ipmaster, comm, err )
end subroutine

! Integer minimum
subroutine globalmin( i )
integer, intent(inout) :: i
integer :: ii, err
call mpi_allreduce( i, ii, 1, mpi_integer, mpi_min, comm, err )
i = ii
end subroutine

! Real global minimum & location, send to master
subroutine globalminloc( rmin, imin, nnoff )
real, intent(inout) :: rmin
integer, intent(inout) :: imin(3)
integer, intent(in) :: nnoff
integer :: err, ipmin
real :: local(2), global(2)
local(1) = rmin
local(2) = ip
call mpi_reduce( local, global, 2, mpi_real, mpi_minloc, ipmaster, comm, err )
rmin  = global(1)
ipmin = global(2)
if ( ip == ipmaster .or. ip == ipmin ) then
  imin = imin - nnoff
  call mpi_sendrecv_replace( imin, 3, mpi_integer, ipmaster, 0, ip, 0, comm, mpi_status_ignore, err )
  imin = imin + nnoff
end if
end subroutine

! Real global maximum & location, send to master
subroutine globalmaxloc( rmax, imax, nnoff )
real, intent(inout) :: rmax
integer, intent(inout) :: imax(3)
integer, intent(in) :: nnoff
integer :: err, ipmax
real :: local(2), global(2)
local(1) = rmax
local(2) = ip
call mpi_reduce( local, global, 2, mpi_real, mpi_maxloc, ipmaster, comm, err )
rmax  = global(1)
ipmax = global(2)
if ( ip == ipmaster .or. ip == ipmax ) then
  imax = imax - nnoff
  call mpi_sendrecv_replace( imax, 3, mpi_integer, ipmaster, 0, ip, 0, comm, mpi_status_ignore, err )
  imax = imax + nnoff
end if
end subroutine

! Swap halo
subroutine swaphalo( w1 )
save
real, intent(in) :: w1(:,:,:,:)
integer :: nhalo, ng(4), nl(4), i0(4), i, adjacent1, adjacent2, slice(12), &
  nr, req(12), mpistatus( mpi_status_size, 4 )
logical :: init = .true.
integer :: mof = mpi_order_fortran, err
ifinit: if ( init ) then
nhalo = 1
ng = (/ size(w1,1), size(w1,2), size(w1,3), size(w1,4) /)
nr = 0
do i = 1, 3
  call mpi_cart_shift( comm, i-1, 1, adjacent1, adjacent2, err )
  nl = ng
  nl(i) = nhalo
  nr = nr + 1
  i0 = 0
  call mpi_type_create_subarray( 4, ng, nl, i0, mof, mpi_real, slice(nr), err )
  call mpi_type_commit( slice(nr), err )
  call mpi_recv_init( w1, 1, slice(nr), adjacent1, 1, comm, req(nr), err )
  nr = nr + 1
  i0(i) = ng(i) - nhalo
  call mpi_type_create_subarray( 4, ng, nl, i0, mof, mpi_real, slice(nr), err )
  call mpi_type_commit( slice(nr), err )
  call mpi_recv_init( w1, 1, slice(nr), adjacent2, 2, comm, req(nr), err )
  nr = nr + 1
  i0(i) = nhalo
  call mpi_type_create_subarray( 4, ng, nl, i0, mof, mpi_real, slice(nr), err )
  call mpi_type_commit( slice(nr), err )
  call mpi_send_init( w1, 1, slice(nr), adjacent1, 2, comm, req(nr), err )
  nr = nr + 1
  i0(i) = ng(i) - 2 * nhalo
  call mpi_type_create_subarray( 4, ng, nl, i0, mof, mpi_real, slice(nr), err )
  call mpi_type_commit( slice(nr), err )
  call mpi_send_init( w1, 1, slice(nr), adjacent2, 1, comm, req(nr), err )
end do
return
end if ifinit
do i = 1, nr, 4
  call mpi_startall( 4, req(i), err )
  call mpi_waitall( 4, req(i), mpistatus, err )
end do
end subroutine

end module

