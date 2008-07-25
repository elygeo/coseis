! Cook CMU ShakeOut data

program main
implicit none
real, parameter :: dt0 = 0.096, t0 = 0.5 * dt0, dt = 0.2, dt0r = 1. / dt0
integer, parameter :: nn = 600*300, nt = 2291
real(8) :: x1(nn), y1(nn), z1(nn), x2(nn), y2(nn), z2(nn)
real :: v(nn), pv(nn), pvh(nn), t
integer :: io, it0, it1, it = 1

pv = 0.
pvh = 0.
inquire( iolength=io ) x1
open( 1, file='uu', recl=io, form='unformatted', access='direct', status='old' )
inquire( iolength=io ) v
open( 2, file='vh', recl=io, form='unformatted', access='direct', status='replace' )
read( 1, rec=1 ) x1
read( 1, rec=2 ) y1
read( 1, rec=3 ) z1
do it0 = 1, nt-1
  read( 1, rec=3*it0+1 ) x2
  read( 1, rec=3*it0+2 ) y2
  read( 1, rec=3*it0+3 ) z2
  x1 = x2 - x1
  y1 = y2 - y1
  z1 = z2 - z1
  v  = dt0r * sqrt( x1 * x1 + y1 * y1  + z1 * z1 )
  pv = max( v, pv )
  v  = dt0r * sqrt( x1 * x1 + y1 * y1 )
  pvh = max( v, pvh )
  x1 = x2
  y1 = y2
  z1 = z2
  t = dt * ( it - 1 )
  it1 = nint( ( t - t0 ) / dt0 ) + 1
  it1 = max( it1, 1 )
  if ( it0 == it1 ) then
    print *, it, it0
    write( 2, rec=it ) v
    it = it + 1
  end if
end do
close( 1 )
close( 2 )

open( 1, file='u1',  recl=io, form='unformatted', access='direct', status='replace' )
open( 2, file='u2',  recl=io, form='unformatted', access='direct', status='replace' )
open( 3, file='u3',  recl=io, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) x1
write( 2, rec=1 ) y1
write( 3, rec=1 ) z1
close( 1 )
close( 2 )
close( 3 )

open( 1, file='um',  recl=io, form='unformatted', access='direct', status='replace' )
open( 2, file='uh',  recl=io, form='unformatted', access='direct', status='replace' )
open( 3, file='pv',  recl=io, form='unformatted', access='direct', status='replace' )
open( 4, file='pvh', recl=io, form='unformatted', access='direct', status='replace' )
v = sqrt( x1 * x1 + y1 * y1 + z1 * z1 )
write( 1, rec=1 ) v
v = sqrt( x1 * x1 + y1 * y1 )
write( 2, rec=1 ) v
write( 3, rec=1 ) pv
write( 4, rec=1 ) pvh
close( 1 )
close( 2 )
close( 3 )
close( 4 )

end program

