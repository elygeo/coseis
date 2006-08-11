! Binary file stats
program stats
implicit none
integer :: i, ii, n
character(255) :: filename
real :: r, rmin, rmax, rmean
logical :: nan
do ii = 1, command_argument_count()
  call get_command_argument( ii, filename )
  inquire( iolength=i ) r
  open( 1, file=filename, recl=i, form='unformatted', access='direct', status='old' )
  read( 1, rec=1 ) r
  rmin = r
  rmax = r
  n = 1
  do
    n = n + 1
    read( 1, rec=n, iostat=i ) r
    if ( i /= 0 ) exit
    rmin = min( r, rmin )
    rmax = max( r, rmax )
    rmean = rmean + r
    nan = r /= r
  end do
  n = n - 1
  rmean = rmean / n
  print *, trim(filename), ' n=',n, ' min=',rmin, ' max=',rmax, ' mean=',rmean, ' nan=',nan
end do
end program

