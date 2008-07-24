! Cook SDSU ShakeOut data

program main
implicit none
integer, parameter :: n1 = 6000, n2 = 3000, nt = 4540, nblock = 20, nskip = 10, ndec = 5
real, parameter :: t0 = -0.73, dt0 = 0.055, dt = 0.2, rr = 1. / ( ndec * ndec )
integer :: i, j, k, jj, kk, io, it0, it1, it = 1
real :: vx(n1,n2), vy(n1,n2), vz(n1,n2), ux(n1,n2), uy(n1,n2), uz(n1,n2), &
  v(n1,n2), pv(n1,n2), pvh(n1,n2), vh(n1/ndec,n2/ndec), t
character(256) :: f1, f2, f3

pv = 0.
pvh = 0.
inquire( iolength=io ) vh
open( 4, file='vh', recl=io, form='unformatted', access='direct', status='replace' )
inquire( iolength=io ) vx
do it0 = 1, nt-1
  i = modulo( it0 - 1, nblock ) + 1
  write( f1, '(a,i5.5)' ) 'data/SX96PS', ( ( it0 - 1 ) / nblock + 1 ) * nblock * nskip
  write( f2, '(a,i5.5)' ) 'data/SY96PS', ( ( it0 - 1 ) / nblock + 1 ) * nblock * nskip
  write( f3, '(a,i5.5)' ) 'data/SZ96PS', ( ( it0 - 1 ) / nblock + 1 ) * nblock * nskip
  open( 1, file=f1, recl=io, form='unformatted', access='direct', status='old' )
  open( 2, file=f2, recl=io, form='unformatted', access='direct', status='old' )
  open( 3, file=f3, recl=io, form='unformatted', access='direct', status='old' )
  read( 1, rec=i ) vx
  read( 2, rec=i ) vy
  read( 3, rec=i ) vz
  close( 1 )
  close( 2 )
  close( 3 )
  ux = ux + dt * vx
  uy = uy + dt * vy
  uz = uz + dt * vz
  v = sqrt( vx * vx + vy * vy + vz * vz )
  pv = max( v, pv )
  v = sqrt( vx * vx + vy * vy )
  pvh = max( v, pvh )
  t = dt * ( it - 1 )
  it1 = nint( ( t - t0 ) / dt0 ) + 1
  it1 = max( it1, 1 )
  if ( it0 == it1 ) then
    print *, it, it0
    vh = 0.
    do k = 1, n2; kk = ( k - 1 ) / ndec + 1
    do j = 1, n1; jj = ( j - 1 ) / ndec + 1
      vh(jj,kk) = vh(jj,kk) + rr * v(j,k)
    end do
    end do
    write( 4, rec=it ) vh
    it = it + 1
  end if
enddo
close( 4 )

open( 1, file='ux',  recl=io, form='unformatted', access='direct', status='replace' )
open( 2, file='uy',  recl=io, form='unformatted', access='direct', status='replace' )
open( 3, file='uz',  recl=io, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) ux
write( 2, rec=1 ) uy
write( 3, rec=1 ) uz
close( 1 )
close( 2 )
close( 3 )

v = sqrt( ux * ux + uy * uy + uz * uz )
open( 1, file='um',  recl=io, form='unformatted', access='direct', status='replace' )
open( 2, file='pv',  recl=io, form='unformatted', access='direct', status='replace' )
open( 3, file='pvh', recl=io, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) v
write( 2, rec=1 ) pv
write( 3, rec=1 ) pvh
close( 1 )
close( 2 )
close( 3 )

end program

