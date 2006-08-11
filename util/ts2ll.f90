! Convert TeraShake coordinates in meters to lat/lon
program p_ts2ll

use m_tscoords
implicit none
character(160) :: line, str
real :: x(1,1,1,2)
integer :: err

doline: do
  read( 5, '(a)', iostat=err ) line
  if ( err /= 0 ) exit doline
  if ( line == '' .or. scan( '>#!%cC', line(1:1) ) /= 0 ) then
    print '(a)', trim( line )
    cycle doline
  end if
  str = ''
  read( line, *, iostat=err ) x, str
  if ( err == 0 ) read( line, * ) x
  call ts2ll( x, 1, 2 )
  print '(2f10.5,x,a)', x, trim( str )
end do doline

end program

