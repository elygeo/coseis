! Binary I/O for SCEC CVM

      subroutine readpts( kerr )
      implicit none
      include 'newin.h'
      integer :: kerr, nio, i
      character(160) :: lon_file, lat_file, dep_file
      write( 0, '(a)' ) 'SCEC Community Velocity Model'
      open( 1, file='cvm-input', status='old' )
      read( 1, * ) nn
      read( 1, * ) lon_file
      read( 1, * ) lat_file
      read( 1, * ) dep_file
      close( 1 )
      if ( nn > ibig ) then
         print *, 'Error: nn greater than ibig', nn , ibig
         stop
      end if
      inquire( iolength=nio ) rlon(1:nn)
      write( 0, '(a)' ) 'Reading input'
      open( 1, file=lon_file, recl=nio, form='unformatted',
     $  access='direct', status='old' )
      open( 2, file=lat_file, recl=nio, form='unformatted',
     $  access='direct', status='old' )
      open( 3, file=dep_file, recl=nio, form='unformatted',
     $  access='direct', status='old' )
      read( 1, rec=1 ) rlon(1:nn)
      read( 2, rec=1 ) rlat(1:nn)
      read( 3, rec=1 ) rdep(1:nn)
      close( 1 )
      close( 2 )
      close( 3 )
      write( 0, '(a)' ) 'Sampling velocity model'
      do i = 1, nn
        if( rdep(i) .lt. 0 ) write( 0, * )
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
      integer :: kerr, nio, i
      character(160) :: rho_file, alpha_file, beta_file
      inquire( iolength=nio ) rho(1:nn)
      open( 1, file='cvm-input', status='old' )
      read( 1, * ) rho_file
      read( 1, * ) rho_file
      read( 1, * ) rho_file
      read( 1, * ) rho_file
      read( 1, * ) rho_file
      read( 1, * ) alpha_file
      read( 1, * ) beta_file
      close( 1 )
      write( 0, '(a)' ) 'Writing output'
      open( 1, file=rho_file, recl=nio, form='unformatted',
     $  access='direct', status='replace' )
      open( 2, file=alpha_file, recl=nio, form='unformatted',
     $  access='direct', status='replace' )
      open( 3, file=beta_file,recl=nio, form='unformatted',
     $  access='direct', status='replace' )
      write( 1, rec=1 ) rho(1:nn)
      write( 2, rec=1 ) alpha(1:nn)
      write( 3, rec=1 ) beta(1:nn)
      close( 1 )
      close( 2 )
      close( 3 )
      do i = 1, nn
        if(rho(i)/=rho(i).or.alpha(i)/=alpha(i).or.beta(i)/=beta(i))
     $    write( 0, * ) 'Error: NaN', i, rlon(i), rlat(i), rdep(i)
      end do
      write( 0, '(a)' ) 'Finished'
      kerr = 0
      end

