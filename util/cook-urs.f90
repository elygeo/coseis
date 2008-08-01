! Cook URS ShakeOut data

program main
implicit none
real, parameter :: t0 = -2.0, dt0 = 0.2, dt = 0.2
!integer, parameter :: nn = 417*834, nt = 1200
integer, parameter :: nn = 250*500, nt = 1200
integer :: io, it0, it1, it = 1
real :: v1(nn), v2(nn), v3(nn), u1(nn), u2(nn), u3(nn), f(nn), pu(nn), puh(nn), pv(nn), pvh(nn), t

pu  = 0.
puh = 0.
pv  = 0.
pvh = 0.
inquire( iolength=io ) v1
open( 1, file='v1', recl=io, form='unformatted', access='direct', status='old' )
open( 2, file='v2', recl=io, form='unformatted', access='direct', status='old' )
open( 3, file='v3', recl=io, form='unformatted', access='direct', status='old' )
open( 4, file='vh', recl=io, form='unformatted', access='direct', status='replace' )
do it0 = 1, nt-1
  read( 1, rec=it0 ) v1
  read( 2, rec=it0 ) v2
  read( 3, rec=it0 ) v3
  u1 = u1 + dt * v1
  u2 = u2 + dt * v2
  u3 = u3 + dt * v3
  f = sqrt( u1 * u1 + u2 * u2 + u3 * u3 ); pu  = max( f, pu )
  f = sqrt( u1 * u1 + u2 * u2 );           puh = max( f, puh )
  f = sqrt( v1 * v1 + v2 * v2 + v3 * v3 ); pv  = max( f, pv )
  f = sqrt( v1 * v1 + v2 * v2 );           pvh = max( f, pvh )
  t = dt * ( it - 1 )
  it1 = nint( ( t - t0 ) / dt0 ) + 1
  it1 = max( it1, 1 )
  if ( it0 == it1 ) then
    print *, it, it0
    write( 4, rec=it ) f
    it = it + 1
  end if
end do
close( 1 )
close( 2 )
close( 3 )
close( 4 )

open( 1, file='u1',  recl=io, form='unformatted', access='direct', status='replace' )
open( 2, file='u2',  recl=io, form='unformatted', access='direct', status='replace' )
open( 3, file='u3',  recl=io, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) u1
write( 2, rec=1 ) u2
write( 3, rec=1 ) u3
close( 1 )
close( 2 )
close( 3 )

open( 1, file='pu',  recl=io, form='unformatted', access='direct', status='replace' )
open( 2, file='puh', recl=io, form='unformatted', access='direct', status='replace' )
open( 3, file='pv',  recl=io, form='unformatted', access='direct', status='replace' )
open( 4, file='pvh', recl=io, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) pu
write( 2, rec=1 ) puh
write( 3, rec=1 ) pv
write( 4, rec=1 ) pvh
close( 1 )
close( 2 )
close( 3 )
close( 4 )

end program

