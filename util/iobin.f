! Binary I/O for SCEC VM

      subroutine readpts( kerr )
      include 'in.h'
      open( 1,file='nn',status='old' )
      read( 1,* ) nn
      close( 1 )
      if( nn > ibig ) stop 'ibig too small'
      open( 1,file='rlon',recl=4,form='unformatted',access='direct',
     $  status='old' )
      open( 2,file='rlat',recl=4,form='unformatted',access='direct',
     $  status='old' )
      open( 3,file='rdep',recl=4,form='unformatted',access='direct',
     $  status='old' )
      do i = 1, nn
        read( 1,rec=i ) rlon(i)
        read( 2,rec=i ) rlat(i)
        read( 3,rec=i ) rdep(i)
      end do
      close( 1 )
      close( 2 )
      close( 3 )
      do i = 1, nn
        if(rdep(i).lt.0)
     $    print *, 'Error: degative depth', i, rlon(i), rlat(i), rdep(i)
        if(rlon(i)/=rlon(i).or.rlat(i)/=rlat(i).or.rdep(i)/=rdep(i))
     $    print *, 'Error: nan', i, rlon(i), rlat(i), rdep(i)
        rdep(i) = rdep(i) * 3.2808399
        if( rdep(i) .lt. rdepmin ) rdep(i) = rdepmin
      end do
      kerr = 0
      end

      subroutine writepts( kerr )
      include 'in.h'
      open( 1,file='vp', recl=4,form='unformatted',access='direct' )
      open( 2,file='vs', recl=4,form='unformatted',access='direct' )
      open( 3,file='rho',recl=4,form='unformatted',access='direct' )
      do i = 1, nn
        if(alpha(i)/=alpha(i).or.beta(i)/=beta(i).or.rho(i)/=rho(i))
     $    print *, 'Error: nan', i, rlon(i), rlat(i), rdep(i)
        write( 1,rec=i ) alpha(i)
        write( 2,rec=i ) beta(i)
        write( 3,rec=i ) rho(i)
      end do
      close( 1 )
      close( 2 )
      close( 3 )
      kerr = 0
      end

