! Cook CMU ShakeOut data

program main
implicit none
real, parameter :: dt0 = 0.096, t0 = 0.5 * dt0, dt = 0.2, dt0r = 1. / dt0
integer, parameter :: nn = 600*300, nt = 2291
real(8) :: x1(nn), y1(nn), z1(nn), x2(nn), y2(nn), z2(nn)
real :: v(nn), pv(nn), pvh(nn), t
integer :: io, it0, it1 = 0, it = 1

inquire( iolength=io ) x1
open( 1, file='uu', recl=io, form='unformatted', access='direct', status='old' )
inquire( iolength=io ) vh
open( 2, file='vh', recl=io, form='unformatted', access='direct', status='replace' )
read( 1, rec=1 ) x1
read( 1, rec=2 ) y1
read( 1, rec=3 ) z1
do it0 = 2, nt
  it0 = it0 + 1
  read( 1, rec=3*it0-2 ) x2
  read( 1, rec=3*it0-1 ) y2
  read( 1, rec=3*it0   ) z2
  x1 = x2 - x1
  y1 = y2 - y1
  z1 = z2 - z1
  v  = dt0r * sqrt( x1 * x1 + y1 * y1  + z1 * z1 )
  pv = max( v, pv )
  v  = dt0r * sqrt( x1 * x1 + y1 * y1 )
  pvh = max( v, pvh )
  loop: do while ( it1 <= it0 )
    t = dt * ( it - 1 )
    it1 = nint( ( t - t0 ) / dt0 ) + 1
    it1 = max( it1, 1 )
    if ( it1 > it0 ) cycle loop
    write( 2, rec=it ) vh
    it = it + 1
  end do loop
  x1 = x2
  y1 = y2
  z1 = z2
end do
close( 1 )
close( 2 )

v = sqrt( x1 * x1 + y1 * y1 + z1 * z1 )
open( 1, file='u',  recl=io, form='unformatted', access='direct', status='replace' )
open( 2, file='pv', recl=io, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) v
write( 2, rec=1 ) pv
close( 1 )
close( 2 )

v = sqrt( x1 * x1 + y1 * y1 )
open( 1, file='uh',  recl=io, form='unformatted', access='direct', status='replace' )
open( 2, file='pvh', recl=io, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) v
write( 2, rec=1 ) pvh
close( 1 )
close( 2 )

end program

