! Cook URS ShakeOut data

program main
implicit none
real, parameter :: t0 = -0.99375, dt0 = 0.116, dt = 0.1 
integer, parameter :: nn = 225*450, nt = 1500
integer :: io, it0, it = 0
real :: v1(nn), v2(nn), vh(nn), t

inquire( iolength=io ) vh
open( 1, file='v1', recl=io, form='unformatted', access='direct', status='old' )
open( 2, file='v2', recl=io, form='unformatted', access='direct', status='old' )
open( 3, file='vh', recl=io, form='unformatted', access='direct', status='replace' )
do while ( it0 <= nt )
  it = it + 1
  t = dt * ( it - 1 )
  it0 = nint( ( t - t0 ) / dt0 ) + 1
  it0 = max( it0, 1 )
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

