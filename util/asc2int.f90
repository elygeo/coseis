! Convert ASCII to integer binary files
program asc2int
implicit none
integer :: n, i, ii, command_argument_count
integer :: vals(255)
character(255) :: filename
n = command_argument_count()
inquire( iolength=ii ) vals(1)
do i = 1, n
  call get_command_argument( i, filename )
  open( i+6, file=filename, recl=ii, form='unformatted', access='direct', status='new' )
end do
n = 3
ii = 0
loop: do
  ii = ii + 1
  read( 5, *, iostat=i ) vals(1:n)
  if ( i /= 0 ) exit loop
  do i = 1, n
    write( i+6, rec=ii ) vals(i)
  end do
end do loop
end program

