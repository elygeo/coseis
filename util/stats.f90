! Floating point stats
program main
implicit none
integer :: ifile, nb, i, command_argument_count
integer(8) :: n
character(255) :: filename
real :: r, rmin, rmax
real(8) :: rmean
do ifile = 1, command_argument_count()
  call get_command_argument( ifile, filename )
  inquire( iolength=nb ) r
  open( 1, file=filename, recl=nb, iostat=i, form='unformatted', access='direct', status='old' )
  if ( i /= 0 ) then
    write( *, * ) 'Error opening file: ', trim( filename )
    stop
  end if
  read( 1, rec=1 ) r
  rmin = r
  rmax = r
  rmean = r
  n = 1
  do
    read( 1, rec=n+1, iostat=i ) r
    if ( i /= 0 ) exit
    n = n + 1
    rmin = min( r, rmin )
    rmax = max( r, rmax )
    rmean = rmean + r
    if ( r /= r ) print *, 'NaN', n
  end do
  rmean = rmean / n
  print '(3e15.6,i15,x,a)', rmin, rmax, rmean, n, trim( filename )
end do
end program

