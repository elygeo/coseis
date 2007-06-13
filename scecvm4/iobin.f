! Binary I/O for SCEC VM

      subroutine readpts( kerr )
      character(160) :: str
      include 'newin.h'
      write( 0, * ) 'SCEC Velocity Model version 4'
      call get_command_argument( 1, str )
      open( 1, file=str, status='old' )
      read( 1, * ) nn
      close( 1 )
      if( nn > ibig ) stop 'ibig too small'
      call get_command_argument( 2, str )
      open( 1, file=str, recl=4*nn, form='unformatted', access='direct',
     $  status='old' )
      call get_command_argument( 3, str )
      open( 2, file=str, recl=4*nn, form='unformatted', access='direct',
     $  status='old' )
      call get_command_argument( 4, str )
      open( 3, file=str, recl=4*nn, form='unformatted', access='direct',
     $  status='old' )
      read( 1, rec=1 ) rlon(1:nn)
      read( 2, rec=1 ) rlat(1:nn)
      read( 3, rec=1 ) rdep(1:nn)
      close( 1 )
      close( 2 )
      close( 3 )
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
      character(160) :: str
      include 'newin.h'
      call get_command_argument( 5, str )
      open( 1, file=str, recl=4*nn, form='unformatted', access='direct',
     $  status='replace' )
      call get_command_argument( 6, str )
      open( 2, file=str, recl=4*nn, form='unformatted', access='direct',
     $  status='replace' )
      call get_command_argument( 7, str )
      open( 3, file=str,recl=4*nn, form='unformatted', access='direct',
     $  status='replace' )
      do i = 1, nn
        if(rho(i)/=rho(i).or.alpha(i)/=alpha(i).or.beta(i)/=beta(i))
     $    write( 0, * ) 'Error: NaN', i, rlon(i), rlat(i), rdep(i)
      end do
      write( 1, rec=1 ) rho(1:nn)
      write( 2, rec=1 ) alpha(1:nn)
      write( 3, rec=1 ) beta(1:nn)
      close( 1 )
      close( 2 )
      close( 3 )
      kerr = 0
      end

