! Cook CMU ShakeOut data

program main
implicit none
real, parameter :: dt0 = 0.096, dt = 0.1
integer, parameter :: nn = 600*300, nt = 2291
integer :: io, it0 = 0, it = 0
real :: vh(nn), t = 0.

inquire( iolength=io ) vh
open( 1, file='vh0', recl=io, form='unformatted', access='direct', status='old' )
open( 2, file='vh',  recl=io, form='unformatted', access='direct', status='replace' )
do while ( it0 <= nt )
  it = it + 1
  t = dt * it
  it0 = int( t / dt0 )
  if ( it0 > nt ) cycle
  print *, it, it0, t
  read( 1, rec=it0 ) vh
  write( 2, rec=it ) vh
enddo
close( 1 )
close( 2 )

end program

