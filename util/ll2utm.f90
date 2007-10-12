! Convert lon/lat to UTM coordinates in meters
program main
use m_utm

implicit none
character(1024) :: str
real :: x(1,1,1,2)
integer :: i, zone, command_argument_count

zone = 11
if ( command_argument_count() > 0 ) then
  call get_command_argument( 1, str )
  read( str, * ) zone
end if
doline: do
  read( 5, '(a)', iostat=i ) str
  if ( i /= 0 ) exit doline
  if ( str == '' .or. scan( '>#!%cCnN', str(1:1) ) /= 0 ) then
    print '(a)', trim( str )
    cycle doline
  end if
  read( str, * ) x
  i = verify( str, ' 	' ); str = str(i:)
  i = scan(   str, ' 	' ); str = str(i:)
  i = verify( str, ' 	' ); str = str(i:)
  i = scan(   str, ' 	' ); str = str(i:)
  call ll2utm( x, 1, 2, zone )
  print '(2f14.4,a)', x, trim( str )
end do doline

end program

