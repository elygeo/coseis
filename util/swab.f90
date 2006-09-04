! Swap endian
program main
implicit none
integer, parameter :: nb = 4
integer :: i, ifile, command_argument_count
integer(8) :: n
character :: bytes(nb)
character(255) :: filename
do ifile = 1, command_argument_count()
  call get_command_argument( ifile, filename )
  open( 1, file=filename, recl=1, iostat=i, form='unformatted', access='direct', status='old' )
  if ( i /= 0 ) then
    write( *, * ) 'Error opening file: ', trim( filename )
    stop
  end if
  filename = trim( filename ) // '.swab'
  open( 2, file=filename, recl=nb, form='unformatted', access='direct', status='replace' )
  n = 0
  do
    read( 1, rec=nb*n+1, iostat=i ) bytes(4)
    if ( i /= 0 ) exit
    do i = 2, nb
      read( 1, rec=nb*n+i ) bytes(nb-i+1)
    end do
    n = n + 1
    write( 2, rec=n ) bytes
  end do
  write( 0, * ) trim( filename ), n
end do
end program

