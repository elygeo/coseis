! Swap endian
! FIXME buffering would greatly speed this up
program main
implicit none
integer, parameter :: nb = 4
integer :: i, ifile, command_argument_count
integer(8) :: n
character :: bytes(nb), setyb(nb)
character(255) :: filename
do ifile = 1, command_argument_count()
  call get_command_argument( ifile, filename )
  open( 1, file=filename, recl=nb, iostat=i, form='unformatted', access='direct', status='old' )
  if ( i /= 0 ) then
    write( *, * ) 'Error opening file: ', trim( filename )
    stop
  end if
  filename = trim( filename ) // '.swab'
  open( 2, file=filename, recl=nb, form='unformatted', access='direct', status='replace' )
  n = 0
  do
    read( 1, rec=n+1, iostat=i ) bytes
    if ( i /= 0 ) exit
    forall( i=1:nb ) setyb(i) = bytes(nb-i+1)
    write( 2, rec=n+1 ) setyb
    n = n + 1
  end do
  write( 0, * ) trim( filename ), n
end do
end program

