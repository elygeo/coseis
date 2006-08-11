! Drape points over topography
program drape

implicit none
real :: t(960,780), x, y, z, h, o1, o2, h1, h2, h3, h4, xx, yy
integer :: j, k, err, reclen
character(160) :: line, str
character :: endian

endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
inquire( iolength=reclen ) t
open( 1, file='topo.'//endian, recl=reclen, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) t
close( 1 ) 

! 30 second grid size, cell centered orogin
h  = 30.
o1 = .5 * h  - 121.5 * 3600.
o2 = .5 * h  +  30.5 * 3600.

! interpolate
doline: do
  read( 5, '(a)', iostat=err ) line
  if ( err /= 0 ) exit doline
  if ( line == '' .or. scan( '>#!%cC', line(1:1) ) /= 0 ) then
    print '(a)', trim( line )
    cycle doline
  end if
  str = ''
  read( line, *, iostat=err ) x, y, str
  if ( err == 0 ) read( line, * ) x, y
  xx = ( ( x * 3600 ) - o1 ) / h
  yy = ( ( y * 3600 ) - o2 ) / h
  j = int( xx ) + 1
  k = int( yy ) + 1
  h1 =  xx - j + 1
  h2 = -xx + j
  h3 =  yy - k + 1
  h4 = -yy + k
  z = ( &
    h2 * h4 * t(j,k)   + &
    h1 * h4 * t(j+1,k) + &
    h2 * h3 * t(j,k+1) + &
    h1 * h3 * t(j+1,k+1) )
  print '(f11.6,x,f9.6,x,f6.1,x,a)', x, y, z, trim( str )
end do doline

end program

