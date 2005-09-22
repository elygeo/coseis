!------------------------------------------------------------------------------!
! MPI

module parallel_m
use mpi

implicit none
save
integer :: err, comm, root, mof = mpi_order_fortran, msi = mpi_status_ignore
logical :: period(3) = .false.

contains

subroutine init;     call mpi_init( err );     end subroutine
subroutine finalize; call mpi_finalize( err ); end subroutine

! Integer minimum
subroutine allmini( il, ig )
integer, intent(in) :: il
integer, intent(out) :: ig
call mpi_allreduce( il, ig, 1, mpi_integer, mpi_min, comm, err )
end subroutine

! Real minimum & location, root proc get result
subroutine pminloc( r, rmax, imax, noff, iroot )
real, intent(in) :: r(:,:,:)
real, intent(out) :: rmax
integer, intent(in) :: iroot
integer, intent(out) :: imax(3)
imax = minloc( r )
rmax = r(imax(1),imax(2),imax(3))
imax = imax - noff
call mpi_reduce( rmax, 1, mpi_real, mpi_min, iroot, comm, err )
call mpi_rendrecv_replace( imax, 3, mpi_integer, iroot, ip, 0, ip, 0, err )
end subroutine

! Real maximum & location, root proc get result
subroutine pmaxloc( r, rmax, imax, iroot )
real, intent(in) :: r(:,:,:)
real, intent(out) :: rmax
integer, intent(in) :: iroot
integer, intent(out) :: imax(3)
real :: rl
imax = maxloc( r )
rmax = r(imax(1),imax(2),imax(3))
imax = imax - noff
call mpi_reduce( rmax, 1, mpi_real, mpi_max, iroot, comm, err )
call mpi_rendrecv_replace( imax, 3, mpi_integer, iroot, ip, 0, ip, 0, err )
end subroutine

! Real minimum & location
subroutine allminloc( r, rmax, imax, noff, iroot )
real, intent(in) :: r(:,:,:)
real, intent(out) :: rmax
integer, intent(out) :: imax(3), iroot
real :: lpair(2), gpair(2)
integer :: ip
imax = minloc( r )
lpair(1) = r(i(1),i(2),i(3))
imax = imax - noff
call mpi_comm_rank( comm, ip, err  )
lpair(2) = ip
call mpi_allreduce( lpair, gpair, 2, mpi_real, mpi_minloc, comm, err )
rmax  = gpair(1)
iroot = gpair(2)
call mpi_bcast( imax, 3, mpi_integer, iroot, comm, err )
end subroutine

! Real maximum & location
subroutine allmaxloc( r, rmax, imax, noff, iroot )
real, intent(in) :: r(:,:,:)
real, intent(out) :: rmax
integer, intent(out) :: imax(3), iroot
real :: lpair(2), gpair(2)
integer :: ip
imax = maxloc( r )
lpair(1) = r(imax(1),imax(2),imax(3))
imax = imax - noff
call mpi_comm_rank( comm, ip, err  )
lpair(2) = ip
call mpi_allreduce( lpair, gpair, 2, mpi_real, mpi_maxloc, comm, err )
rmax  = gpair(1)
iroot = gpair(2)
call mpi_bcast( imax, 3, mpi_integer, iroot, comm, err )
end subroutine

! Processor rank
subroutine rank( np, ip, ip3 )
integer, intent(in) :: np
integer, intent(out) :: ip, ip3
call mpi_cart_create( mpi_comm_world, 3, np, period, .true., comm, err )
if ( comm == mpi_comm_null ) then
  print *, 'Unused processor: ', ip
  call mpi_finalize( err )
  stop
end if
call mpi_cart_get( comm, 3, np, period, ip3, err )
call mpi_comm_rank( comm, ip, err  )
end subroutine

! Swap halo
subroutine swaphalo( w1 )
save
real, intent(in) :: w1(:,:,:,:)
integer :: nhalo, ng(4), nl(4), i0(4), i, adjacent1, adjacent2, slice(12), &
  nr, req(12), mpistatus( mpi_statis_size, 4 )
logical :: init = .true.
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

