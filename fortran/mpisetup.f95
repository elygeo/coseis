!==============================================================================!
! MPISETUP
!------------------------------------------------------------------------------!

subroutine mpisetup( nreqs, req, comm3d )
use globals
include 'mpif.h'

integer :: err, penmln, comm3d, i, hat, blens(3), displs(3), nreqs, &
  req(3*2*2), tag, way, side, gsize(4), lsize(4), start(4), types(3), nvars, &
  house, n
logical :: period(3) = .false.

!------------------------------------------------------------------------------!

if ( comm3d == mpi_comm_null ) then
  print *, 'unused processor: ', ipe
  call mpi_finalize( err )
  stop
end if
do i = 1, 3
  call mpi_cart_shift( comm3d, i-1, 1, adjpe(1,i), adjpe(2,i), err )
end do

call mpi_address( v,     displs(1), err )
call mpi_address( vslip, displs(2), err )
blens = 1
displs = displs - displs(1)
nreqs = 0

do hat = 1, 3
if ( npe3d(hat) > 1 ) then
do way = 0, 1
do side = 0, 1

  gsize(1:3) = mp
  lsize(1:3) = nl
  gsize(4) = 3
  lsize(4) = 3
  start = 0
  lsize(hat) = halo
  if ( side == 0 )  then
    start(hat) = way * halo
  else
    start(hat) = nl(hat) - halo - way * halo
  end if
  call mpi_type_create_subarray( 4, gsize, lsize, start, mpi_order_fortran, mpi_real, types(1), err )
  call mpi_type_commit( types(1), err )
  gsize(4) = lsp
  lsize(4) = lsp
  call mpi_type_create_subarray( 4, gsize, lsize, start, mpi_order_fortran, mpi_real, types(2), err )
  call mpi_type_commit( types(2), err )
  gsize(1) = 1
  lsize(1) = 1
  call mpi_type_create_subarray( 4, gsize, lsize, start, mpi_order_fortran, mpi_real, types(3), err )
  call mpi_type_commit( types(3), err )
  if ( hat == 3 ) then
    nvars = 1
  else
    nvars = 3
  end if
  call mpi_type_struct( nvars, blens, displs, types, house, err )
  call mpi_type_commit( house, err )
  nreqs = nreqs + 1
  tag = mod( side+way, 2 )
  if ( way == 0 ) then
    call mpi_recv_init( v, 1, house, adjpe(side+1,hat), tag, comm3d, req(nreqs), err)
  else
    call mpi_send_init( v, 1, house, adjpe(side+1,hat), tag, comm3d, req(nreqs), err)
  end if

end do ! side
end do ! way
end if ! npe
end do ! hat

return
end

