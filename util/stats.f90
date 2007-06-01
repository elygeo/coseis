! Floating point stats
program main
implicit none
integer, parameter :: nr = 8192
integer(8) :: n
integer :: i, ifile, command_argument_count
real(8) :: xmean
real :: xx(nr), x, xmin, xmax
character(255) :: filename
do ifile = 1, command_argument_count()
  call get_command_argument( ifile, filename )
  inquire( iolength=i ) xx
  open( 1, file=filename, recl=i, form='unformatted', access='direct', status='old' )
  n = 0
  do
    read( 1, rec=n+1, iostat=i ) xx
    if ( i /= 0 ) exit
    if ( n == 0 ) then
      xmin = xx(1)
      xmax = xx(1)
      xmean = 0
    end if
    xmin = min( xmin, minval(xx) )
    xmax = max( xmax, maxval(xx) )
    xmean = xmean + sum(xx)
    n = n + 1
  end do
  close(1)
  inquire( iolength=i ) x
  open( 1, file=filename, recl=i, form='unformatted', access='direct', status='old' )
  n = n * nr
  do
    read( 1, rec=n+1, iostat=i ) x
    if ( i /= 0 ) exit
    if ( n == 0 ) then
      xmin = x
      xmax = x
      xmean = 0
    end if
    xmin = min( xmin, x )
    xmax = max( xmax, x )
    xmean = xmean + x
    n = n + 1
  end do
  xmean = xmean / n
  print '(3e15.6,i15,x,a)', xmin, xmax, xmean, n, trim( filename )
end do
end program

