! Convert TeraShake coordinates in meters to lat/lon
program p_ts2ll

use m_tscoords
implicit none
character(1024) :: line
real :: x(1,1,1,2)
integer :: i

doline: do
  read( 5, '(a)', iostat=i ) line
  if ( i /= 0 ) exit doline
  if ( line == '' .or. scan( '>#!%cC', line(1:1) ) /= 0 ) then
    print '(a)', trim( line )
    cycle doline
  end if
  read( line, * ) x
  i = verify( line, ' ' ); line = line(i:)
  i = scan(   line, ' ' ); line = line(i:)
  i = verify( line, ' ' ); line = line(i:)
  i = scan(   line, ' ' ); line = line(i:)
  call ts2ll( x, 1, 2 )
  print '(2f10.5,x,a)', x, trim( line )
end do doline

end program

