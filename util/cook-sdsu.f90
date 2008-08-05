! Cook SDSU ShakeOut data

program main
implicit none
integer, parameter :: n1 = 6000, n2 = 3000, nt = 4540, nblock = 20, nskip = 10, ndec = 5
real, parameter :: t0 = -0.73, dt0 = 0.055, dt = 0.2, rr = 1. / ( ndec * ndec )
integer :: i, j, k, jj, kk, io, it0, it1, it = 1
real :: v1(n1,n2), v2(n1,n2), v3(n1,n2), u1(n1,n2), u2(n1,n2), u3(n1,n2), &
  f(n1,n2), pu(n1,n2), puh(n1,n2), pv(n1,n2), pvh(n1,n2), vh(n1/ndec,n2/ndec), t
character(256) :: f1, f2, f3

u1  = 0.
u2  = 0.
u3  = 0.
pu  = 0.
puh = 0.
pv  = 0.
pvh = 0.
inquire( iolength=io ) vh
open( 4, file='vh', recl=io, form='unformatted', access='direct', status='replace' )
inquire( iolength=io ) v1
do it0 = 1, nt-1
  i = modulo( it0 - 1, nblock ) + 1
  write( f1, '(a,i5.5)' ) 'data/SX96PS', ( ( it0 - 1 ) / nblock + 1 ) * nblock * nskip
  write( f2, '(a,i5.5)' ) 'data/SY96PS', ( ( it0 - 1 ) / nblock + 1 ) * nblock * nskip
  write( f3, '(a,i5.5)' ) 'data/SZ96PS', ( ( it0 - 1 ) / nblock + 1 ) * nblock * nskip
  open( 1, file=f1, recl=io, form='unformatted', access='direct', status='old' )
  open( 2, file=f2, recl=io, form='unformatted', access='direct', status='old' )
  open( 3, file=f3, recl=io, form='unformatted', access='direct', status='old' )
  read( 1, rec=i ) v1
  read( 2, rec=i ) v2
  read( 3, rec=i ) v3
  close( 1 )
  close( 2 )
  close( 3 )
  u1 = u1 + dt0 * v1
  u2 = u2 + dt0 * v2
  u3 = u3 + dt0 * v3
  f = sqrt( u1 * u1 + u2 * u2 + u3 * u3 ); pu  = max( f, pu )
  f = sqrt( u1 * u1 + u2 * u2 );           puh = max( f, puh )
  f = sqrt( v1 * v1 + v2 * v2 + v3 * v3 ); pv  = max( f, pv )
  f = sqrt( v1 * v1 + v2 * v2 );           pvh = max( f, pvh )
  t = dt * ( it - 1 )
  it1 = nint( ( t - t0 ) / dt0 ) + 1
  it1 = max( it1, 1 )
  if ( it0 == it1 ) then
    print *, it, it0
    vh = 0.
    do k = 1, n2; kk = ( k - 1 ) / ndec + 1
    do j = 1, n1; jj = ( j - 1 ) / ndec + 1
      vh(jj,kk) = vh(jj,kk) + rr * f(j,k)
    end do
    end do
    write( 4, rec=it ) vh
    it = it + 1
  end if
enddo
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

