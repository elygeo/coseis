! Swap endian
program main
implicit none
integer, parameter :: nb = 4, nr = 4096
integer :: i, j, ifile, command_argument_count
integer(8) :: n
character :: b2(nb,nr), b1(nb), b0
character(255) :: filename
do ifile = 1, command_argument_count()
  call get_command_argument( ifile, filename )
  open( 1, file=filename, recl=nb*nr, form='unformatted', access='direct', status='old' )
  filename = trim( filename ) // '.swab'
  open( 2, file=filename, recl=nb*nr, form='unformatted', access='direct', status='replace' )
  n = 0
  do
    read( 1, rec=n+1, iostat=i ) b2
    if ( i /= 0 ) exit
    do j = 1, nr
      b0 = b2(1,j); b2(1,j) = b2(4,j); b2(4,j) = b0
      b0 = b2(2,j); b2(2,j) = b2(3,j); b2(3,j) = b0
    end do
    write( 2, rec=n+1 ) b2
    n = n + 1
  end do
  close(1)
  close(2)
  call get_command_argument( ifile, filename )
  open( 1, file=filename, recl=nb, form='unformatted', access='direct', status='old' )
  filename = trim( filename ) // '.swab'
  open( 2, file=filename, recl=nb, form='unformatted', access='direct', status='old' )
  n = n * nr
  do
    read( 1, rec=n+1, iostat=i ) b1
    if ( i /= 0 ) exit
    b0 = b1(1); b1(1) = b1(4); b1(4) = b0
    b0 = b1(2); b1(2) = b1(3); b1(3) = b0
    write( 2, rec=n+1 ) b1
    n = n + 1
  end do
  close(1)
  close(2)
  write( 0, * ) trim( filename ), n
end do
end program

