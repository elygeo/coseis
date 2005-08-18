!------------------------------------------------------------------------------!
! MPISETUP

subroutine mpisetup( nreqs, req, comm3 )

use globals
implicit none
include 'mpif.h'
integer, intent(in) :: comm3
integer, intent(out) :: nreqs = 0, req(12)
integer :: err, i, ng(4), nl(4), start(4) = 0, ape1, ape2, vsub
logical :: period(3) = .false.

if ( comm3 == mpi_comm_null ) then
  print *, 'unused processor: ', ipe
  call mpi_finalize( err )
  stop
end if
nreqs = count( npe3 > 1 ) * 4
ng = size( v )
do i = 1, 3
if ( npe3(i) > 1 ) then
  call mpi_cart_shift( comm3, i-1, 1, ape1, ape2, err )
  nl = ng
  nl(i) = nhalo
  call mpi_type_create_subarray( 4, ng, nl, start, mpi_order_fortran, mpi_real, vsub, err )
  call mpi_type_commit( subv, err )
  i1 = i1node - nhalo
  j = i1(1)
  k = i1(2)
  l = i1(3)
  call mpi_recv_init( v(j,k,l,:), 1, vsub, ape1, 1, comm3, req(4*i-3), err )
  i1(i) = i2node(i) + nhalo
  j = i1(1)
  k = i1(2)
  l = i1(3)
  call mpi_recv_init( v(j,k,l,:), 1, vsub, ape2, 2, comm3, req(4*i-2), err )
  i1(i) = i1node(i)
  j = i1(1)
  k = i1(2)
  l = i1(3)
  call mpi_send_init( v(j,k,l,:), 1, vsub, ape1, 2, comm3, req(4*i-1), err )
  i1(i) = i2node(i)
  j = i1(1)
  k = i1(2)
  l = i1(3)
  call mpi_send_init( v(j,k,l,:), 1, vsub, ape2, 1, comm3, req(4*i-0), err )
end if
end do

end subroutine

