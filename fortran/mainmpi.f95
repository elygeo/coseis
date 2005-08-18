!------------------------------------------------------------------------------!
! PARALLEL SORD

program sord

use globals
implicit none
include 'mpif.h'
integer :: nreqs, req(12), comm3, commout(???), mpistatus( mpi_statis_size, 4 )
integer :: i, wt(5), wt_rate, err
real :: dwt(5)

call mpi_init( err )
call mpi_comm_rank( comm3, ipe, err )
call inputs

np = npg / npe3; where ( mod( npg, npe3 ) /= 0 ) np = np + 1
npe3 = npg / np; where ( mod( npg, np ) /= 0 ) npe3 = npe3 + 1
i1node = np * ipe3 + 1
i2node = np * ipe3 + np; i2node = min( i2node, npg )
i1cell = i1node
i2cell = i2node - 1
where( ipe3 /= 0         ) i1cell = i1cell - nhalo
where( ipe3 /= npe3d - 1 ) i2cell = i2cell + nhalo
i1nodepml = max( i1node, 1       + bc(1:3) * npml )
i2nodepml = min( i2node, npg     - bc(4:6) * npml )
i1cellpml = max( i1cell, 1       + bc(1:3) * npml )
i2cellpml = min( i2cell, npg - 1 - bc(4:6) * npml )

call mpi_cart_create( mpi_comm_world, 3, npe3, period, .true., comm3, err )
call mpi_comm_rank( mpi_comm_world, ipe, err )
call mpi_cart_get( comm3, 3, npe3, period, ipe3, err )
call setup
call mpisetup
call mpioutput( 0 )
do i = 1, nout
  call mpi_comm_split( comm3, outme(i), ipe, commout(i), err )
end do
it = 0
call mpi_allreduce( it, it1, 1, mpi_integer, mpi_min, comm3, err )
if ( ipe == 0 ) print '(a)', 'step  compute  commun   output   checkpnt total'

do while ( it <= nt )
  it = it + 1;
  call system_clock( wt(1), count_rate=wt_rate )
  call vstep
  call system_clock( wt(2) )
  do i = 1, nreqs, 4
    call mpi_startall( 4, req(i), err )
    call mpi_waitall( 4, req(i), mpistatus, err )
  end do
  call system_clock( wt(3) )
  u = u + dt * v
  call wstep
  call system_clock( wt(4) )
  call mpioutput( i, commout(i) )
  call system_clock( wt(5) )
  dwt(1:4) = real( wt(2:5) - wt(1:4) ) / real( wt_rate )
  dwt(5)   = real( wt(4)   - wt(1)   ) / real( wt_rate )
  if ( ipe == 0 ) print '(i5,x,4(e9.2))', it, dwt
end do
call mpi_finalize( err )

end program

