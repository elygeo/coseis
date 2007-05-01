! Swap endian
program main
implicit none
integer, parameter :: nb = 4
integer :: i, ifile, command_argument_count
integer(8) :: n
character :: b1(nb), b2(nb)
character(255) :: filename
do ifile = 1, command_argument_count()
  call get_command_argument( ifile, filename )
  open( 1, file=filename, recl=nb, form='unformatted', access='direct', status='old' )
  filename = trim( filename ) // '.swab'
  open( 2, file=filename, recl=nb, form='unformatted', access='direct', status='replace' )
  n = 0
  do
    read( 1, rec=n+1, iostat=i ) b1
    if ( i /= 0 ) exit
    forall( i=1:nb ) b2(i) = b1(nb-i+1)
    write( 2, rec=n+1 ) b2
    n = n + 1
  end do
  write( 0, * ) trim( filename ), n
end do
end program

