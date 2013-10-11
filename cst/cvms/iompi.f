! MPI I/O for SCEC CVM

      subroutine readpts (kerr)
      implicit none
      include 'in.h'
      include 'mpif.h'
      integer (kind=mpi_offset_kind) :: offset, nn8, np8, nnl8
      integer :: kerr, ip, np, ifh, info, ierr, i
      character (160) :: file_lon, file_lat, file_dep
      call mpi_init(ierr)
      open (1, file='cvms.in', status='old')
      read (1, *) nn8
      read (1, '(a)') file_lon
      read (1, '(a)') file_lat
      read (1, '(a)') file_dep
      close (1)
      call mpi_comm_rank(mpi_comm_world, ip, ierr)
      call mpi_comm_size(mpi_comm_world, np, ierr)
      call mpi_file_set_errhandler(mpi_file_null,
     $    mpi_errors_are_fatal, ierr)
      if (ip == 0) write (0, '(a)') 'SCEC Community Velocity Model'
      nnl = nn8 / np
      np8 = np
      if (modulo(nn8, np8) /= 0) nnl = nnl + 1
      nnl8 = nnl
      nn = min(nnl8, nn8 - nnl8 * ip)
      if (nn > ibig) then
          write (0, *) 'Error: nn greater than ibig', nn, ibig
          stop
      end if
      call mpi_type_size(mpi_real, i, ierr)
      offset = i
      offset = offset * nnl * ip
      if (ip == 0) write (0, '(a)') 'Reading input'
      i =  mpi_mode_rdonly
      info = mpi_info_null
      call mpi_file_open(mpi_comm_world, file_lon, i, info, ifh, ierr)
      call mpi_file_read_at_all(ifh, offset, rlon, nn, mpi_real,
     $    mpi_status_ignore, ierr)
      call mpi_file_close(ifh, ierr)
      call mpi_file_open(mpi_comm_world, file_lat, i, info, ifh, ierr)
      call mpi_file_read_at_all(ifh, offset, rlat, nn, mpi_real,
     $    mpi_status_ignore, ierr)
      call mpi_file_close(ifh, ierr)
      call mpi_file_open(mpi_comm_world, file_dep, i, info, ifh, ierr)
      call mpi_file_read_at_all(ifh, offset, rdep, nn, mpi_real,
     $    mpi_status_ignore, ierr)
      call mpi_file_close(ifh, ierr)
      if (ip == 0) write (0, '(a)') 'Sampling velocity model'
      do i = 1, nn
          if (rdep(i).lt.0) write(0, *)
     $        'Error: negative depth', i, rlon(i), rlat(i), rdep(i)
          if (rlon(i)/=rlon(i).or.rlat(i)/=rlat(i).or.rdep(i)/=rdep(i))
     $        write (0, *) 'Error: NaN', i, rlon(i), rlat(i), rdep(i)
          rdep(i) = rdep(i) * 3.2808399
          if (rdep(i) .lt. rdepmin) rdep(i) = rdepmin
      end do
      kerr = 0
      end

      subroutine writepts(kerr)
      implicit none
      include 'in.h'
      include 'mpif.h'
      integer (kind=mpi_offset_kind) :: offset
      integer :: kerr, ip, ifh, info, ierr, i
      character (160) :: file_rho, file_alpha, file_beta
      open (1, file='cvms.in', status='old')
      read (1, '(a)') file_rho
      read (1, '(a)') file_rho
      read (1, '(a)') file_rho
      read (1, '(a)') file_rho
      read (1, '(a)') file_rho
      read (1, '(a)') file_alpha
      read (1, '(a)') file_beta
      close (1)
      call mpi_comm_rank(mpi_comm_world, ip, ierr)
      call mpi_type_size(mpi_real, i, ierr)
      offset = i
      offset = offset * nnl * ip
      if (ip == 0) write (0, '(a)') 'Writing output'
      i = mpi_mode_create + mpi_mode_wronly
      info = mpi_info_null
      call mpi_file_open(mpi_comm_world, file_rho, i, info, ifh, ierr)
      call mpi_file_write_at_all(ifh, offset, rho, nn, mpi_real,
     $    mpi_status_ignore, ierr)
      call mpi_file_close(ifh, ierr)
      call mpi_file_open(mpi_comm_world, file_alpha, i, info, ifh, ierr)
      call mpi_file_write_at_all(ifh, offset, alpha, nn, mpi_real,
     $    mpi_status_ignore, ierr)
      call mpi_file_close(ifh, ierr)
      call mpi_file_open(mpi_comm_world, file_beta, i, info, ifh, ierr)
      call mpi_file_write_at_all(ifh, offset, beta, nn, mpi_real,
     $    mpi_status_ignore, ierr)
      call mpi_file_close(ifh, ierr)
      kerr = 0
      do i = 1, nn
          if (rho(i)/=rho(i).or.alpha(i)/=alpha(i).or.beta(i)/=beta(i))
     $        write (0, *) 'Error: NaN', i, rlon(i), rlat(i), rdep(i)
      end do
      if (ip == 0) write (0, '(a)') 'Finished'
      call mpi_finalize(ierr)
      end

