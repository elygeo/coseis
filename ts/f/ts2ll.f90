! Convert TeraShake coordinates in meters to lat/lon
! compile: f95 utm.f90 tscoords.f90 ts2ll.f90 -o ts2ll
! input: ascii file of lat/lon coordinate pairs
! run: ./ts2ll < ascii_file
program ts2ll_p

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
  call ts2ll( x, 1, 2 )
  print '(2f10.5)', x
end do doline

end program

