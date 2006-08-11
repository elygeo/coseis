! Convert binary files to ASCII
program bin2asc
implicit none
integer :: n, i, ii, iii
real :: r(255)
character(255) :: filename
n = command_argument_count()
inquire( iolength=ii ) r(1)
do i = 1, n
  call get_command_argument( i, filename )
  open( i+6, file=filename, recl=ii, form='unformatted', access='direct', status='old' )
end do
ii = 0
loop: do
  ii = ii + 1
  do i = 1, n
    read( i+6, rec=ii, iostat=iii ) r(i)
    if ( iii /= 0 ) exit loop
  end do
  print *, r(1:n)
end do loop
end program

