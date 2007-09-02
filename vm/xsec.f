      program main
      implicit none
      real, allocatable :: x(:,:)
      real :: x1(3), x2(3), dx(3)
      integer :: n(2), i, nb
      read( 5, * ) n, x1, x2
      write( 6, * ) product( n )
      dx = x2 - x1
      allocate( x( n(1), n(2) ) )
      inquire( iolength=nb ) x
      do i = 1, n(1)
        x(i,:) = x1(1) + dx(1) * ( i - 1 ) / ( n(1) - 1 )
      end do
      open( 1, file='rdep', recl=nb, form='unformatted',
     $  access='direct', status='replace' )
      write( 1, rec=1 ) x
      close( 1 )
      do i = 1, n(2)
        x(:,i) = x1(2) + dx(2) * ( i - 1 ) / ( n(2) - 1 )
      end do
      open( 1, file='rlon', recl=nb, form='unformatted',
     $  access='direct', status='replace' )
      write( 1, rec=1 ) x
      close( 1 )
      do i = 1, n(2)
        x(:,i) = x1(3) + dx(3) * ( i - 1 ) / ( n(2) - 1 )
      end do
      open( 1, file='rlat', recl=nb, form='unformatted',
     $  access='direct', status='replace' )
      write( 1, rec=1 ) x
      close( 1 )
      end program

