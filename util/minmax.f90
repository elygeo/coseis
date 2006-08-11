! Find extreme values for binary file
program minmax
implicit none
integer :: i, ii, ifile
character(255) :: filename
real :: r, rmin, rmax
do ifile = 1, command_argument_count()
  call get_command_argument( ifile, filename )
  inquire( iolength=ii ) r
  open( 1, file=filename, recl=ii, form='unformatted', access='direct', status='old' )
  read( 1, rec=1 ) r
  rmin = r
  rmax = r
  i = 1
  do
    i = i + 1
    read( 1, rec=i, iostat=ii ) r
    if ( ii /= 0 ) exit
    rmin = min( r, rmin )
    rmax = max( r, rmax )
  end do
  print *, trim( filename ), i-1, rmin, rmax
end do
end program

