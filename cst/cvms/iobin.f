! Binary I/O for SCEC CVM

      subroutine readpts(kerr)
      implicit none
      include 'in.h'
      integer :: kerr, nio, i
      character(160) :: file_lon, file_lat, file_dep
      write (0, '(a)') 'SCEC Community Velocity Model'
      open (1, file='cvms-input', status='old')
      read (1, *) nn
      read (1, '(a)') file_lon
      read (1, '(a)') file_lat
      read (1, '(a)') file_dep
      close (1)
      if (nn > ibig) then
          write (0, *) 'Error: nn greater than ibig', nn , ibig
          stop
      end if
      inquire (iolength=nio) rlon(1:nn)
      write (0, '(a)') 'Reading input'
      open (1, file=file_lon, recl=nio, form='unformatted',
     $    access='direct', status='old')
      open (2, file=file_lat, recl=nio, form='unformatted',
     $    access='direct', status='old')
      open (3, file=file_dep, recl=nio, form='unformatted',
     $    access='direct', status='old')
      read (1, rec=1) rlon(1:nn)
      read (2, rec=1) rlat(1:nn)
      read (3, rec=1) rdep(1:nn)
      close (1)
      close (2)
      close (3)
      write (0, '(a)') 'Sampling velocity model'
      do i = 1, nn
          if (rdep(i) .lt. 0) write (0, *)
     $        'Error: degative depth', i, rlon(i), rlat(i), rdep(i)
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
      integer :: kerr, nio, i
      character (160) :: file_rho, file_alpha, file_beta
      inquire (iolength=nio) rho(1:nn)
      open (1, file='cvms-input', status='old')
      read (1, '(a)') file_rho
      read (1, '(a)') file_rho
      read (1, '(a)') file_rho
      read (1, '(a)') file_rho
      read (1, '(a)') file_rho
      read (1, '(a)') file_alpha
      read (1, '(a)') file_beta
      close (1)
      write (0, '(a)') 'Writing output'
      open (1, file=file_rho, recl=nio, form='unformatted',
     $    access='direct', status='replace')
      open (2, file=file_alpha, recl=nio, form='unformatted',
     $    access='direct', status='replace')
      open (3, file=file_beta, recl=nio, form='unformatted',
     $    access='direct', status='replace')
      write (1, rec=1) rho(1:nn)
      write (2, rec=1) alpha(1:nn)
      write (3, rec=1) beta(1:nn)
      close (1)
      close (2)
      close (3)
      do i = 1, nn
          if (rho(i)/=rho(i).or.alpha(i)/=alpha(i).or.beta(i)/=beta(i))
     $        write (0, *) 'Error: NaN', i, rlon(i), rlat(i), rdep(i)
      end do
      write (0, '(a)') 'Finished'
      kerr = 0
      end

