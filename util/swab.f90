! Swap endian of files in place
program main
implicit none
integer, parameter :: nb = 4, nr = 4096
integer(8) :: n
integer :: i, j, ifile, command_argument_count
character :: b0(nb,nr), b1(nb), b2(nb)
character(255) :: str
character :: endian

! Print native endian
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
print *, endian

! Check that all files can be opened
do ifile = 1, command_argument_count()
  call get_command_argument( ifile, str )
  open( 1, file=str, recl=nb*nr, form='unformatted', access='direct', status='old' )
  close( 1 )
end do

! Swap bytes
do ifile = 1, command_argument_count()
  call get_command_argument( ifile, str )
  inquire( iolength=i ) b0
  open( 1, file=str, recl=i, form='unformatted', access='direct', status='old' )
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
  inquire( iolength=i ) b2
  open( 1, file=str, recl=i, form='unformatted', access='direct', status='old' )
  n = n * nr
  do
    read( 1, rec=n+1, iostat=i ) b1
    if ( i /= 0 ) exit
    forall( i=1:nb ) b2(i) = b1(nb-i+1)
    write( 1, rec=n+1 ) b2
    n = n + 1
  end do
  close( 1 )
  write( 0, * ) trim( str ), n
end do
end program

