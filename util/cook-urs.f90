! Cook URS ShakeOut data

program main
implicit none
real, parameter :: dt0 = 0.025, dt = 0.1
integer, parameter :: nn = 113*225, nt = 8000
integer :: io, it0 = 0, it = 0
real :: v1(nn), v2(nn), vh(nn), t = 0.

inquire( iolength=io ) vh
open( 1, file='v1', recl=io, form='unformatted', access='direct', status='old' )
open( 2, file='v2', recl=io, form='unformatted', access='direct', status='old' )
open( 3, file='vh', recl=io, form='unformatted', access='direct', status='replace' )
do while ( it0 <= nt )
  it = it + 1
  t = dt * it
  it0 = nint( t / dt0 )
  if ( it0 > nt ) cycle
  print *, it, it0, t
  read( 1, rec=it0 ) v1
  read( 2, rec=it0 ) v2
  vh = sqrt( v1 * v1 + v2 * v2 )
  write( 3, rec=it ) vh
enddo
close( 1 )
close( 2 )
close( 3 )

end program

