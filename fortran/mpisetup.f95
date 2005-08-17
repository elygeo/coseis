!------------------------------------------------------------------------------!
! MPISETUP

subroutine mpisetup( nreqs, req, comm3d )
use globals
include 'mpif.h'
integer, intent(in) :: comm3d
integer, intent(out) :: nreqs = 0, req(12)
integer :: err, i, hat, tag, way, side, gsize(4), lsize(4), start(4), n
logical :: period(3) = .false.

if ( comm3d == mpi_comm_null ) then
  print *, 'unused processor: ', ipe
  call mpi_finalize( err )
  stop
end if
do i = 1, 3
  call mpi_cart_shift( comm3d, i-1, 1, adjpe(1,i), adjpe(2,i), err )
end do

gsize(4) = 3
lsize(4) = 3
a: do hat = 1, 3
b: if ( npe3d(hat) > 1 ) then
c: do way = 0, 1
d: do side = 0, 1
  nreqs = nreqs + 1
  gsize(1:3) = mp
  lsize(1:3) = nl
  start = 0
  lsize(hat) = halo
  if ( side == 0 )  then
    start(hat) = way * halo
  else
    start(hat) = nl(hat) - halo - way * halo
  end if
  call mpi_type_create_subarray( 4, gsize, lsize, start, mpi_order_fortran, mpi_real, subarray, err )
  call mpi_type_commit( subarray, err )
  tag = mod( side + way, 2 )
  if ( way == 0 ) then
    call mpi_recv_init( v, 1, subarray, adjpe(side+1,hat), tag, comm3d, req(nreqs), err)
  else
    call mpi_send_init( v, 1, subarray, adjpe(side+1,hat), tag, comm3d, req(nreqs), err)
  end if
end do d
end do c
end if b
end do a

end subroutine

