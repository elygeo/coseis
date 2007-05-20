! Swap endian of a file in place
program main
implicit none
integer, parameter :: nb = 4, nr = 4096
integer(8) :: n
integer :: i, j, ifile, command_argument_count
character :: b0(nb,nr), b1(nb), b2(nb)
character(255) :: filename
do ifile = 1, command_argument_count()
  call get_command_argument( ifile, filename )
  open( 1, file=filename, recl=nb*nr, form='unformatted', access='direct', status='old' )
  n = 0
  do
    read( 1, rec=n+1, iostat=i ) b0
    if ( i /= 0 ) exit
    do j = 1, nr
      forall( i=1:nb ) b1(i) = b0(nb-i+1,j)
      b0(:,j) = b1
    end do
    write( 1, rec=n+1 ) b0
    n = n + 1
  end do
  close(1)
  open( 1, file=filename, recl=nb, form='unformatted', access='direct', status='old' )
  n = n * nr
  do
    read( 1, rec=n+1, iostat=i ) b1
    if ( i /= 0 ) exit
    forall( i=1:nb ) b2(i) = b1(nb-i+1)
    write( 1, rec=n+1 ) b2
    n = n + 1
  end do
  close(1)
  write( 0, * ) trim( filename ), n
end do
end program

