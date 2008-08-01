! Cook CMU ShakeOut data

program main
implicit none
real, parameter :: dt0 = 0.1, t0 = 0.5 * dt0, dt = 0.2, dt0r = 1. / dt0
integer, parameter :: nn = 600*300, nt = 2500
real(8) :: u1(3,nn), u2(3,nn)
real :: f(nn), pu(nn), puh(nn), pv(nn), pvh(nn), t
integer :: io, it0, it1, it = 1

pu  = 0.
puh = 0.
pv  = 0.
pvh = 0.
inquire( iolength=io ) u1
open( 1, file='uu', recl=io, form='unformatted', access='direct', status='old' )
inquire( iolength=io ) f
open( 2, file='vh', recl=io, form='unformatted', access='direct', status='replace' )
read( 1, rec=1 ) u1
do it0 = 1, nt-1
  read( 1, rec=it0+1 ) u2
  u1 = dt0r * ( u2 - u1 )
  f  = sqrt( u2(1,:) * u2(1,:) + u2(2,:) * u2(2,:)  + u2(3,:) * u2(3,:) ); pu  = max( f, pu )
  f  = sqrt( u2(1,:) * u2(1,:) + u2(2,:) * u2(2,:) );                      puh = max( f, puh )
  f  = sqrt( u1(1,:) * u1(1,:) + u1(2,:) * u1(2,:)  + u1(3,:) * u1(3,:) ); pv  = max( f, pv )
  f  = sqrt( u1(1,:) * u1(1,:) + u1(2,:) * u1(2,:) );                      pvh = max( f, pvh )
  t = dt * ( it - 1 )
  it1 = nint( ( t - t0 ) / dt0 ) + 1
  it1 = max( it1, 1 )
  if ( it0 == it1 ) then
    print *, it, it0
    write( 2, rec=it ) f
    it = it + 1
  end if
  u1 = u2
end do
close( 1 )
close( 2 )

open( 1, file='u1',  recl=io, form='unformatted', access='direct', status='replace' )
open( 2, file='u2',  recl=io, form='unformatted', access='direct', status='replace' )
open( 3, file='u3',  recl=io, form='unformatted', access='direct', status='replace' )
f = u1(1,:); write( 1, rec=1 ) f
f = u1(2,:); write( 2, rec=1 ) f
f = u1(3,:); write( 3, rec=1 ) f
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

