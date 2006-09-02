! Convert ASCII to floating point binary files
program main
implicit none
integer :: nfiles, i, io, command_argument_count
integer(8) :: n
real :: vals(255)
character(255) :: filename
nfiles = command_argument_count()
inquire( iolength=io ) vals(1)
do i = 1, nfiles
  call get_command_argument( i, filename )
  open( i+6, file=filename, recl=io, form='unformatted', access='direct', status='new' )
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

