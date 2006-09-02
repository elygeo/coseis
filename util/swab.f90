! Swap endian
program main
implicit none
integer, parameter :: n = 4
integer :: i, ii, ifile, command_argument_count
character :: bytes(n)
character(255) :: filename
do ifile = 1, command_argument_count()
  call get_command_argument( ifile, filename )
  open( 1, file=filename, recl=1, form='unformatted', access='direct', status='old' )
  filename = trim( filename ) // '.swab'
  open( 2, file=filename, recl=n, form='unformatted', access='direct' )
  i = 0
  do
    read( 1, rec=n*i+1, iostat=ii ) bytes(4)
    if ( ii /= 0 ) exit
    do ii = 2, n
      read( 1, rec=n*i+ii ) bytes(n-ii+1)
    end do
    i = i + 1
    write( 2, rec=i ) bytes
  end do
  write( 0, * ) trim( filename ), i
end do
end program

