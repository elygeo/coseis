!------------------------------------------------------------------------------!
! PARALLEL SORD

program sord
use globals
include 'mpif.h'
integer :: nreqs, req(12), comm3d, commout(???), mpistatus( mpi_statis_size, 4 )
integer :: i, wt(5), wt_rate, err
real :: dwt(5)

call mpi_init( err )
call mpi_comm_rank( comm3d, ipe, err )
call inputs
np = npg / npe3d; where ( mod( npg, npe3d ) /= 0 ) np = np + 1
npe3d = npg / np; where ( mod( npg, np ) /= 0 ) npe3d = npe3d + 1
call mpi_cart_create( mpi_comm_world, 3, npe3d, period, .true., comm3d, err )
call mpi_comm_rank( mpi_comm_world, ipe, err )
call mpi_cart_get( comm3d, 3, npe3d, period, ipe3d, err )
call setup
call output( 0 )
call mpisetup
call mpioutput( 0 )
do i = 1, nout
  call mpi_comm_split( comm3d, outme(i), ipe, commout(i), err )
end do
if ( ipe == 0 ) print '(a)', 'step  compute  commun   output   checkpnt total'
it = 0
call mpi_allreduce( it, it1, 1, mpi_integer, mpi_min, comm3d, err )

do while ( it <= nt )
  it = it + 1;
  call system_clock( wt(1), count_rate=wt_rate )
  call vstep
  call wstep
  call system_clock( wt(2) )
  do i = 1, nreqs, 4
    call mpi_startall( 4, req(i), err )
    call mpi_waitall( 4, req(i), mpistatus, err )
  end do
  call system_clock( wt(3) )
  do i = 1, nout
  if ( outme(i) .and. mod( it, outint(i) ) == 0 ) then
    if ( outmee(i) ) then
      call output( i )
    else
      call mpioutput( i, commout(i) )
    end if
  end if
  end do
  call system_clock( wt(4) )
  call system_clock( wt(5) )
  dwt(1:4) = real( wt(2:5) - wt(1:4) ) / real( wt_rate )
  dwt(5)   = real( wt(4)   - wt(1)   ) / real( wt_rate )
  if ( ipe == 0 ) print '(i5,x,4(e9.2))', it, dwt
end do
call mpi_finalize( err )

end program

