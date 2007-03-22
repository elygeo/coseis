! Convert lon/lat to TeraShake coordinates in meters
program main

use m_tscoords
implicit none
character(1024) :: str
real :: x(1,1,1,2)
integer :: i

doline: do
  read( 5, '(a)', iostat=i ) str
  if ( i /= 0 ) exit doline
  if ( str == '' .or. scan( '>#!%cCnN', str(1:1) ) /= 0 ) then
    print '(a)', trim( str )
    cycle doline
  end if
  read( str, * ) x
  i = verify( str, ' ' ); str = str(i:)
  i = scan(   str, ' ' ); str = str(i:)
  i = verify( str, ' ' ); str = str(i:)
  i = scan(   str, ' ' ); str = str(i:)
  call ll2ts( x, 1, 2 )
  print '(2f10.0,a)', x, trim( str )
end do doline

end program

