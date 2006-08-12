! Convert ASCII to binary files
program asc2bin
implicit none
integer :: n, i, ii, iii, command_argument_count
real :: r(255)
character(255) :: filename
n = command_argument_count()
inquire( iolength=ii ) r(1)
do i = 1, n
  call get_command_argument( i, filename )
  open( i+6, file=filename, recl=ii, form='unformatted', access='direct', status='new' )
end do
ii = 0
loop: do
  ii = ii + 1
  read( 5, '(a)', iostat=i ) r(1:n)
  if ( i /= 0 ) exit loop
  do i = 1, n
    write( i+6, rec=ii ) r(i)
  end do
end do loop
end program

