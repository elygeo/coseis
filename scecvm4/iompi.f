! MPI I/O for SCEC VM

      subroutine readpts( kerr )
      implicit none
      include 'newin.h'
      include 'mpif.h'
      integer(kind=mpi_offset_kind) :: nnd, npd, mpioffset
      integer :: kerr, ip, np, ifh, ierr, i
      character(160) :: str
      call mpi_init( ierr )
      call get_command_argument( 1, str )
      open( 1, file=str, status='old' )
      read( 1, * ) nnd
      close( 1 )
      call mpi_comm_rank( mpi_comm_world, ip, ierr )
      call mpi_comm_size( mpi_comm_world, np, ierr )
      call mpi_file_set_errhandler( mpi_file_null,
     $  MPI_ERRORS_ARE_FATAL, ierr )
      if ( ip == 0 ) write( 0, '(a)' ) 'SCEC Velocity Model version 4'
      npd = np
      nnl = nnd / npd
      if ( modulo( nnd, npd ) /= 0 ) nnl = nnl + 1
      nn = nnd - ip * nnl
      nn = min( nn, nnl )
      if ( nn > ibig ) then
         print *, 'Error: nn greater than ibig', nn, ibig
         stop
      end if
      mpioffset = ip * nnl * irealsize
      call get_command_argument( 2, str )
      call mpi_file_open( mpi_comm_world, str, mpi_mode_rdonly,
     $  mpi_info_null, ifh, ierr )
      call mpi_file_read_at( ifh, mpioffset, rlon, nn, mpi_real,
     $  mpi_status_ignore, ierr )
      call mpi_file_close( ifh, ierr )
      call get_command_argument( 3, str )
      call mpi_file_open( mpi_comm_world, str, mpi_mode_rdonly,
     $  mpi_info_null, ifh, ierr )
      call mpi_file_read_at( ifh, mpioffset, rlat, nn, mpi_real,
     $  mpi_status_ignore, ierr )
      call mpi_file_close( ifh, ierr )
      call get_command_argument( 4, str )
      call mpi_file_open( mpi_comm_world, str, mpi_mode_rdonly,
     $  mpi_info_null, ifh, ierr )
      call mpi_file_read_at( ifh, mpioffset, rdep, nn, mpi_real,
     $  mpi_status_ignore, ierr )
      call mpi_file_close( ifh, ierr )
      do i = 1, nn
        if(rdep(i).lt.0) write( 0, * ) 
     $    'Error: degative depth', i, rlon(i), rlat(i), rdep(i)
        if(rlon(i)/=rlon(i).or.rlat(i)/=rlat(i).or.rdep(i)/=rdep(i))
     $    write( 0, * ) 'Error: NaN', i, rlon(i), rlat(i), rdep(i)
        rdep(i) = rdep(i) * 3.2808399
        if( rdep(i) .lt. rdepmin ) rdep(i) = rdepmin
      end do
      kerr = 0
      end

      subroutine writepts( kerr )
      implicit none
      include 'newin.h'
      include 'mpif.h'
      integer(kind=mpi_offset_kind) :: mpioffset
      integer :: kerr, ip, ifh, ierr, i
      character(160) :: str
      call mpi_comm_rank( mpi_comm_world, ip, ierr )
      mpioffset = ip * nnl * irealsize
      call get_command_argument( 5, str )
      call mpi_file_open( mpi_comm_world, str,
     $  mpi_mode_create + mpi_mode_wronly, mpi_info_null, ifh, ierr )
      call mpi_file_write_at( ifh, mpioffset, rho, nn, mpi_real,
     $  mpi_status_ignore, ierr )
      call mpi_file_close( ifh, ierr )
      call get_command_argument( 6, str )
      call mpi_file_open( mpi_comm_world, str,
     $  mpi_mode_create + mpi_mode_wronly, mpi_info_null, ifh, ierr )
      call mpi_file_write_at( ifh, mpioffset, alpha, nn, mpi_real,
     $  mpi_status_ignore, ierr )
      call mpi_file_close( ifh, ierr )
      call get_command_argument( 7, str )
      call mpi_file_open( mpi_comm_world, str,
     $  mpi_mode_create + mpi_mode_wronly, mpi_info_null, ifh, ierr )
      call mpi_file_write_at( ifh, mpioffset, beta, nn, mpi_real,
     $  mpi_status_ignore, ierr )
      call mpi_file_close( ifh, ierr )
      call mpi_finalize( ierr )
      kerr = 0
      do i = 1, nn
        if(rho(i)/=rho(i).or.alpha(i)/=alpha(i).or.beta(i)/=beta(i))
     $    write( 0, * ) 'Error: NaN', i, rlon(i), rlat(i), rdep(i)
      end do
      end

