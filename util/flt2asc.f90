! Convert floating point binary files to ASCII
program flt2asc
implicit none
integer :: nfiles, i, io, command_argument_count
integer(8) :: n
real :: val
character(255) :: filename
nfiles = command_argument_count()
inquire( iolength=io ) val
do i = 1, nfiles
  call get_command_argument( i, filename )
  open( i+6, file=filename, recl=io, form='unformatted', access='direct', status='old' )
end do
n = 0
loop: do
  n = n + 1
  do i = 1, nfiles
    read( i+6, rec=n, iostat=io ) val
    if ( io /= 0 ) exit loop
    write( *, '(e15.6)', advance='no' ) val
  end do
  write( *, '(a)' ) ''
end do loop
end program

