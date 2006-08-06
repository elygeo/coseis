! Convert lat/lon to TeraShake coordinates in meters
! compile: f95 utm.f90 tscoords.f90 ll2ts.f90 -o ll2ts
! input: ascii file of coordinate pairs
! run: ./ll2ts < ascii_file
program ll2ts_p

use tscoords_m
implicit none
character(160) :: line
real :: x(1,1,1,2)
integer :: err

doline: do
  read( 5, '(a)', iostat=err ) line
  if ( err /= 0 ) exit doline
  if ( line == '' .or. scan( '>#!%cC', line(1:1) ) /= 0 ) then
    print '(a)', trim( line )
    cycle doline
  end if
  read( line, * ) x
  call ll2ts( x, 1, 2 )
  print '(2f10.0)', x
end do doline

end program

