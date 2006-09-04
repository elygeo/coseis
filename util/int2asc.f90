! Convert integer binary files to ASCII
program main
implicit none
integer :: nfiles, i, nb, io, command_argument_count
integer(8) :: n
integer :: val
character(255) :: filename
nfiles = command_argument_count()
inquire( iolength=nb ) val
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
  do i = 1, nfiles
    read( i+6, rec=n, iostat=io ) val
    if ( io /= 0 ) exit loop
    write( *, '(i15)', advance='no' ) val
  end do
  write( *, '(a)' ) ''
end do loop
end program

