! Floating point stats
program main
implicit none
integer, parameter :: nr = 8192
integer(8) :: n
integer :: io, ifile, command_argument_count
real(8) :: xmean
real :: xx(nr), x, xmin, xmax
character(255) :: filename
print '(a)', '        Min            Max           Mean                  N'
do ifile = 1, command_argument_count()
  call get_command_argument( ifile, filename )
  inquire( iolength=io ) xx
  open( 1, file=filename, recl=io, form='unformatted', access='direct', status='old' )
  n = 0
  do
    read( 1, rec=n+2, iostat=io ) xx ! work around gfortran bug
    if ( io /= 0 ) exit
    read( 1, rec=n+1 ) xx
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
  inquire( iolength=io ) x
  open( 1, file=filename, recl=io, form='unformatted', access='direct', status='old' )
  n = n * nr
  do
    read( 1, rec=n+1, iostat=io ) x
    if ( io /= 0 ) exit
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
  print '(3g15.7,i15,1x,a)', xmin, xmax, xmean, n, trim( filename )
end do
end program

