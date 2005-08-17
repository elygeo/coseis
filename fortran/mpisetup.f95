!------------------------------------------------------------------------------!
! MPISETUP

subroutine mpisetup( nreqs, req, comm3d )
use globals
include 'mpif.h'
integer, intent(in) :: comm3d
integer, intent(out) :: nreqs = 0, req(12)
integer :: err, i, gsize(4), lsize(4), start(4) = 0, ape1, ape2, vsub
logical :: period(3) = .false.

if ( comm3d == mpi_comm_null ) then
  print *, 'unused processor: ', ipe
  call mpi_finalize( err )
  stop
end if
nreqs = count( npe3d > 1 ) * 4
gsize = size( v )
do i = 1, 3
if ( npe3d(i) > 1 ) then
  call mpi_cart_shift( comm3d, i-1, 1, ape1, ape2, err )
  lsize = gsize
  lsize(i) = nhalo
  call mpi_type_create_subarray( 4, gsize, lsize, start, mpi_order_fortran, mpi_real, subarray, err )
  call mpi_type_commit( subv, err )
  i1 = i1node - nhalo
  i2 = i2node + nhalo
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  call mpi_recv_init( v(j1,k1,l1,:), 1, vsub, ape1, 1, comm3d, req(4*i-3), err)
  call mpi_recv_init( v(j2,k2,l2,:), 1, vsub, ape2, 2, comm3d, req(4*i-2), err)
  i1(i) = i1(i) + 1
  i2(i) = i2(i) - 1
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  call mpi_send_init( v(j1,k1,l1,:), 1, vsub, ape1, 2, comm3d, req(4*i-1), err)
  call mpi_send_init( v(j2,k2,l2,:), 1, vsub, ape2, 1, comm3d, req(4*i-0), err)
end if
end do

end subroutine

