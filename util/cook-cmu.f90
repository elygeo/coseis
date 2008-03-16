! Cook CMU ShakeOut data

program main
implicit none
real, parameter :: dt0 = 0.096, dt = 0.1, dt0r = 1. / dt0
integer, parameter :: nn = 600*300, nt = 2291
real(8) :: x1(nn), x2(nn), y1(nn), y2(nn)
real :: vh(nn), t = 0.
integer :: io, it0 = 0, it = 0

inquire( iolength=io ) x1
open( 1, file='uu', recl=io, form='unformatted', access='direct', status='old' )
inquire( iolength=io ) vh
open( 2, file='vh', recl=io, form='unformatted', access='direct', status='replace' )
do while ( it0 <= nt )
  it = it + 1
  t = dt * it
  it0 = int( t / dt0 )
  if ( it0 > nt ) cycle
  print *, it, it0, t
  read( 1, rec=3*it0-2 ) x1
  read( 1, rec=3*it0-1 ) y1
  read( 1, rec=3*it0+1 ) x2
  read( 1, rec=3*it0+2 ) y2
  x2 = x2 - x1
  y2 = y2 - y1
  vh = dt0r * sqrt( x2 * x2 + y2 * y2 )
  write( 2, rec=it ) vh
enddo
close( 1 )
close( 2 )

end program

