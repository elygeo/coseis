!------------------------------------------------------------------------------!
! MPI

module parallel_m
use mpi

implicit none
save
integer :: ip, ip3(3), ipmaster, ip3master(3), comm, err
logical :: master, period(3) = .false.

contains

subroutine init
call mpi_init( err )
call mpi_comm_rank( mpi_comm_world, ip, err  )
master = .false.
if ( ip == 0 ) master = .true.
end subroutine

! Finalize
subroutine finalize
call mpi_finalize( err )
end subroutine

! Processor rank
subroutine rank( np, ip3master )
integer, intent(in) :: np(3), ip3master(3)
call mpi_cart_create( mpi_comm_world, 3, np, period, .true., comm, err )
if ( comm == mpi_comm_null ) then
  print *, 'Unused processor: ', ip
  call mpi_finalize( err )
  stop
end if
call mpi_comm_rank( comm, ip, err  )
call mpi_cart_coords( comm, ip, 3, ip3, err )
call mpi_cart_rank( comm, ip3master, ipmaster, err )
master = .false.
if ( ip == ipmaster ) master = .true.
end subroutine

! Broadcast
subroutine broadcast( r )
real, intent(inout) :: r(:)
integer :: i
i = size(r)
call mpi_bcast( r, i, mpi_real, ipmaster, comm, err )
end subroutine

! Integer minimum
subroutine globalmin( i )
integer, intent(inout) :: i
integer :: ii
call mpi_allreduce( i, ii, 1, mpi_integer, mpi_min, comm, err )
i = ii
end subroutine

! Real global minimum & location, send to master
subroutine globalminloc( rmin, imin, noff )
real, intent(inout) :: rmin
integer, intent(inout) :: imin(3)
integer, intent(in) :: noff
real :: local(2), global(2)
local(1) = rmin
local(2) = ip
call mpi_reduce( local, global, 2, mpi_real, mpi_minloc, ipmaster, comm, err )
rmin  = global(1)
ipmin = global(2)
if ( ip = ipmaster .or. ip = ipmin ) then
  ihypo = ihypo - noff
  call mpi_rendrecv_replace( imin, 3, mpi_integer, ipmaster, 0, ip, 0, comm, mpi_status_ignore, err )
  ihypo = ihypo + noff
end if
end subroutine

! Real global maximum & location, send to master
subroutine globalmaxloc( rmax, imax, noff )
real, intent(inout) :: rmax
integer, intent(inout) :: imax(3)
integer, intent(in) :: noff
real :: local(2), global(2)
local(1) = rmax
local(2) = ip
call mpi_reduce( local, global, 2, mpi_real, mpi_maxloc, ipmaster, comm, err )
rmax  = global(1)
ipmax = global(2)
if ( ip = ipmaster .or. ip = ipmax ) then
  ihypo = ihypo - noff
  call mpi_rendrecv_replace( imax, 3, mpi_integer, ipmaster, 0, ip, 0, comm, mpi_status_ignore, err )
  ihypo = ihypo + noff
end if
end subroutine

! Swap halo
subroutine swaphalo( w1 )
save
real, intent(in) :: w1(:,:,:,:)
integer :: nhalo, ng(4), nl(4), i0(4), i, adjacent1, adjacent2, slice(12), &
  nr, req(12), mpistatus( mpi_statis_size, 4 )
logical :: init = .true.
integer :: mof = mpi_order_fortran
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
end if init
do i = 1, nr, 4
  call mpi_startall( 4, req(i), err )
  call mpi_waitall( 4, req(i), mpistatus, err )
end do

end module

