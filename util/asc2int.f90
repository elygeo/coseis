! Convert ASCII to integer binary files
program main
implicit none
integer :: nfiles, i, nb, io, command_argument_count
integer(8) :: n
integer :: vals(255)
character(255) :: filename
nfiles = command_argument_count()
inquire( iolength=nb ) vals(1)
do i = 1, nfiles
  call get_command_argument( i, filename )
  open( i+6, file=filename, recl=nb, iostat=io, form='unformatted', access='direct', status='old' )
  if ( io /= 0 ) then
    write( *, * ) 'Error opening file: ', trim( filename )
    stop
  end if
end do
n = 0
loop: do
  n = n + 1
  read( 5, *, iostat=io ) vals(1:nfiles)
  if ( io /= 0 ) exit loop
  do i = 1, nfiles
    write( i+6, rec=n ) vals(i)
  end do
end do loop
end program

